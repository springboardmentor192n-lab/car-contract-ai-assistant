import asyncio

async def mock_llm_responder(user_message: str) -> str:
    """
    A mock function to simulate an LLM's response in a negotiation chat.
    """
    await asyncio.sleep(1) # Simulate network latency

    user_message = user_message.lower()

    if "hello" in user_message:
        return "Hello! I am your negotiation assistant. How can I help you with this contract?"
    elif "interest rate" in user_message or "apr" in user_message:
        return "The interest rate seems a bit high compared to market averages. I suggest we ask for a 0.5% reduction."
    elif "payment" in user_message or "monthly" in user_message:
        return "Based on the terms, the monthly payment is calculated correctly. However, with a lower interest rate, we could reduce this amount."
    elif "lower" in user_message or "reduce" in user_message:
        return "That's a good point. Let's draft a message to the dealer proposing a lower price based on our market data."
    elif "thanks" in user_message or "thank you" in user_message:
        return "You're welcome! Is there anything else I can assist you with?"
    else:
        return "I'm analyzing that. Can you give me a moment to review the contract details related to your question?"