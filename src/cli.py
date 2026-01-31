#!/usr/bin/env python3
"""
Slang Collector CLI.
Entry point for collecting American English slang terms from Urban Dictionary.

Usage:
    python cli.py --dry-run          # Test API connection
    python cli.py -n 1000            # Collect 1000 terms
    python cli.py -n 500 --no-resume # Start fresh, ignore existing data
"""
import argparse
import logging
import sys
import signal
from pathlib import Path
from typing import Optional

from clients.urban_api_client import UrbanAPIClient, APIError, RateLimitError
from repos.json_repo import JsonRepo
from services.collector_service import CollectorService
from config import DEFAULT_OUTPUT_PATH, DEFAULT_TARGET_COUNT


# Global reference for signal handler
_service: Optional[CollectorService] = None
_current_terms: list = []


def setup_logging(verbose: bool = False) -> None:
    """Configure logging."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%H:%M:%S",
    )


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Collect American English slang terms from Urban Dictionary",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    
    parser.add_argument(
        "-o", "--output",
        type=str,
        default=DEFAULT_OUTPUT_PATH,
        help="Output JSON file path",
    )
    
    parser.add_argument(
        "-n", "--count",
        type=int,
        default=DEFAULT_TARGET_COUNT,
        help="Number of terms to collect",
    )
    
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable debug logging",
    )
    
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Test API connection without saving",
    )
    
    parser.add_argument(
        "--no-resume",
        action="store_true",
        help="Start fresh, ignore existing data",
    )
    
    parser.add_argument(
        "--stats",
        action="store_true",
        help="Show statistics about existing data and exit",
    )
    
    return parser.parse_args()


def handle_interrupt(signum, frame):
    """Handle Ctrl+C gracefully by saving current progress."""
    global _service, _current_terms
    
    print("\n\nInterrupted! Saving progress...")
    
    if _service and _current_terms:
        try:
            _service.repo.save(_current_terms)
            print(f"Saved {len(_current_terms)} terms before exit.")
        except Exception as e:
            print(f"Failed to save: {e}")
    
    sys.exit(130)


def run_dry_run(client: UrbanAPIClient) -> int:
    """Test API connection."""
    logger = logging.getLogger(__name__)
    
    logger.info("Testing API connection...")
    
    try:
        results = client.random()
        
        if not results:
            logger.error("API returned empty response")
            return 1
        
        logger.info(f"API test successful! Got {len(results)} definitions")
        logger.info("Sample terms:")
        
        for item in results[:5]:
            word = item.get("word", "unknown")
            definition = item.get("definition", "")[:60]
            thumbs = item.get("thumbs_up", 0)
            logger.info(f"  - {word} (👍 {thumbs}): {definition}...")
        
        return 0
        
    except RateLimitError as e:
        logger.error(f"Rate limited: {e}")
        return 1
        
    except APIError as e:
        logger.error(f"API error: {e}")
        return 1


def run_stats(repo: JsonRepo) -> int:
    """Show statistics about existing data."""
    logger = logging.getLogger(__name__)
    
    if not repo.exists():
        logger.info(f"No data file found at {repo.filepath}")
        return 0
    
    terms = repo.load()
    
    if not terms:
        logger.info("Data file is empty")
        return 0
    
    unique_words = len(set(t.word.lower() for t in terms))
    total_up = sum(t.thumbs_up for t in terms)
    total_down = sum(t.thumbs_down for t in terms)
    avg_score = total_up / (total_up + total_down) if (total_up + total_down) > 0 else 0
    
    logger.info("=" * 50)
    logger.info("Data Statistics")
    logger.info("=" * 50)
    logger.info(f"Total definitions: {len(terms)}")
    logger.info(f"Unique words: {unique_words}")
    logger.info(f"Total thumbs up: {total_up:,}")
    logger.info(f"Total thumbs down: {total_down:,}")
    logger.info(f"Average score: {avg_score:.1%}")
    
    # Top 5 by popularity
    by_popularity = sorted(terms, key=lambda t: t.popularity, reverse=True)[:5]
    logger.info("\nTop 5 by engagement:")
    for t in by_popularity:
        logger.info(f"  - {t.word}: {t.popularity:,} votes")
    
    return 0


def main() -> int:
    """Main entry point."""
    global _service, _current_terms
    
    args = parse_args()
    setup_logging(args.verbose)
    
    logger = logging.getLogger(__name__)
    
    # Resolve output path relative to project root
    script_dir = Path(__file__).parent.parent
    output_path = script_dir / args.output
    
    # Initialize components
    repo = JsonRepo(output_path)
    
    # Handle stats-only mode
    if args.stats:
        return run_stats(repo)
    
    logger.info("=" * 50)
    logger.info("Urban Dictionary Slang Collector")
    logger.info("=" * 50)
    logger.info(f"Target: {args.count} terms")
    logger.info(f"Output: {output_path}")
    logger.info(f"Resume: {'disabled' if args.no_resume else 'enabled'}")
    
    client = UrbanAPIClient()
    
    try:
        # Dry run mode
        if args.dry_run:
            return run_dry_run(client)
        
        # Set up signal handler for graceful shutdown
        signal.signal(signal.SIGINT, handle_interrupt)
        signal.signal(signal.SIGTERM, handle_interrupt)
        
        # Initialize service
        service = CollectorService(client, repo)
        _service = service  # For signal handler
        
        # Run collection
        logger.info("Starting collection...")
        terms = service.collect(
            target_count=args.count,
            resume=not args.no_resume,
        )
        _current_terms = terms  # For signal handler
        
        # Summary
        logger.info("=" * 50)
        logger.info("Collection Summary")
        logger.info("=" * 50)
        logger.info(f"Total definitions collected: {len(terms)}")
        logger.info(f"Unique words: {len(set(t.word.lower() for t in terms))}")
        logger.info(f"Output file: {output_path}")
        
        if terms:
            logger.info("\nSample terms:")
            for term in terms[:5]:
                preview = term.definition[:50].replace("\n", " ")
                logger.info(f"  - {term.word}: {preview}...")
        
        return 0
        
    except KeyboardInterrupt:
        # Should be handled by signal handler, but just in case
        logger.warning("Interrupted")
        return 130
        
    except Exception as e:
        logger.error(f"Collection failed: {e}")
        if args.verbose:
            logger.exception("Full traceback:")
        return 1
        
    finally:
        client.close()


if __name__ == "__main__":
    sys.exit(main())
