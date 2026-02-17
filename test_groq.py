import os
from groq import Groq
from dotenv import load_dotenv

# Force reload to be sure
load_dotenv(override=True)

key = os.getenv("GROQ_API_KEY")
# Print first/last few chars to verify without exposing full key if shared (though safely local here)
visible_key = f"{key[:5]}...{key[-5:]}" if key and len(key) > 10 else key
print(f"Key loaded: '{visible_key}' (Length: {len(key) if key else 0})")

if not key:
    print("❌ No key found in environment.")
    exit(1)

client = Groq(api_key=key)

try:
    print("Attempting connection to Groq...")
    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "user", "content": "Hello"}],
        max_tokens=10
    )
    print("✅ Success! API Key is valid.")
    print("Response:", response.choices[0].message.content)
except Exception as e:
    print(f"❌ Error: {e}")
