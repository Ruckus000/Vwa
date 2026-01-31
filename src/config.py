"""
Configuration constants.
Centralized config - single source of truth (DRY).
"""

# API Configuration - Official Urban Dictionary API
API_BASE_URL = "https://api.urbandictionary.com/v0"

# Rate limiting - be conservative with unofficial/undocumented API
REQUEST_DELAY_SECONDS = 1.5  # Slightly more polite than 1s
REQUEST_TIMEOUT_SECONDS = 30

# Retry configuration
MAX_RETRIES = 3
RETRY_BACKOFF_BASE = 2  # Exponential backoff: 2^attempt seconds

# Default paths
DEFAULT_OUTPUT_PATH = "data/slang_terms.json"

# Collection defaults
DEFAULT_TARGET_COUNT = 1000
CHECKPOINT_INTERVAL = 50  # Save progress every N terms
RANDOM_BATCH_SIZE = 10  # API returns ~10 random terms per call

# User agent - identify ourselves politely
USER_AGENT = "SlangCollector/1.0 (educational project; github.com/example/vwa)"
