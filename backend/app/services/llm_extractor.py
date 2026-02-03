# backend/app/services/llm_extractor.py
import os
from typing import Dict
import json
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import OpenAI



class SimpleLLMExtractor:
    def __init__(self, api_key: str = None):
        if not api_key:
            api_key = os.getenv("OPENAI_API_KEY", "your-key-here")

        self.llm = OpenAI(
            openai_api_key=api_key,
            temperature=0,
            max_tokens=500
        )

    def extract_contract_details(self, text: str) -> Dict:
        """Extract contract details using LLM"""

        prompt = PromptTemplate(
            input_variables=["contract_text"],
            template="""
            Extract these key details from the car contract:

            Contract:
            {contract_text}

            Extract as JSON with these keys:
            1. interest_rate (as percentage)
            2. monthly_payment (as number)
            3. lease_term_months (as number)
            4. down_payment (as number)
            5. total_amount (as number)
            6. mileage_limit_per_year (as number)
            7. excess_mileage_charge (as per mile)
            8. early_termination_fee (as number)
            9. late_payment_fee (as number)
            10. security_deposit (as number)

            Return only JSON, no other text.
            """
        )

        chain = prompt | self.llm | StrOutputParser()

        # Limit text for token constraints
        limited_text = text[:3000]

        try:
            result = chain.invoke({"contract_text": limited_text})

            # Try to parse JSON
            try:
                parsed = json.loads(result.strip())
                return {
                    "success": True,
                    "data": parsed,
                    "raw": result
                }
            except json.JSONDecodeError:
                return {
                    "success": False,
                    "data": {},
                    "raw": result,
                    "error": "Failed to parse JSON"
                }

        except Exception as e:
            return {
                "success": False,
                "data": {},
                "error": str(e)
            }


# For testing without API key
class MockLLMExtractor:
    def extract_contract_details(self, text: str) -> Dict:
        """Mock extractor for testing"""
        return {
            "success": True,
            "data": {
                "interest_rate": "5.9%",
                "monthly_payment": 450,
                "lease_term_months": 36,
                "down_payment": 2500,
                "mileage_limit_per_year": 12000,
                "excess_mileage_charge": 0.25,
                "late_payment_fee": 35
            },
            "raw": "Mock response"
        }