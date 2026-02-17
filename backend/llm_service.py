import os
from dotenv import load_dotenv
from groq import AsyncGroq
import json

load_dotenv(override=True)

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
print(f"🔑 Loaded GROQ_API_KEY: {GROQ_API_KEY[:5]}...{GROQ_API_KEY[-5:] if GROQ_API_KEY else 'None'}")

if not GROQ_API_KEY:
    raise RuntimeError("❌ GROQ_API_KEY not found in .env")

client = AsyncGroq(api_key=GROQ_API_KEY)

async def generate_summary(clauses: dict) -> str:
    try:
        prompt = f"""
You are a car lease contract expert.

Given the following extracted contract clauses:
{clauses}

1. Give a simple summary
2. List red flags
3. Suggest negotiation tips

Respond in bullet points.
"""
        response = await client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": "You are a helpful legal assistant."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            max_tokens=600
        )
        return response.choices[0].message.content

    except Exception as e:
        return f"⚠️ LLM summary unavailable: {str(e)}"


async def negotiation_chat(clauses: dict, user_query: str) -> dict:
    try:
        prompt = f"""
You are an expert car lease negotiation assistant.
Your goal is to help the user save money and get fair terms.

Contract Clauses Context:
{json.dumps(clauses, indent=2)}

User Question:
"{user_query}"

Instructions:
1. Analyze the user's question in the context of the lease clauses.
2. Provide specific, actionable advice (bullet points preferred).
3. If the user asks for an email or if writing to the dealer is the best next step, provide a draft email. 
   - If no email is needed, set "email_draft" to null.

Output purely Valid JSON in this format:
{{
  "advice": "Here is what you should do:\\n- Point 1\\n- Point 2",
  "email_draft": {{
    "title": "Subject Line for Email",
    "body": "Hi [Dealer Name],\\n\\n..."
  }},
  "suggestions": ["Follow up question 1", "Follow up question 2"]
}}
"""
        response = await client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": "You are a JSON-speaking negotiation coach."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            max_tokens=600,
            response_format={"type": "json_object"}
        )
        
        content = response.choices[0].message.content
        return json.loads(content)

    except Exception as e:
        print(f"Negotiation error: {e}")
        return {
            "advice": f"⚠️ I encountered an error connecting to the AI brain. Please try again. (Error: {str(e)})",
            "email_draft": None,
            "suggestions": []
        }


async def extract_contract_details(clauses: dict) -> dict:
    try:
        prompt = f"""
You are a data extraction assistant.
Extract the following details from the car lease contract clauses below:
1. Interest Rate (APR/Money Factor) - return as number or null
2. Monthly Payment - return as number or null
3. Lease Term (months) - return as number or null
4. Mileage Limit (per year) - return as number or null

Clauses:
{clauses}

Output purely Valid JSON in this format:
{{
  "interest_rate": 4.5,       // or null if not found
  "monthly_payment": 549.00,  // or null
  "lease_term_months": 36,    // or null
  "mileage_limit_per_year": 12000 // or null
}}
"""
        response = await client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": "You are a JSON extraction engine."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.1, # Low temp for data extraction
            max_tokens=200,
            response_format={"type": "json_object"}
        )
        
        return json.loads(response.choices[0].message.content)

    except Exception as e:
        print(f"Extraction error: {e}")
        return {
            "interest_rate": None,
            "monthly_payment": None,
            "lease_term_months": None,
            "mileage_limit_per_year": None
        }
