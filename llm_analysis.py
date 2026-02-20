from groq import Groq
import os

api_key = os.getenv("GROQ_API_KEY")

if not api_key:
    raise ValueError("GROQ_API_KEY is not set in environment")

client = Groq(api_key=api_key)

def analyze_with_llm(contract_text):

    contract_text = contract_text[:3000]

    prompt = f"""
You are a legal AI assistant specializing in car lease agreements.

Analyze the following contract and provide:

1. A short summary
2. Key risks or problematic clauses
3. Important financial terms
4. Negotiation suggestions

Contract:
{contract_text}
"""

    response = client.chat.completions.create(
    model="llama-3.1-8b-instant",
        messages=[
            {"role": "user", "content": prompt}
        ],
        max_tokens=600,
    )

    return response.choices[0].message.content