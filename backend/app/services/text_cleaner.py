def clean_text(text: str) -> str:
    """
    Clean and normalize text extracted from documents.
    """
    if not text:
        return ""

    # Remove extra whitespace
    cleaned = " ".join(text.split())

    # Remove non-printable characters
    cleaned = ''.join(c for c in cleaned if c.isprintable())

    return cleaned
