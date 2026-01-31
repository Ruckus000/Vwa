"""
Urban Dictionary API client.
Single responsibility: HTTP communication with the official API.

API Endpoints (unofficial but stable):
- GET /define?term={word} - Search for definitions
- GET /random - Get random definitions

Response format:
{
    "list": [
        {
            "word": "yolo",
            "definition": "you only live once",
            "example": "yolo!",
            "author": "username",
            "thumbs_up": 1234,
            "thumbs_down": 56,
            "defid": 8496053,
            "permalink": "http://yolo.urbanup.com/8496053",
            "written_on": "2015-09-21T14:15:38.358Z",
            "current_vote": ""
        }
    ]
}
"""
import time
import random
import logging
from typing import List, Dict, Any, Optional

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

from config import (
    API_BASE_URL,
    REQUEST_DELAY_SECONDS,
    REQUEST_TIMEOUT_SECONDS,
    MAX_RETRIES,
    RETRY_BACKOFF_BASE,
    USER_AGENT,
)


logger = logging.getLogger(__name__)


class APIError(Exception):
    """Raised when API request fails after all retries."""
    
    def __init__(self, message: str, status_code: Optional[int] = None):
        super().__init__(message)
        self.status_code = status_code


class RateLimitError(APIError):
    """Raised when API returns 429 Too Many Requests."""
    pass


class UrbanAPIClient:
    """
    Client for the Official Urban Dictionary API.
    
    Features:
    - Rate limiting between requests
    - Exponential backoff retry on failures
    - Proper User-Agent identification
    - Connection pooling via requests.Session
    """

    def __init__(
        self,
        base_url: str = API_BASE_URL,
        delay_seconds: float = REQUEST_DELAY_SECONDS,
        timeout_seconds: float = REQUEST_TIMEOUT_SECONDS,
        max_retries: int = MAX_RETRIES,
    ):
        self.base_url = base_url.rstrip("/")
        self.delay_seconds = delay_seconds
        self.timeout_seconds = timeout_seconds
        self.max_retries = max_retries
        self._last_request_time = 0.0
        
        # Configure session with retry adapter
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": USER_AGENT,
            "Accept": "application/json",
        })
        
        # Configure automatic retry for connection errors only
        # We handle HTTP errors manually for better control
        retry_strategy = Retry(
            total=2,
            backoff_factor=0.5,
            status_forcelist=[502, 503, 504],  # Gateway errors only
            allowed_methods=["GET"],
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("https://", adapter)
        self.session.mount("http://", adapter)

    def _rate_limit(self) -> None:
        """Enforce delay between requests to be polite."""
        elapsed = time.time() - self._last_request_time
        if elapsed < self.delay_seconds:
            sleep_time = self.delay_seconds - elapsed
            # Add small jitter to avoid thundering herd
            sleep_time += random.uniform(0, 0.1)
            logger.debug(f"Rate limiting: sleeping {sleep_time:.2f}s")
            time.sleep(sleep_time)
        self._last_request_time = time.time()

    def _get_with_retry(self, url: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """
        Make GET request with exponential backoff retry.
        
        Retry strategy:
        - Attempt 1: immediate
        - Attempt 2: wait 2s + jitter
        - Attempt 3: wait 4s + jitter
        
        Raises APIError after all retries exhausted.
        """
        last_error: Optional[Exception] = None
        response = None  # Initialize to avoid UnboundLocalError
        
        for attempt in range(self.max_retries):
            try:
                self._rate_limit()
                
                logger.debug(f"GET {url} params={params} (attempt {attempt + 1}/{self.max_retries})")
                
                response = self.session.get(
                    url,
                    params=params,
                    timeout=self.timeout_seconds,
                )
                
                # Handle specific HTTP errors
                if response.status_code == 429:
                    raise RateLimitError(
                        "Rate limited by API. Consider increasing delay.",
                        status_code=429
                    )
                
                if response.status_code == 404:
                    # Not found is not retryable - return empty result
                    logger.debug(f"404 Not Found for {url}")
                    return {"list": []}
                
                response.raise_for_status()
                
                data = response.json()
                
                # Validate response structure
                if not isinstance(data, dict):
                    raise APIError(f"Unexpected response type: {type(data)}")
                
                return data
                
            except RateLimitError:
                # Don't retry rate limits - fail fast and let caller handle
                raise
                
            except requests.exceptions.Timeout as e:
                last_error = APIError(f"Request timed out after {self.timeout_seconds}s: {e}")
                logger.warning(f"Timeout on attempt {attempt + 1}: {e}")
                
            except requests.exceptions.ConnectionError as e:
                last_error = APIError(f"Connection error: {e}")
                logger.warning(f"Connection error on attempt {attempt + 1}: {e}")
                
            except requests.exceptions.HTTPError as e:
                status = response.status_code if response is not None else None
                last_error = APIError(
                    f"HTTP error {status}: {e}",
                    status_code=status
                )
                logger.warning(f"HTTP error on attempt {attempt + 1}: {e}")
                
            except ValueError as e:
                last_error = APIError(f"Invalid JSON response: {e}")
                logger.warning(f"JSON parse error on attempt {attempt + 1}: {e}")
            
            # Exponential backoff before retry (skip on last attempt)
            if attempt < self.max_retries - 1:
                backoff = (RETRY_BACKOFF_BASE ** attempt) + random.uniform(0, 1)
                logger.info(f"Retrying in {backoff:.1f}s...")
                time.sleep(backoff)
        
        # All retries exhausted
        raise last_error or APIError("Request failed after all retries")

    def define(self, term: str) -> List[Dict[str, Any]]:
        """
        Search for a specific term.
        
        Args:
            term: Word or phrase to search for
            
        Returns:
            List of definition dictionaries (up to ~10)
        """
        if not term or not term.strip():
            return []
            
        url = f"{self.base_url}/define"
        result = self._get_with_retry(url, {"term": term.strip()})
        return result.get("list", [])

    def random(self) -> List[Dict[str, Any]]:
        """
        Get random definitions.
        
        Returns:
            List of ~10 random definition dictionaries
        """
        url = f"{self.base_url}/random"
        result = self._get_with_retry(url, {})
        return result.get("list", [])

    def close(self) -> None:
        """Close the session and release resources."""
        self.session.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
