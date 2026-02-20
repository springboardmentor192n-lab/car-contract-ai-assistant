import re

def extract_vin(text):
    match = re.search(r"\b[A-HJ-NPR-Z0-9]{17}\b", text)
    return match.group(0) if match else None