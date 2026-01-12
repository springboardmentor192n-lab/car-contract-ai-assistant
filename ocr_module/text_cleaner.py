import re

def clean_text(text):
    """
    Cleans extracted text by removing extra spaces,
    line breaks, and unwanted characters.
    """
    if not text:
        return ""

    # Remove multiple spaces and newlines
    text = re.sub(r'\s+', ' ', text)

    # Remove common page markers
    text = re.sub(r'Page\s+\d+', '', text, flags=re.IGNORECASE)

    return text.strip()
