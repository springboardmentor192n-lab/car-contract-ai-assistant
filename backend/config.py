import os
from pathlib import Path
from dotenv import load_dotenv

# --- Determine .env location ---
# First, check project root (E:\autofinance_guardian)
project_root_env = Path(__file__).resolve().parents[1] / ".env"
# Then, fallback to current folder (backend/)
backend_env = Path(__file__).parent / ".env"

# Load .env file from project root if exists, otherwise use backend folder
if project_root_env.exists():
    dotenv_path = project_root_env
elif backend_env.exists():
    dotenv_path = backend_env
else:
    dotenv_path = None

if dotenv_path:
    load_result = load_dotenv(dotenv_path)
    print(f"DEBUG: load_dotenv() loaded from {dotenv_path} -> {load_result}")
else:
    print("WARNING: No .env file found!")

# --- DEBUG: Check if keys are loaded ---
print(f"DEBUG: FRED_API_KEY = {os.getenv('FRED_API_KEY')}")
print(f"DEBUG: GEMINI_API_KEY = {os.getenv('GEMINI_API_KEY')}")

class Settings:
    FRED_API_KEY: str = os.getenv("FRED_API_KEY", "")
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "mysql+aiomysql://root:Deepali7019%40@localhost/autofinance_guardian"
    )
    SECRET_KEY: str = os.getenv("SECRET_KEY", "super-secret-key")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))

    def __init__(self):
        if not self.FRED_API_KEY:
            print("Warning: FRED_API_KEY is not set.")
        if not self.GEMINI_API_KEY:
            print("Warning: GEMINI_API_KEY is not set.")

settings = Settings()
