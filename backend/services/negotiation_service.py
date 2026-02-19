
from openai import OpenAI
from groq import Groq
from config import settings
from schemas import ExtractedSLA

class NegotiationService:
    def __init__(self):
        self.openai_client = OpenAI(api_key=settings.OPENAI_API_KEY) if settings.OPENAI_API_KEY else None
        self.groq_client = Groq(api_key=settings.GROQ_API_KEY) if settings.GROQ_API_KEY else None

    async def generate_response(self, contract_context: dict, chat_history: list, user_message: str):
        
        system_prompt = f"""
        You are an expert car negotiation assistant.
        Your goal is to help the user get a better deal on their car contract.
        
        CONTEXT FROM CONTRACT:
        {contract_context}
        
        GUIDELINES:
        1. Speak in simple, non-legal English.
        2. Be firm but polite in negotiation tactics.
        3. Explain WHY a term is bad before suggesting a change.
        4. If the user asks for an email draft, write a professional email to the dealer.
        5. Suggest 3 specific follow-up questions the user should ask the dealer.
        
        OUTPUT FORMAT:
        Return a JSON object with:
        - "response": The chat response to the user.
        - "suggested_questions": A list of 3 questions to ask the dealer.
        - "dealer_email_draft": (Optional) A draft email if relevant, else null.
        """
        
        messages = [{"role": "system", "content": system_prompt}]
        
        # Append history (limited to last 5 turns to save context)
        for msg in chat_history[-5:]:
            messages.append({"role": "user" if msg['sender'] == 'user' else "assistant", "content": msg['content']})
            
        messages.append({"role": "user", "content": user_message})

        try:
             # Prefer Groq
            if self.groq_client:
                 completion = self.groq_client.chat.completions.create(
                    model="llama-3.3-70b-versatile",
                    messages=messages,
                    temperature=0.3,
                    response_format={"type": "json_object"}
                )
                 import json
                 return json.loads(completion.choices[0].message.content)
            elif self.openai_client:
                 completion = self.openai_client.chat.completions.create(
                    model="gpt-4-turbo-preview",
                    messages=messages,
                    temperature=0.3,
                    response_format={"type": "json_object"}
                )
                 import json
                 return json.loads(completion.choices[0].message.content)
            else:
                 return {
                     "response": "I cannot analyze this right now as the AI service is not configured.",
                     "suggested_questions": [],
                     "dealer_email_draft": None
                 }
        except Exception as e:
            import traceback
            from datetime import datetime
            error_msg = f"Negotiation Chat Error: {str(e)}\n{traceback.format_exc()}"
            print(error_msg)
            with open("backend_errors.log", "a") as f:
                f.write(f"[{datetime.now()}] {error_msg}\n")
            
            return {
                     "response": f"I encountered an error processing your request. (Debug: {str(e)})",
                     "suggested_questions": [],
                     "dealer_email_draft": None
                 }

negotiation_service = NegotiationService()
