
import json
import os
from openai import OpenAI
from groq import Groq
from config import settings
from schemas import ExtractedSLABase

class LLMExtractionService:
    def __init__(self):
        self.openai_client = OpenAI(api_key=settings.OPENAI_API_KEY) if settings.OPENAI_API_KEY else None
        self.groq_client = Groq(api_key=settings.GROQ_API_KEY) if settings.GROQ_API_KEY else None
        
        self.system_prompt = """
        You are a consumer protection assistant specialized in analyzing car loan and lease agreements.
        Your job is to explain contracts in very simple language.

        You must:
        1. Summarize the contract in plain English.
        2. Extract important financial terms.
        3. Identify risky clauses.
        4. Detect hidden charges.
        5. Explain penalties and obligations.
        6. Suggest negotiation points.
        7. Give practical advice before signing.
        8. Respond in a structured JSON format.

        Be clear, user-friendly, and non-legalistic.
        Assume the user has no legal knowledge.

        Return JSON in this exact format:
        {
          "summary": "Plain English summary",
          "important_terms": ["Term 1", "Term 2","Term 3"],
          "risky_clauses": ["Clause 1", "Clause 2","Clause 3"],
          "hidden_charges": [{"name": "Charge", "amount": 100, "description": "why"}],
          "penalties": ["Penalty 1", "Penalty 2"],
          "negotiation_points": ["Point 1", "Point 2"],
          "final_advice": "Final advice for the user"
        }
        """

    def log_debug(self, msg):
        with open("debug_llm.log", "a", encoding='utf-8') as f:
             from datetime import datetime
             f.write(f"[{datetime.now()}] {msg}\n")

    async def extract_data(self, contract_text: str) -> dict:
        self.log_debug(f"Received text length: {len(contract_text)}")
        # Truncate text if too long (simple heuristic)
        if len(contract_text) > 100000:
            contract_text = contract_text[:100000]

        prompt = f"Extract data from this contract:\n\n{contract_text}"

        try:
            # Prefer Groq for speed if available, else OpenAI
            if self.groq_client:
                print(f"Using Groq LLM to extract data from {len(contract_text)} chars...")
                completion = self.groq_client.chat.completions.create(
                    model="llama-3.3-70b-versatile", # Updated for stability
                    messages=[
                        {"role": "system", "content": self.system_prompt},
                        {"role": "user", "content": prompt}
                    ],
                    temperature=0.1,
                    response_format={"type": "json_object"}
                )
                result = completion.choices[0].message.content
                print(f"Groq Result Received: {len(result)} chars")
            elif self.openai_client:
                completion = self.openai_client.chat.completions.create(
                    model="gpt-4-turbo-preview",
                    messages=[
                        {"role": "system", "content": self.system_prompt},
                        {"role": "user", "content": prompt}
                    ],
                    temperature=0.1,
                    response_format={"type": "json_object"}
                )
                result = completion.choices[0].message.content
            else:
                return {"error": "No LLM API keys configured"}

            return json.loads(result)
        
        except Exception as e:
            print(f"LLM Extraction Error: {e}")
            return {"error": str(e)}

llm_service = LLMExtractionService()
