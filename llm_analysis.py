import ollama

def analyze_with_llm(contract_text):
    prompt = f"""
You are a legal assistant.

Analyze the following car lease agreement and extract:
1. Short summary
2. Lease duration
3. Monthly payment
4. Vehicle VIN
5. Any risky clauses
6. Also suggest which clauses can be negotiated and why.

Agreement text:
{contract_text}
"""
    response = ollama.chat(
        model="llama3",
        messages=[{"role": "user", "content": prompt}]
    )

    return response["message"]["content"]
