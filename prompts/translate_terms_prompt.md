# Gen Z Slang Translation Prompt

Copy this entire prompt and paste it into Claude. It will output a JSON file ready to use.

---

You are creating a slang dictionary for Spanish and French speakers learning to understand American Gen Z slang. For each term below, provide:

1. A clear English definition (what it means, not literal)
2. An example sentence showing natural usage
3. A Spanish explanation (NOT literal translation - explain the meaning and when it's used)
4. A Spanish example that conveys the same sentiment naturally
5. A French explanation (NOT literal translation - explain the meaning and when it's used)
6. A French example that conveys the same sentiment naturally
7. A category from: AGREEMENT, CRITICISM, DEGREE, EMOTION, PRAISE, QUALITY, TRUTH, OTHER

**Terms to translate:**

```
no cap, lowkey, highkey, bet, slay, bussin, mid, sus, fire, goated,
fr fr, on god, deadass, salty, pressed, finna, periodt, slaps,
hits different, main character, ate, understood the assignment,
rent free, its giving, say less, valid, vibes, caught in 4k, stan,
simp, pick me, based, cringe, W, L, ratio, ong, ngl, iykyk, rizz,
delulu, snatched, tea, ick, sending me, unalive, cheugy, yeet
```

**Output format - respond with ONLY this JSON array, no other text:**

```json
[
  {
    "id": 1,
    "term": "no cap",
    "category": "TRUTH",
    "definition": "For real, no lie, I'm being completely serious",
    "example": "That concert was amazing, no cap",
    "translations": {
      "ES": {
        "definition": "Expresión que significa 'en serio' o 'sin mentir'. Se usa para enfatizar que algo es completamente verdad y no estás exagerando.",
        "example": "Ese concierto estuvo increíble, en serio"
      },
      "FR": {
        "definition": "Expression signifiant 'sérieusement' ou 'sans mentir'. Utilisée pour souligner que quelque chose est absolument vrai et qu'on n'exagère pas.",
        "example": "Ce concert était incroyable, sans mentir"
      }
    },
    "meta": {
      "thumbsUp": 0,
      "thumbsDown": 0,
      "author": "claude",
      "addedOn": "2025-01-30"
    }
  }
]
```

**Important guidelines:**
- Spanish/French explanations should help someone UNDERSTAND when and how to use the term
- Don't translate literally - explain the vibe/feeling/context
- Examples should sound natural in the target language, not word-for-word translations
- Include nuance: is it playful? serious? sarcastic? used with friends only?
- Category should reflect the primary usage

Generate the complete JSON for all 50 terms. Start with `[` and end with `]`.
