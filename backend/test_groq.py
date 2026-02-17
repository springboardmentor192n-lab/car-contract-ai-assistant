from dotenv import load_dotenv
import os
from groq import Groq

# Load .env from project root
load_dotenv()

print("KEY LOADED:", os.getenv("GROQ_API_KEY"))

client = Groq()

response = client.chat.completions.create(
    model="llama3-8b-8192",
    messages=[
        {"role": "user", "content": "Say hello in one line"}
    ]
)

print("LLM RESPONSE:")
print(response.choices[0].message.content)


