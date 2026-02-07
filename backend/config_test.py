import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Print the keys to see if Python can read them
print("FRED_API_KEY =", os.getenv("FRED_API_KEY"))
print("GEMINI_API_KEY =", os.getenv("GEMINI_API_KEY"))
