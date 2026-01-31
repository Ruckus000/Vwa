# Vwa - Slang Translation App

A bilingual project for translating American English slang to Spanish and French, consisting of:

1. **Python Data Collector** (`src/`): CLI tool to collect and process slang from Urban Dictionary API
2. **Swift iOS App** (`ios/`): Native iOS app with voice recognition and translations

## Project Structure

```
Vwa/
├── src/                    # Python slang collector
├── ios/                    # Swift iOS app sources
├── data/                   # Collected and processed slang data
├── Vwa.xcodeproj/         # Xcode project
├── requirements.txt       # Python dependencies
└── translate_terms.py     # AI translation script
```

## Python Collector - Quick Start

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Test API connection
cd src
python cli.py --dry-run

# Collect 1000 terms (auto-resumes if interrupted)
python cli.py -n 1000

# View statistics about collected data
python cli.py --stats
```

## Swift iOS App - Quick Start

```bash
# Open in Xcode
open Vwa.xcodeproj

# Build from command line
xcodebuild -project Vwa.xcodeproj -scheme Vwa -configuration Debug
```

## Usage

```
usage: cli.py [-h] [-o OUTPUT] [-n COUNT] [-v] [--dry-run] [--no-resume] [--stats]

Collect American English slang terms from Urban Dictionary

options:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        Output JSON file path (default: data/slang_terms.json)
  -n COUNT, --count COUNT
                        Number of terms to collect (default: 1000)
  -v, --verbose         Enable debug logging
  --dry-run             Test API connection without saving
  --no-resume           Start fresh, ignore existing data
  --stats               Show statistics about existing data and exit
```

## Features

- **Resume Capability**: Automatically continues from where it left off if interrupted
- **Checkpoint Saving**: Saves progress every 50 terms to prevent data loss
- **Graceful Shutdown**: Ctrl+C saves current progress before exiting
- **Retry Logic**: Exponential backoff on API failures (3 retries)
- **Atomic Writes**: Uses temp file + rename to prevent data corruption
- **Deduplication**: By unique definition ID (`defid`), not just by word

## Output Format

Terms are saved as JSON with full metadata:

```json
[
  {
    "word": "yeet",
    "definition": "To throw something with force...",
    "example": "He yeeted the ball across the field",
    "thumbs_up": 15234,
    "thumbs_down": 1203,
    "author": "someuser123",
    "defid": 8496053,
    "permalink": "http://yeet.urbanup.com/8496053",
    "written_on": "2015-09-21T14:15:38.358Z"
  }
]
```

## Python Collector Architecture

```
src/
├── cli.py              # Entry point with signal handling
├── config.py           # Centralized configuration
├── domain/
│   └── models.py       # SlangTerm dataclass + validation
├── clients/
│   └── urban_api_client.py  # HTTP client with retry logic
├── repos/
│   └── json_repo.py    # Atomic JSON persistence
└── services/
    └── collector_service.py  # Collection orchestration
```

**Design Principles:**
- **SRP**: Each module has one responsibility
- **DRY**: Centralized config, validation in model
- **KISS**: No unnecessary abstractions
- **YAGNI**: Only features that are actually used

## iOS App Architecture

```
ios/
├── VwaApp.swift              # App entry point
├── Models/                   # Data models (SlangTerm, Category, Language, Theme)
├── ViewModels/               # State management (TermStore)
├── Views/                    # SwiftUI screens and components
├── Services/                 # Voice recognition and search
├── Theme/                    # Neo-brutalist design system
└── Resources/                # Bundled slang data (terms.json)
```

**Key Features:**
- Voice recognition for slang search
- Spanish/French translations
- Neo-brutalist design with dark/light themes
- Fuzzy search with phonetic matching
- iOS 15+ support

## Performance

- Rate limited to 1.5 requests/second (polite scraping)
- ~10 terms per API call (random endpoint)
- 1000 terms ≈ 3-5 minutes collection time

## Data Source

Uses the [Urban Dictionary public API](https://api.urbandictionary.com/v0/) which is undocumented but widely used. Key endpoints:

- `GET /random` - Random definitions (~10 per call)
- `GET /define?term={word}` - Search specific word

**Note**: This API is undocumented and could change. The code handles API errors gracefully with retries and checkpointing.

## Limitations

1. **Random-only collection**: No browse-by-letter endpoint exists in the official API
2. **~10 terms per request**: API returns limited batch sizes
3. **Duplicate words possible**: Same word can have many definitions (different `defid`)
4. **Content quality**: Urban Dictionary content is unfiltered user submissions

## Data Pipeline

The project uses a multi-step pipeline to go from raw data to the iOS app:

1. **Collect**: `python src/cli.py -n 1000` → `data/slang_terms.json`
2. **Curate**: Manually filter to real Gen Z slang (random UD terms vary in quality)
3. **Translate**: `python translate_terms.py` (uses Groq AI) → `data/curated_terms.json`
4. **Bundle**: Copy `curated_terms.json` → `ios/Resources/terms.json`
5. **Build**: Compile iOS app with bundled data

See `VWA_Swift_Implementation_Plan_v2.md` for detailed implementation guidance.

## License

MIT
