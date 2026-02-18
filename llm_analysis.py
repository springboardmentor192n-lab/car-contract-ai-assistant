import ollama

def analyze_with_llm(contract_text):
    if not contract_text:
        return "No text provided for analysis."

    prompt = f"""
    Analyze the following car lease contract text and extract the key terms:
    - Monthly Payment
    - Lease Term (months)
    - Down Payment / Initial Payment
    - Mileage Limit
    - Residual Value
    - Key Clauses (e.g., wear and tear, early termination)

    Contract Text:
    {contract_text}

    Format the output as a clear markdown summary.
    """

    try:
        response = ollama.chat(
            model="gemma3:1b",
            messages=[{"role": "user", "content": prompt}]
        )
        return response["message"]["content"]
    except Exception as e:
        return f"Error during AI analysis: {str(e)}\n\n**Note:** Please ensure Ollama is installed and running on your system. You can download it from [ollama.com](https://ollama.com/download)."
