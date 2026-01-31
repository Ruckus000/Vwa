"""
JSON file repository.
Single responsibility: read/write slang terms to JSON files with atomic operations.
"""
import json
import os
import tempfile
import logging
from pathlib import Path
from typing import List, Set

from domain.models import SlangTerm


logger = logging.getLogger(__name__)


class JsonRepo:
    """
    Persists SlangTerms to JSON files with atomic write operations.
    
    Atomic writes prevent data corruption if the process is interrupted
    mid-write (Ctrl+C, crash, power loss, etc.).
    
    Strategy:
    1. Write to temporary file in same directory
    2. Flush and sync to disk
    3. Atomic rename to target path
    """

    def __init__(self, filepath: Path):
        self.filepath = Path(filepath)

    def save(self, terms: List[SlangTerm]) -> None:
        """
        Atomically save terms to JSON file.
        
        Creates parent directories if needed.
        Uses temp file + rename to prevent corruption.
        """
        self.filepath.parent.mkdir(parents=True, exist_ok=True)
        
        data = [term.to_dict() for term in terms]
        
        # Write to temp file first
        fd, temp_path = tempfile.mkstemp(
            suffix=".json.tmp",
            dir=self.filepath.parent,
        )
        
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                f.flush()
                os.fsync(f.fileno())  # Ensure data hits disk
            
            # Atomic rename (on POSIX systems)
            os.replace(temp_path, self.filepath)
            
            logger.info(f"Saved {len(terms)} terms to {self.filepath}")
            
        except Exception:
            # Clean up temp file on failure
            if os.path.exists(temp_path):
                os.unlink(temp_path)
            raise

    def load(self) -> List[SlangTerm]:
        """
        Load terms from JSON file.
        
        Returns empty list if file doesn't exist.
        Logs warning for malformed entries but continues loading valid ones.
        """
        if not self.filepath.exists():
            logger.info(f"No existing data at {self.filepath}")
            return []
        
        try:
            with open(self.filepath, "r", encoding="utf-8") as f:
                data = json.load(f)
        except json.JSONDecodeError as e:
            logger.error(f"Corrupt JSON file {self.filepath}: {e}")
            return []
        
        if not isinstance(data, list):
            logger.error(f"Invalid data format in {self.filepath}: expected list")
            return []
        
        terms = []
        for i, item in enumerate(data):
            try:
                term = SlangTerm.from_dict(item)
                terms.append(term)
            except Exception as e:
                logger.warning(f"Skipping malformed entry at index {i}: {e}")
                continue
        
        logger.info(f"Loaded {len(terms)} terms from {self.filepath}")
        return terms

    def load_defids(self) -> Set[int]:
        """
        Load just the defids for fast duplicate checking.
        
        More memory-efficient than loading full terms when we just
        need to check for duplicates.
        """
        if not self.filepath.exists():
            return set()
        
        try:
            with open(self.filepath, "r", encoding="utf-8") as f:
                data = json.load(f)
        except (json.JSONDecodeError, IOError):
            return set()
        
        defids = set()
        for item in data:
            if isinstance(item, dict) and "defid" in item:
                try:
                    defids.add(int(item["defid"]))
                except (ValueError, TypeError):
                    continue
        
        return defids

    def exists(self) -> bool:
        """Check if the data file exists."""
        return self.filepath.exists()

    def count(self) -> int:
        """Get count of terms without loading all data into memory."""
        if not self.filepath.exists():
            return 0
        
        try:
            with open(self.filepath, "r", encoding="utf-8") as f:
                data = json.load(f)
            return len(data) if isinstance(data, list) else 0
        except (json.JSONDecodeError, IOError):
            return 0
