from groq import Groq
import os

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def contract_chatbot(contract_text, user_query):

    contract_text = contract_text[:3000]

    prompt = f"""
You are a car lease advisor.

Contract:
{contract_text}

User question:
{user_query}

Answer clearly and practically.
"""

    response = client.chat.completions.create(
    model="llama-3.1-8b-instant",
        messages=[
            {"role": "user", "content": prompt}
        ],
        max_tokens=400,
    )

    return response.choices[0].message.content