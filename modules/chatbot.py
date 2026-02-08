import google.generativeai as genai

def get_chatbot_response(user_input, contract_data, api_key):
    if not api_key:
        return "Missing API Key."

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-2.5-flash')
    
    total_cost = contract_data.get('total_cost', 'Unknown')
    score = contract_data.get('fairness_score', 'Unknown')
    monthly = contract_data.get('monthly_payment', 'Unknown')
    term = contract_data.get('lease_term', 'Unknown')
    upfront = contract_data.get('total_upfront', 'Unknown')
    flags = contract_data.get('red_flags', [])

    system_prompt = f"""
    You are a blunt, honest car contract expert. 
    
    SPECIFIC DATA FOR THIS DEAL:
    - Monthly Payment: ${monthly}
    - Term: {term}
    - Upfront Cost: ${upfront}
    - Total Contract Cost: ${total_cost}
    - Fairness Score: {score}/100
    - Red Flags found: {", ".join(flags)}

    STRICT RULES:
    1. Use the SPECIFIC DATA above to answer questions.
    2. If the user asks for total cost, state exactly ${total_cost}.
    3. DO NOT repeat the same sentence.
    4. DO NOT use ** inside sentences.
    5. Use plain text only.
    """

    config = {"temperature": 0}

    try:
        response = model.generate_content(
            f"{system_prompt}\n\nUser Question: {user_input}",
            generation_config=config
        )
        
        lines = response.text.split('.')
        unique_lines = []
        for line in lines:
            clean_line = line.strip()
            if clean_line and clean_line not in unique_lines:
                unique_lines.append(clean_line)
        
        return ". ".join(unique_lines).replace(".", ". ")
    except Exception as e:
        return f"Error: {str(e)}"