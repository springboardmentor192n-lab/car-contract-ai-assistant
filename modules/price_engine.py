import re

def get_market_value(year, brand, model):
    """Simple benchmark pricing for prototype purposes."""
    # Base prices for brands (approximate for 2026 market)
    brand_values = {
        "TOYOTA": 22000, "HONDA": 21000, "FORD": 18000, 
        "CHEVROLET": 17500, "BMW": 35000, "MERCEDES": 38000
    }
    
    current_year = 2026
    try:
        clean_year = re.sub(r'\D', '', str(year))
        vehicle_year = int(clean_year) if clean_year else 2021
    except:
        vehicle_year = 2021 
        
    age = current_year - vehicle_year
    
    base = brand_values.get(str(brand).upper(), 20000)
    
    market_value = base * (0.9 ** age)
    return round(market_value, 2)

def calculate_fairness_score(extracted_data, market_value):
    """Calculates a 0-100 score based on price, interest, and legal risk."""
    score = 100
    
    def to_float(s):
        if s is None or s == "N/A": return 0.0
        try:
            clean = re.sub(r'[^\d.]', '', str(s))
            return float(clean) if clean else 0.0
        except:
            return 0.0

    monthly = to_float(extracted_data.get('monthly_payment', 0))
    term = to_float(extracted_data.get('lease_term'))
    if term == 0: term = 36.0
    
    upfront = to_float(extracted_data.get('total_upfront', 0))

    total_cost = (monthly * term) + upfront
    
    if total_cost > (market_value * 2.0):
        score -= 40  # Extreme overpayment
    elif total_cost > (market_value * 1.5):
        score -= 25  # Significant markup
    elif total_cost > (market_value * 1.2):
        score -= 10  # Moderate markup
        
    apr_val = to_float(extracted_data.get('apr', 0))
    if apr_val > 18:
        score -= 25
    elif apr_val > 10:
        score -= 15
    elif apr_val == 0:
        score -= 5 
        
    flags = extracted_data.get('red_flags', [])
    flag_penalty = len(flags) * 4
    score -= min(45, flag_penalty) 
    
    return max(5, min(100, score))