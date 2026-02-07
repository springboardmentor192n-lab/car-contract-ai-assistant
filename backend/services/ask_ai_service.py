from fastapi import HTTPException
import google.generativeai as genai
import logging

from backend.models import schemas
from backend.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def ask_ai_service(request: schemas.AskAIRequest) -> str:
    logger.info(f"Received question for Ask AI service: {request.question}")
    gemini_api_key = settings.GEMINI_API_KEY
    if not gemini_api_key:
        raise HTTPException(status_code=500, detail="Gemini API key not configured")

    try:
        genai.configure(api_key=gemini_api_key)
        model = genai.GenerativeModel('gemini-1.5-flash')

        prompt = f"""
        You are an expert in auto finance contracts. A user has a question about their contract.
        Based ONLY on the contract text provided below, answer the user's question.
        If the answer is not in the text, say "The answer to your question is not found in the provided contract text."

        ---
        Contract Text:
        {request.context}
        ---

        User's Question:
        {request.question}
        ---

        Answer:
        """

        response = await model.generate_content_async(prompt)
        return response.text

    except Exception as e:
        logger.error(f"Gemini API Error: {e}")
        raise HTTPException(status_code=503, detail="Error communicating with the AI service.")