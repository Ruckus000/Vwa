#!/usr/bin/env python3
"""
VWA Preprocessing Script
Transforms raw Urban Dictionary data into app-ready content with translations.

Uses Groq's free API (Llama 3) for:
- Spanish/French contextual explanations
- Category assignment
- Content filtering

Usage:
    export GROQ_API_KEY="your-key-here"
    python translate_terms.py --input data/slang_terms.json --output data/processed_terms.json

Free tier limits (Groq):
    - 14,400 requests/day
    - 30 requests/minute
    - More than enough for 1000 terms
"""

import json
import os
import sys
import time
import re
import argparse
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import Optional
from groq import Groq, RateLimitError, APIError

# ============================================================================
# Configuration
# ============================================================================

GROQ_MODEL = "llama-3.3-70b-versatile"  # Free, high quality
REQUESTS_PER_MINUTE = 25  # Stay under 30 RPM limit
CHECKPOINT_EVERY = 10  # Save progress every N terms
MAX_RETRIES = 3
RETRY_DELAY = 5  # seconds

CATEGORIES = [
    "AGREEMENT",   # bet, facts, say less
    "CRITICISM",   # mid, sus, cringe  
    "DEGREE",      # lowkey, highkey, deadass
    "EMOTION",     # salty, pressed, tilted
    "PRAISE",      # slay, goated, fire
    "QUALITY",     # bussin, slaps, hits different
    "TRUTH",       # no cap, fr fr, on god
    "OTHER",       # catch-all
]

# Words/patterns that indicate explicit content to filter out
EXPLICIT_PATTERNS = [
    r'\bsex\b', r'\bporn', r'\bfuck(?!ing\s+amazing)', r'\bdick\b', r'\bpussy\b',
    r'\bcock\b', r'\bass\s?hole', r'\bslut\b', r'\bwhore\b', r'\bcum\b',
    r'\bmasturbat', r'\borgasm', r'\berection', r'\banus\b', r'\bgenital',
    r'\brape\b', r'\bpedophil', r'\bincest', r'\bbestiality',
    # Add more as needed
]

# ============================================================================
# Data Models
# ============================================================================

@dataclass
class Translation:
    definition: str
    example: Optional[str]

@dataclass
class ProcessedTerm:
    id: int
    term: str
    category: str
    definition: str
    example: Optional[str]
    translations: dict  # {"ES": Translation, "FR": Translation}
    meta: dict

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "term": self.term,
            "category": self.category,
            "definition": self.definition,
            "example": self.example,
            "translations": {
                "ES": asdict(self.translations["ES"]),
                "FR": asdict(self.translations["FR"]),
            },
            "meta": self.meta,
        }

# ============================================================================
# Content Filtering
# ============================================================================

def is_explicit(text: str) -> bool:
    """Check if text contains explicit content."""
    if not text:
        return False
    text_lower = text.lower()
    for pattern in EXPLICIT_PATTERNS:
        if re.search(pattern, text_lower):
            return True
    return False

def is_quality_term(term: dict) -> bool:
    """
    Filter for quality terms worth including.
    
    Criteria:
    - Has a definition
    - Definition is substantive (not just a few words)
    - Not explicit content
    - Reasonably popular (some engagement) OR recent
    """
    word = term.get("word", "")
    definition = term.get("definition", "")
    example = term.get("example", "")
    thumbs_up = term.get("thumbs_up", 0)
    thumbs_down = term.get("thumbs_down", 0)
    
    # Must have word and definition
    if not word or not definition:
        return False
    
    # Definition should be substantive
    if len(definition) < 20:
        return False
    
    # Filter explicit content
    if is_explicit(word) or is_explicit(definition) or is_explicit(example or ""):
        return False
    
    # Filter very low quality (many downvotes, few upvotes)
    total_votes = thumbs_up + thumbs_down
    if total_votes > 10 and thumbs_down > thumbs_up * 2:
        return False
    
    return True

def clean_text(text: str) -> str:
    """Clean Urban Dictionary formatting artifacts."""
    if not text:
        return ""
    # Remove [brackets] used for links
    text = re.sub(r'\[([^\]]+)\]', r'\1', text)
    # Normalize whitespace
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

# ============================================================================
# Groq API Integration
# ============================================================================

def create_translation_prompt(term: str, definition: str, example: str, language: str) -> str:
    """Create prompt for contextual translation."""
    lang_name = "Spanish" if language == "ES" else "French"
    
    return f"""You are helping translate Gen Z/internet slang for {lang_name} speakers.

SLANG TERM: {term}
ENGLISH MEANING: {definition}
EXAMPLE USAGE: {example if example else "N/A"}

Your task:
1. Write a clear explanation in {lang_name} that helps someone understand this slang
2. Don't do literal word-for-word translation - explain the MEANING and USAGE
3. If there's an example, provide a natural {lang_name} equivalent

Respond with ONLY valid JSON (no markdown, no extra text):
{{"definition": "your {lang_name} explanation here", "example": "translated example or null"}}"""

def create_category_prompt(term: str, definition: str) -> str:
    """Create prompt for category assignment."""
    categories_str = ", ".join(CATEGORIES)
    
    return f"""Categorize this slang term into ONE of these categories: {categories_str}

TERM: {term}
MEANING: {definition}

Categories explained:
- AGREEMENT: affirming, saying yes (bet, facts, say less)
- CRITICISM: negative judgment (mid, sus, cringe)
- DEGREE: intensity modifiers (lowkey, highkey, deadass)
- EMOTION: feelings/reactions (salty, pressed, tilted)
- PRAISE: positive compliments (slay, goated, fire)
- QUALITY: describing something good/bad (bussin, slaps)
- TRUTH: honesty/sincerity (no cap, fr fr, on god)
- OTHER: doesn't fit above categories

Respond with ONLY the category name, nothing else."""

class GroqTranslator:
    def __init__(self, api_key: str):
        self.client = Groq(api_key=api_key)
        self.request_times: list[float] = []
    
    def _rate_limit(self):
        """Ensure we don't exceed rate limits."""
        now = time.time()
        # Remove requests older than 60 seconds
        self.request_times = [t for t in self.request_times if now - t < 60]
        
        if len(self.request_times) >= REQUESTS_PER_MINUTE:
            sleep_time = 60 - (now - self.request_times[0]) + 1
            print(f"    Rate limit: sleeping {sleep_time:.1f}s...")
            time.sleep(sleep_time)
        
        self.request_times.append(time.time())
    
    def _call_api(self, prompt: str, retries: int = MAX_RETRIES) -> str:
        """Make API call with retry logic."""
        self._rate_limit()
        
        for attempt in range(retries):
            try:
                response = self.client.chat.completions.create(
                    model=GROQ_MODEL,
                    messages=[{"role": "user", "content": prompt}],
                    temperature=0.3,
                    max_tokens=500,
                )
                return response.choices[0].message.content.strip()
            
            except RateLimitError:
                print(f"    Rate limited, waiting {RETRY_DELAY * (attempt + 1)}s...")
                time.sleep(RETRY_DELAY * (attempt + 1))
            
            except APIError as e:
                print(f"    API error: {e}")
                if attempt < retries - 1:
                    time.sleep(RETRY_DELAY)
                else:
                    raise
        
        raise Exception("Max retries exceeded")
    
    def translate(self, term: str, definition: str, example: str, language: str) -> Translation:
        """Get translation for a term."""
        prompt = create_translation_prompt(term, definition, example, language)
        response = self._call_api(prompt)
        
        try:
            # Clean potential markdown formatting
            response = response.strip()
            if response.startswith("```"):
                response = re.sub(r'^```(?:json)?\n?', '', response)
                response = re.sub(r'\n?```$', '', response)
            
            data = json.loads(response)
            return Translation(
                definition=data.get("definition", ""),
                example=data.get("example"),
            )
        except json.JSONDecodeError:
            print(f"    Warning: Could not parse translation response")
            return Translation(definition=response[:500], example=None)
    
    def categorize(self, term: str, definition: str) -> str:
        """Assign category to a term."""
        prompt = create_category_prompt(term, definition)
        response = self._call_api(prompt)
        
        # Extract category from response
        response_upper = response.upper().strip()
        for cat in CATEGORIES:
            if cat in response_upper:
                return cat
        
        return "OTHER"

# ============================================================================
# Main Processing
# ============================================================================

def load_checkpoint(checkpoint_path: Path) -> set[int]:
    """Load IDs of already processed terms."""
    if checkpoint_path.exists():
        with open(checkpoint_path) as f:
            return set(json.load(f))
    return set()

def save_checkpoint(checkpoint_path: Path, processed_ids: set[int]):
    """Save processed IDs to checkpoint file."""
    with open(checkpoint_path, 'w') as f:
        json.dump(list(processed_ids), f)

def load_progress(output_path: Path) -> list[dict]:
    """Load already processed terms."""
    if output_path.exists():
        with open(output_path) as f:
            return json.load(f)
    return []

def save_progress(output_path: Path, terms: list[dict]):
    """Save processed terms (atomic write)."""
    temp_path = output_path.with_suffix('.tmp')
    with open(temp_path, 'w') as f:
        json.dump(terms, f, indent=2, ensure_ascii=False)
    temp_path.replace(output_path)

def process_terms(
    input_path: Path,
    output_path: Path,
    limit: Optional[int] = None,
    skip_filter: bool = False,
):
    """Main processing function."""
    
    # Check for API key
    api_key = os.environ.get("GROQ_API_KEY")
    if not api_key:
        print("Error: GROQ_API_KEY environment variable not set")
        print("Get your free API key at: https://console.groq.com")
        sys.exit(1)
    
    # Load input
    print(f"Loading {input_path}...")
    with open(input_path) as f:
        raw_terms = json.load(f)
    print(f"  Loaded {len(raw_terms)} raw terms")
    
    # Filter
    if skip_filter:
        filtered_terms = raw_terms
    else:
        print("Filtering terms...")
        filtered_terms = [t for t in raw_terms if is_quality_term(t)]
        print(f"  {len(filtered_terms)} terms passed quality filter")
    
    # Apply limit
    if limit:
        filtered_terms = filtered_terms[:limit]
        print(f"  Limited to {limit} terms")
    
    # Load existing progress
    checkpoint_path = output_path.with_suffix('.checkpoint.json')
    processed_ids = load_checkpoint(checkpoint_path)
    processed_terms = load_progress(output_path)
    
    if processed_ids:
        print(f"  Resuming: {len(processed_ids)} terms already processed")
    
    # Initialize translator
    translator = GroqTranslator(api_key)
    
    # Process each term
    total = len(filtered_terms)
    for i, raw_term in enumerate(filtered_terms):
        term_id = raw_term.get("defid", 0)
        
        # Skip if already processed
        if term_id in processed_ids:
            continue
        
        term_word = raw_term.get("word", "")
        definition = clean_text(raw_term.get("definition", ""))
        example = clean_text(raw_term.get("example", ""))
        
        print(f"[{i+1}/{total}] Processing: {term_word}")
        
        try:
            # Get category
            print("    Categorizing...")
            category = translator.categorize(term_word, definition)
            print(f"    Category: {category}")
            
            # Get Spanish translation
            print("    Translating to Spanish...")
            es_translation = translator.translate(term_word, definition, example, "ES")
            
            # Get French translation
            print("    Translating to French...")
            fr_translation = translator.translate(term_word, definition, example, "FR")
            
            # Create processed term
            processed = ProcessedTerm(
                id=term_id,
                term=term_word,
                category=category,
                definition=definition,
                example=example if example else None,
                translations={
                    "ES": es_translation,
                    "FR": fr_translation,
                },
                meta={
                    "thumbsUp": raw_term.get("thumbs_up", 0),
                    "thumbsDown": raw_term.get("thumbs_down", 0),
                    "author": raw_term.get("author", ""),
                    "addedOn": raw_term.get("written_on", ""),
                },
            )
            
            processed_terms.append(processed.to_dict())
            processed_ids.add(term_id)
            
            # Checkpoint
            if len(processed_ids) % CHECKPOINT_EVERY == 0:
                print(f"    Checkpointing ({len(processed_ids)} processed)...")
                save_progress(output_path, processed_terms)
                save_checkpoint(checkpoint_path, processed_ids)
        
        except KeyboardInterrupt:
            print("\n\nInterrupted! Saving progress...")
            save_progress(output_path, processed_terms)
            save_checkpoint(checkpoint_path, processed_ids)
            print(f"Progress saved. {len(processed_ids)} terms processed.")
            print(f"Run again to resume.")
            sys.exit(0)
        
        except Exception as e:
            print(f"    Error processing term: {e}")
            # Save progress and continue
            save_progress(output_path, processed_terms)
            save_checkpoint(checkpoint_path, processed_ids)
            continue
    
    # Final save
    save_progress(output_path, processed_terms)
    save_checkpoint(checkpoint_path, processed_ids)
    
    # Clean up checkpoint file on completion
    if len(processed_ids) == len(filtered_terms):
        checkpoint_path.unlink(missing_ok=True)
    
    print(f"\nDone! Processed {len(processed_terms)} terms")
    print(f"Output saved to: {output_path}")

# ============================================================================
# CLI
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Process slang terms with Groq translations"
    )
    parser.add_argument(
        "--input", "-i",
        type=Path,
        required=True,
        help="Input JSON file (raw Urban Dictionary data)"
    )
    parser.add_argument(
        "--output", "-o",
        type=Path,
        required=True,
        help="Output JSON file (processed terms)"
    )
    parser.add_argument(
        "--limit", "-n",
        type=int,
        default=None,
        help="Limit number of terms to process (for testing)"
    )
    parser.add_argument(
        "--skip-filter",
        action="store_true",
        help="Skip content filtering (process all terms)"
    )
    
    args = parser.parse_args()
    
    if not args.input.exists():
        print(f"Error: Input file not found: {args.input}")
        sys.exit(1)
    
    # Create output directory if needed
    args.output.parent.mkdir(parents=True, exist_ok=True)
    
    process_terms(
        input_path=args.input,
        output_path=args.output,
        limit=args.limit,
        skip_filter=args.skip_filter,
    )

if __name__ == "__main__":
    main()
