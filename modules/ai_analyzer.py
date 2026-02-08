import json
from google import genai

def analyze_with_gemini(text, api_key):
    if not api_key:
        return {"error": "No API Key found"}
        
    client = genai.Client(api_key=api_key)
    model_name = "gemini-2.5-flash" 
    
    prompt = f"""
    Return ONLY a JSON object. No conversational text.
    Extract: brand, model, variant, year, vin, monthly_payment, lease_term, total_upfront, apr, red_flags (list), mileage_limit.
    Note: Keep currency symbols ($, ₹) if found.
    
    Contract Text:
    {text[:8000]}
    """
    
    try:
        response = client.models.generate_content(model=model_name, contents=prompt)
        res_text = response.text.strip()
        
        # Robust JSON cleaning
        if "```json" in res_text:
            res_text = res_text.split("```json")[-1].split("```")[0].strip()
        elif "```" in res_text:
            res_text = res_text.split("```")[-1].split("```")[0].strip()
            
        return json.loads(res_text)
    except Exception as e:
        return {
            "vin": "ERROR", "brand": "N/A", "model": "N/A", "year": "N/A",
            "monthly_payment": "N/A", "apr": "N/A", "lease_term": "N/A", "total_upfront": "N/A",
            "red_flags": [f"API Error: {str(e)}"], "mileage_limit": "N/A"
        }
