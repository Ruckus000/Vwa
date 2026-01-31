# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Vwa is a bilingual slang translation project consisting of two components:

1. **Python Data Collector** (src/ directory): Scrapes American English slang from Urban Dictionary API and processes it with AI translations
2. **Swift iOS App** (ios/ directory): Native iOS app that displays curated slang with voice recognition and Spanish/French translations

## Python Collector

### Development Commands

**Basic workflow:**
```bash
# Activate virtual environment
source venv/bin/activate

# Test API connection
cd src
python cli.py --dry-run

# Collect slang terms
python cli.py -n 1000  # Collects 1000 terms, auto-resumes if interrupted

# View statistics
python cli.py --stats

# Process with AI translations
export GROQ_API_KEY="your-key-here"
python translate_terms.py --input data/slang_terms.json --output data/processed_terms.json
```

**Common CLI flags:**
- `-n COUNT` - Number of terms to collect (default: 1000)
- `-o OUTPUT` - Output file path (default: data/slang_terms.json)
- `--no-resume` - Start fresh, ignore existing data
- `-v` - Verbose debug logging

### Architecture

Clean architecture with clear separation of concerns:

```
src/
├── cli.py                      # Entry point with signal handling
├── config.py                   # Centralized configuration constants
├── domain/
│   ├── models.py               # SlangTerm dataclass with validation
│   └── filters.py              # Data filtering utilities
├── clients/
│   └── urban_api_client.py     # HTTP client with retry logic
├── repos/
│   └── json_repo.py            # Atomic JSON persistence
└── services/
    └── collector_service.py    # Collection orchestration
```

**Key Design Principles:**
- **SRP**: Each module has one responsibility
- **Atomic writes**: Uses temp file + rename to prevent data corruption
- **Graceful shutdown**: Ctrl+C saves progress via signal handlers
- **Deduplication**: By unique definition ID (`defid`), not just by word
- **Checkpoint saving**: Progress saved every 50 terms

**API Details:**
- Urban Dictionary public API: `https://api.urbandictionary.com/v0`
- Rate limited to 1.5 requests/second
- Random endpoint returns ~10 terms per call
- Retry logic: 3 retries with exponential backoff

### Data Processing

The `translate_terms.py` script uses Groq's free API (Llama 3) for:
- Spanish/French contextual explanations (not literal translations)
- Category assignment (TRUTH, PRAISE, CRITICISM, etc.)
- Content filtering

**Critical**: Data quality requires manual curation. Random Urban Dictionary terms are not always Gen Z slang. Filter to curated list before processing.

## Swift iOS App

### Development Commands

**Building and running:**
```bash
# Open in Xcode
open Vwa.xcodeproj

# Build from command line
xcodebuild -project Vwa.xcodeproj -scheme Vwa -configuration Debug

# Run tests (when added)
xcodebuild test -project Vwa.xcodeproj -scheme Vwa
```

**TestFlight deployment:**
```bash
# Using EAS CLI (if configured)
eas build --platform ios --profile preview
```

### Architecture

Native SwiftUI app with MVVM pattern:

```
ios/
├── VwaApp.swift              # App entry point
├── Models/
│   ├── SlangTerm.swift       # Core data model with Codable
│   ├── Category.swift        # Enum for term categories
│   ├── Language.swift        # ES/FR language enum
│   └── Theme.swift           # Dark/Light theme enum
├── ViewModels/
│   └── TermStore.swift       # ObservableObject for app state
├── Views/
│   ├── MainView.swift        # Primary screen with term display
│   ├── BrowseView.swift      # Search/browse all terms
│   └── Components/           # Reusable UI components
├── Services/
│   ├── SpeechRecognizer.swift    # Voice recognition
│   └── TermSearch.swift          # Fuzzy search with phonetic matching
├── Theme/
│   ├── Colors.swift          # Neo-brutalist color system
│   └── BrutalModifiers.swift # Custom view modifiers
└── Resources/
    └── terms.json            # Bundled slang data (curated)
```

**Design System:**
- **Style**: Neo-brutalist with bold borders, hard shadows, and high contrast
- **Colors**: Custom dark/light themes with heavy use of black borders
- **Typography**: System fonts with heavy weights
- **Shadows**: Hard shadows (no blur) with offset

**Key Features:**
- **Voice Recognition**: Uses Speech framework with silence-based auto-stop
- **Fuzzy Search**: Levenshtein distance with scaled thresholds for short terms
- **Phonetic Matching**: Handles common voice transcription errors (e.g., "no cat" → "no cap")
- **Debounced Search**: 300ms debounce on text search to prevent lag
- **State Persistence**: User preferences saved with UserDefaults

### Voice Recognition Implementation

The app uses iOS Speech framework with smart timeout logic:
- **Silence detection**: Auto-stops 1.5s after speech ends (not hard timeout)
- **Transcription corrections**: Maps common errors (e.g., "bussing" → "bussin")
- **Scaled thresholds**: Short terms (2-3 chars) require exact match; longer terms allow more errors
- **Phonetic fallback**: Simple phonetic coding catches spelling variations

**iOS Compatibility:**
- Target: iOS 15+
- Uses single-parameter `onChange` syntax for iOS 15 compatibility
- NavigationStack for iOS 16+ navigation

## Data Flow

```
Urban Dictionary API
  ↓ (cli.py)
data/slang_terms.json (raw, 1000+ terms)
  ↓ (manual curation + translate_terms.py)
data/curated_terms.json (40-50 quality terms)
  ↓ (manual copy)
ios/Resources/terms.json (bundled in iOS app)
```

**Critical Steps:**
1. Collect raw data with Python collector
2. Manually curate to real Gen Z slang (not random UD entries)
3. Process with AI translations
4. Copy curated JSON to Swift app Resources/

## Common Development Tasks

### Adding New Slang Terms to iOS App

1. Edit `data/curated_terms.json` (or use spreadsheet method from implementation plan)
2. Run translation script if needed
3. Copy to `ios/Resources/terms.json`
4. Rebuild iOS app in Xcode

### Debugging Voice Recognition Issues

1. Check microphone permissions in iOS Settings
2. Test with known terms from `terms.json`
3. Add new transcription corrections to `Services/TermSearch.swift` if needed
4. Adjust fuzzy match threshold in `calculateThreshold()` for problematic terms

### Testing Collection Script

```bash
cd src
python cli.py --dry-run     # Test API without saving
python cli.py -n 10 -v      # Collect 10 terms with debug output
```

## Project State & Next Steps

**Current Status:**
- Python collector: ✅ Fully functional
- Translation pipeline: ✅ Working with Groq API
- Swift app: ⚠️  In development (check implementation plans for current phase)
- Data quality: ⚠️  Requires manual curation (see VWA_Swift_Implementation_Plan_v2.md Phase 0)

**Implementation Plans:**
- `VWA_Swift_Implementation_Plan_v2.md`: Detailed Swift implementation with code snippets
- `implement.md`: Original React Native plan (deprecated in favor of Swift)

**Known Issues:**
1. Random Urban Dictionary data contains low-quality terms - manual curation required before processing
2. Voice recognition accuracy varies with background noise
3. Short slang terms (2-3 chars) need exact match to avoid false positives

## Testing

**Current state**: No automated tests yet. Testing strategy deferred per YAGNI principles until MVP validates concept.

**Manual testing workflows:**
- Python: Run with `--dry-run` and `--stats` flags
- iOS: Build and run on physical device via Xcode

## Configuration

**Python:**
- Configuration in `src/config.py`
- API rate limiting: 1.5s between requests
- Checkpoint interval: Save every 50 terms

**Swift:**
- No external configuration files
- Preferences persisted via TermStore + UserDefaults
- Bundled data in Resources/terms.json

## External Dependencies

**Python:**
- `requests>=2.28.0` (only dependency)
- Groq API key required for translation (free tier sufficient)

**Swift:**
- iOS Speech framework (system)
- No third-party dependencies

## Design Philosophy

From the codebase and docs:
- **KISS**: No unnecessary abstractions
- **YAGNI**: Only features that are actually used
- **DRY**: Centralized config and validation
- **SRP**: Each module has one responsibility
- **Atomic operations**: Prevent data corruption with temp file writes
- **Graceful degradation**: Errors don't lose data (checkpoints, signal handling)
