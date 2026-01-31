"""
Domain models for slang terms.
Pure data structures with no I/O or framework dependencies.
"""
from dataclasses import dataclass
from typing import Optional


@dataclass
class SlangTerm:
    """
    Represents a single slang definition.
    
    Note: A single word can have MANY definitions (different defid values).
    We deduplicate by defid, not by word, to preserve all unique definitions.
    """
    
    word: str
    definition: str
    example: Optional[str]
    thumbs_up: int
    thumbs_down: int
    author: str
    defid: int  # Unique identifier - this is what we dedupe on
    permalink: Optional[str] = None
    written_on: Optional[str] = None  # ISO timestamp from API

    @property
    def score(self) -> float:
        """Quality score based on vote ratio (0.0 to 1.0)."""
        total = self.thumbs_up + self.thumbs_down
        if total == 0:
            return 0.5  # Neutral for no votes, not 0
        return self.thumbs_up / total

    @property
    def popularity(self) -> int:
        """Total engagement (sum of all votes)."""
        return self.thumbs_up + self.thumbs_down

    def __hash__(self):
        # Hash by defid - the unique definition identifier
        return hash(self.defid)

    def __eq__(self, other):
        if not isinstance(other, SlangTerm):
            return False
        # Two terms are equal if they have the same definition ID
        return self.defid == other.defid

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "word": self.word,
            "definition": self.definition,
            "example": self.example,
            "thumbs_up": self.thumbs_up,
            "thumbs_down": self.thumbs_down,
            "author": self.author,
            "defid": self.defid,
            "permalink": self.permalink,
            "written_on": self.written_on,
        }

    @classmethod
    def from_dict(cls, data: dict) -> "SlangTerm":
        """Create from dictionary (for loading from JSON)."""
        return cls(
            word=data.get("word", ""),
            definition=data.get("definition", ""),
            example=data.get("example"),
            thumbs_up=data.get("thumbs_up", 0),
            thumbs_down=data.get("thumbs_down", 0),
            author=data.get("author", ""),
            defid=data.get("defid", 0),
            permalink=data.get("permalink"),
            written_on=data.get("written_on"),
        )

    @classmethod
    def from_api_response(cls, data: dict) -> Optional["SlangTerm"]:
        """
        Parse from Urban Dictionary API response.
        
        Returns None if required fields are missing or invalid.
        """
        try:
            word = data.get("word", "").strip()
            definition = data.get("definition", "").strip()
            defid = data.get("defid")
            
            # Validate required fields
            if not word or not definition or defid is None:
                return None
            
            # Basic content validation
            if len(word) < 1 or len(definition) < 5:
                return None
            
            return cls(
                word=word,
                definition=definition,
                example=data.get("example", "").strip() if data.get("example") else None,
                thumbs_up=int(data.get("thumbs_up", 0) or 0),
                thumbs_down=int(data.get("thumbs_down", 0) or 0),
                author=data.get("author", "").strip() if data.get("author") else "",
                defid=int(defid),
                permalink=data.get("permalink"),
                written_on=data.get("written_on"),
            )
        except (ValueError, TypeError, AttributeError):
            return None
