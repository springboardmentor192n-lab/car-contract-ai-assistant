
import random

class PriceEstimationService:
    def check_fair_price(self, make: str, model: str, year: int, quoted_price: float, mileage: int = 0) -> dict:
        """
        Simulates a market price check.
        In a real app, this would query a database like KBB or Edmunds API.
        Here we simulate based on base prices and depreciation.
        """
        
        # Base prices (simulated database)
        base_prices = {
            "Toyota": {"Camry": 28000, "Corolla": 22000, "RAV4": 30000},
            "Honda": {"Civic": 24000, "Accord": 29000, "CR-V": 31000},
            "Ford": {"F-150": 40000, "Mustang": 35000, "Explorer": 38000},
            "BMW": {"3 Series": 45000, "X5": 65000},
            "Tesla": {"Model 3": 40000, "Model Y": 48000}
        }
        
        base = 30000 # Default fallback
        if make in base_prices and model in base_prices[make]:
            base = base_prices[make][model]
            
        # Depreciation Logic (approx 15% per year)
        current_year = 2026 # From system time
        age = current_year - year
        
        depreciated_value = base * ((0.85) ** age)
        
        # Mileage adjustment (approx $0.10 per mile over expected 12k/year)
        # Assuming new car if mileage < 1000
        if mileage > 1000:
            expected_mileage = age * 12000
            excess_mileage = max(0, mileage - expected_mileage)
            depreciated_value -= (excess_mileage * 0.10)
            
        market_low = depreciated_value * 0.95
        market_high = depreciated_value * 1.05
        market_avg = depreciated_value
        
        overpriced_amount = max(0, quoted_price - market_high)
        
        verdict = "Fair Deal"
        if quoted_price < market_low:
            verdict = "Great Deal"
        elif quoted_price > market_high:
            verdict = "Overpriced"
            
        explanation = f"Market average for a {year} {make} {model} is around ${market_avg:,.2f}. "
        if verdict == "Overpriced":
            explanation += f"The quoted price is ${overpriced_amount:,.2f} higher than the estimated upper market range."
        else:
            explanation += "The quoted price falls within the fair market range."

        return {
            "estimated_fair_price_low": round(market_low, 2),
            "estimated_fair_price_high": round(market_high, 2),
            "market_average_price": round(market_avg, 2),
            "contract_price": quoted_price,
            "overpriced_amount": round(overpriced_amount, 2),
            "verdict": verdict,
            "explanation": explanation
        }

price_service = PriceEstimationService()
