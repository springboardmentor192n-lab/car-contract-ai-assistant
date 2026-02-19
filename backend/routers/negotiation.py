
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import models, schemas, database
from routers.auth import get_current_user
from services.negotiation_service import negotiation_service

router = APIRouter(prefix="/negotiation", tags=["Negotiation"])

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/chat", response_model=schemas.NegotiationChatResponse)
async def chat_negotiation(
    request: schemas.NegotiationChatRequest,
    db: Session = Depends(get_db)
):
    contract = db.query(models.Contract).filter(models.Contract.id == request.contract_id).first()
    if not contract:
        raise HTTPException(status_code=404, detail="Contract not found")
        
    if not contract.sla:
         raise HTTPException(status_code=400, detail="Contract analysis not yet complete.")

    # Find or create thread
    thread = db.query(models.NegotiationThread).filter(models.NegotiationThread.contract_id == request.contract_id).first()
    if not thread:
        thread = models.NegotiationThread(contract_id=request.contract_id)
        db.add(thread)
        db.commit()
        db.refresh(thread)
    
    # Save User Message
    user_msg = models.NegotiationMessage(
        thread_id=thread.id,
        sender="user",
        content=request.user_message
    )
    db.add(user_msg)
    db.commit()
    
    # Get Context
    chat_history = []
    previous_msgs = db.query(models.NegotiationMessage).filter(models.NegotiationMessage.thread_id == thread.id).order_by(models.NegotiationMessage.timestamp).all()
    for msg in previous_msgs:
        chat_history.append({"sender": msg.sender, "content": msg.content})
        
    contract_context = {
        "sla": {k: v for k, v in contract.sla.__dict__.items() if not k.startswith('_')},
        "fairness": {k: v for k, v in contract.fairness_score.__dict__.items() if not k.startswith('_')} if contract.fairness_score else {},
        "price": {k: v for k, v in contract.price_analysis.__dict__.items() if not k.startswith('_')} if contract.price_analysis else {}
    }
    
    # Generate Bot Response
    result = await negotiation_service.generate_response(contract_context, chat_history, request.user_message)
    
    # Save Bot Message
    bot_msg = models.NegotiationMessage(
        thread_id=thread.id,
        sender="bot",
        content=result.get("response", "Error generating response"),
        metadata_json={
            "suggested_questions": result.get("suggested_questions"),
            "dealer_email_draft": result.get("dealer_email_draft")
        }
    )
    db.add(bot_msg)
    db.commit()
    
    return {
        "response": bot_msg.content,
        "suggested_questions": result.get("suggested_questions", []),
        "dealer_email_draft": result.get("dealer_email_draft")
    }
