import ollama

def contract_chatbot(contract_text, user_query):
    prompt = f"""
You are a car lease advisor.

Contract:
{contract_text}

User question:
{user_query}

Answer clearly and practically.
"""
    response = ollama.chat(
        model="gemma3:1b",
        messages=[{"role": "user", "content": prompt}]
    )

    return response["message"]["content"]