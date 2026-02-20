from openai import OpenAI
import os

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def analyze_with_llm(contract_text):

    contract_text = contract_text[:4000]

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
        model="gpt-4o-mini",
        messages=[
            {"role": "user", "content": prompt}
        ],
        max_tokens=500
    )

    return response.choices[0].message.content