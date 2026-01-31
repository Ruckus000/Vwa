"""
Collector service.
Orchestrates data collection by coordinating client and repo.

Features:
- Resume capability: loads existing data and continues from where it left off
- Checkpoint saving: saves progress periodically to prevent data loss
- Deduplication by defid: ensures unique definitions across runs
"""
import logging
from typing import List, Set, Dict, Any, Optional

from domain.models import SlangTerm
from clients.urban_api_client import UrbanAPIClient, APIError, RateLimitError
from repos.json_repo import JsonRepo
from config import CHECKPOINT_INTERVAL, RANDOM_BATCH_SIZE


logger = logging.getLogger(__name__)


class CollectorService:
    """
    Orchestrates slang term collection with fault tolerance.
    
    Collection Strategy:
    1. Load any existing data (resume capability)
    2. Collect random terms until target reached
    3. Checkpoint every N terms to prevent data loss
    4. Deduplicate by defid (unique definition ID)
    
    Why random endpoint only:
    - The /define endpoint requires knowing words in advance
    - The /random endpoint gives us diverse, varied content
    - No official browse-by-letter endpoint exists
    """

    def __init__(
        self,
        client: UrbanAPIClient,
        repo: JsonRepo,
        checkpoint_interval: int = CHECKPOINT_INTERVAL,
    ):
        self.client = client
        self.repo = repo
        self.checkpoint_interval = checkpoint_interval
        self._seen_defids: Set[int] = set()

    def collect(
        self,
        target_count: int,
        resume: bool = True,
    ) -> List[SlangTerm]:
        """
        Collect slang terms up to target count.
        
        Args:
            target_count: Number of unique definitions to collect
            resume: If True, load existing data and continue from there
            
        Returns:
            List of all collected SlangTerms
        """
        all_terms: List[SlangTerm] = []
        self._seen_defids.clear()
        
        # Resume from existing data if available
        if resume and self.repo.exists():
            all_terms = self.repo.load()
            self._seen_defids = {term.defid for term in all_terms}
            
            if len(all_terms) >= target_count:
                logger.info(f"Already have {len(all_terms)} terms (target: {target_count})")
                return all_terms[:target_count]
            
            logger.info(f"Resuming collection: {len(all_terms)}/{target_count} terms")
        else:
            logger.info(f"Starting fresh collection. Target: {target_count} terms")
        
        # Track for checkpointing
        last_checkpoint_count = len(all_terms)
        consecutive_failures = 0
        max_consecutive_failures = 10
        
        # Collection loop
        while len(all_terms) < target_count:
            try:
                # Fetch random batch
                raw_data = self.client.random()
                
                if not raw_data:
                    logger.warning("Empty response from /random endpoint")
                    consecutive_failures += 1
                    if consecutive_failures >= max_consecutive_failures:
                        logger.error("Too many consecutive empty responses. Stopping.")
                        break
                    continue
                
                # Reset failure counter on success
                consecutive_failures = 0
                
                # Parse and dedupe
                new_terms = self._parse_and_dedupe(raw_data)
                all_terms.extend(new_terms)
                
                logger.debug(
                    f"Batch: +{len(new_terms)} new terms "
                    f"(total: {len(all_terms)}/{target_count})"
                )
                
                # Checkpoint periodically
                if len(all_terms) - last_checkpoint_count >= self.checkpoint_interval:
                    self._checkpoint(all_terms)
                    last_checkpoint_count = len(all_terms)
                    logger.info(f"Progress: {len(all_terms)}/{target_count} terms")
                
            except RateLimitError as e:
                logger.error(f"Rate limited: {e}. Stopping collection.")
                break
                
            except APIError as e:
                logger.warning(f"API error: {e}")
                consecutive_failures += 1
                if consecutive_failures >= max_consecutive_failures:
                    logger.error("Too many consecutive API errors. Stopping.")
                    break
                continue
        
        # Final save
        final_terms = all_terms[:target_count]
        self.repo.save(final_terms)
        
        logger.info(f"Collection complete. Total: {len(final_terms)} terms")
        return final_terms

    def _parse_and_dedupe(self, raw_data: List[Dict[str, Any]]) -> List[SlangTerm]:
        """Parse API response and remove duplicates."""
        terms: List[SlangTerm] = []
        
        for item in raw_data:
            term = SlangTerm.from_api_response(item)
            
            if term is None:
                continue
            
            # Dedupe by defid (unique definition ID)
            if term.defid in self._seen_defids:
                continue
            
            self._seen_defids.add(term.defid)
            terms.append(term)
        
        return terms

    def _checkpoint(self, terms: List[SlangTerm]) -> None:
        """Save checkpoint to prevent data loss."""
        try:
            self.repo.save(terms)
            logger.debug(f"Checkpoint saved: {len(terms)} terms")
        except Exception as e:
            logger.warning(f"Checkpoint save failed: {e}")

    def get_stats(self) -> Dict[str, Any]:
        """Get statistics about collected data."""
        terms = self.repo.load()
        
        if not terms:
            return {"count": 0}
        
        total_up = sum(t.thumbs_up for t in terms)
        total_down = sum(t.thumbs_down for t in terms)
        
        return {
            "count": len(terms),
            "unique_words": len(set(t.word.lower() for t in terms)),
            "total_thumbs_up": total_up,
            "total_thumbs_down": total_down,
            "avg_score": total_up / (total_up + total_down) if (total_up + total_down) > 0 else 0,
        }
