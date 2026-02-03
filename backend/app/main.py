# backend/app/main.py - UPDATED VERSION
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import PyPDF2
import io
import re

app = FastAPI(title="Car Contract AI Assistant")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simple in-memory storage
contracts_db = {}
next_id = 1


@app.get("/")
def root():
    return {"message": "Car Contract AI Assistant API - Running!"}


@app.post("/api/contracts/upload")
async def upload_contract(file: UploadFile = File(...)):
    """Enhanced upload endpoint with real parsing"""
    if not file.filename:
        raise HTTPException(400, "No file provided")

    try:
        # Read file
        contents = await file.read()

        # Extract text based on file type
        file_ext = file.filename.split('.')[-1].lower()
        text = ""

        if file_ext == 'pdf':
            text = extract_text_from_pdf(contents)
        elif file_ext == 'txt':
            text = contents.decode('utf-8', errors='ignore')
        else:
            text = f"File type {file_ext} - text extraction not implemented"

        # Extract contract details
        extracted_details = extract_contract_details(text)

        # Calculate better risk score
        risk_score = 50  # Base

        # Check interest rate
        if "interest_rate" in extracted_details:
            rate_str = extracted_details["interest_rate"].replace('%', '')
            try:
                rate = float(rate_str)
                if rate > 8:
                    risk_score += 30
                elif rate > 6:
                    risk_score += 15
                elif rate < 4:
                    risk_score -= 10
            except:
                pass

        # Check monthly payment (simple heuristic)
        if "monthly_payment" in extracted_details:
            payment_str = extracted_details["monthly_payment"].replace('$', '').replace(',', '')
            try:
                payment = float(payment_str)
                if payment > 600:
                    risk_score += 10
                elif payment > 400:
                    risk_score += 5
            except:
                pass

        # Check mileage
        if "mileage" in extracted_details:
            mileage_str = extracted_details["mileage"].replace(',', '')
            try:
                mileage = int(mileage_str)
                if mileage < 10000:
                    risk_score += 10  # Low mileage limit
            except:
                pass

        # Ensure score is 0-100
        risk_score = max(0, min(100, risk_score))
        risk_level = "high" if risk_score > 70 else "medium" if risk_score > 40 else "low"

        # Store in memory
        global next_id
        contract_id = next_id
        next_id += 1

        contracts_db[contract_id] = {
            "id": contract_id,
            "filename": file.filename,
            "file_type": file_ext,
            "size": len(contents),
            "extracted_text": text[:3000],
            "extracted_details": extracted_details,
            "risk_score": risk_score,
            "risk_level": risk_level,
            "upload_time": "2024-01-30"  # Add timestamp
        }

        # Generate recommendations
        recommendations = []
        if "interest_rate" in extracted_details:
            rate_str = extracted_details["interest_rate"].replace('%', '')
            try:
                rate = float(rate_str)
                if rate > 6:
                    recommendations.append(f"Consider negotiating interest rate from {rate}% to 4-5%")
            except:
                pass

        if len(recommendations) < 3:
            recommendations.extend([
                "Review all fees and charges",
                "Verify mileage limits match your needs",
                "Check early termination conditions"
            ])

        return {
            "success": True,
            "contract_id": contract_id,
            "filename": file.filename,
            "file_type": file_ext,
            "file_size": len(contents),
            "risk_score": risk_score,
            "risk_level": risk_level,
            "extracted_text": text[:1000],  # First 1000 chars
            "extracted_details": extracted_details,
            "recommendations": recommendations[:5],
            "analysis": {
                "total_pages": text.count('\n') // 50 + 1 if text else 0,
                "keywords_found": len(extracted_details),
                "confidence": "medium"
            },
            "message": f"Analysis complete. Found {len(extracted_details)} key terms."
        }

    except Exception as e:
        raise HTTPException(500, f"Upload failed: {str(e)}")


@app.get("/api/vin/decode/{vin}")
async def decode_vin(vin: str, use_mock: bool = True):
    """Simple VIN endpoint"""
    if use_mock:
        return {
            "valid": True,
            "vin": vin,
            "make": "Toyota",
            "model": "Camry",
            "year": "2023",
            "body_type": "Sedan",
            "engine": "2.5L 4-cylinder",
            "recalls": {
                "count": 2,
                "recalls": [
                    {"description": "Software update required", "date": "2023-05-15"},
                    {"description": "Airbag sensor check", "date": "2023-08-22"}
                ]
            },
            "source": "Mock Data"
        }
    else:
        return {
            "valid": False,
            "error": "Real API not configured. Use mock=true",
            "vin": vin
        }


@app.get("/api/chatbot/ask")
async def ask_chatbot(question: str):
    """Simple chatbot endpoint"""
    question_lower = question.lower()

    if any(word in question_lower for word in ['interest', 'apr', 'rate']):
        response = "Interest rates are negotiable. Current market average is 4-6% APR. Compare rates from multiple lenders."
    elif any(word in question_lower for word in ['payment', 'monthly', 'installment']):
        response = "Monthly payments depend on loan term and down payment. Consider extending term for lower payments."
    elif any(word in question_lower for word in ['fee', 'charge', 'cost', 'admin']):
        response = "Many fees are negotiable. Ask for itemized list and challenge fees over $500."
    elif any(word in question_lower for word in ['mileage', 'miles', 'limit']):
        response = "Standard lease mileage is 12,000 miles/year. If you drive less, ask for lower payments."
    else:
        response = "I can help with interest rates, fees, payments, or mileage questions. What specifically would you like to know?"

    return {
        "question": question,
        "response": response,
        "tips": [
            "Research market prices on KBB or Edmunds",
            "Get competing offers from different dealerships",
            "Read all terms carefully before signing",
            "Don't feel pressured to sign immediately"
        ]
    }


def extract_text_from_pdf(file_bytes: bytes) -> str:
    """Extract text from PDF files"""
    text = ""
    try:
        pdf_reader = PyPDF2.PdfReader(io.BytesIO(file_bytes))
        for page in pdf_reader.pages:
            text += page.extract_text() + "\n"
    except Exception as e:
        text = f"PDF extraction error: {str(e)}"
    return text


def extract_contract_details(text: str) -> dict:
    """Extract key contract terms using regex"""
    patterns = {
        "interest_rate": r"(?:interest rate|APR)[:\s]*([\d\.]+%)",
        "monthly_payment": r"(?:monthly payment|installment)[:\s]*\$?([\d,]+\.?\d*)",
        "lease_term": r"(?:term|duration)[:\s]*(\d+)\s*(?:months|years)",
        "down_payment": r"(?:down payment|deposit)[:\s]*\$?([\d,]+\.?\d*)",
        "mileage": r"(?:mileage|annual mileage)[:\s]*([\d,]+)",
        "security_deposit": r"(?:security deposit)[:\s]*\$?([\d,]+\.?\d*)",
        "late_fee": r"(?:late fee|late payment)[:\s]*\$?([\d,]+\.?\d*)",
    }

    extracted = {}
    for key, pattern in patterns.items():
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            extracted[key] = match.group(1)

    return extracted


# Add this new endpoint to backend/app/main.py
@app.get("/api/chatbot/ask_with_context")
async def ask_chatbot_with_context(question: str, contract_id: int = None):
    """Chatbot endpoint with contract context"""

    contract_data = None
    if contract_id and contract_id in contracts_db:
        contract_data = contracts_db[contract_id]

    question_lower = question.lower()

    # Base response
    if any(word in question_lower for word in ['interest', 'apr', 'rate']):
        base_response = "Interest rates are negotiable. Current market average is 4-6% APR."

        # Add contract-specific advice
        if contract_data and contract_data.get('extracted_details', {}).get('interest_rate'):
            rate = contract_data['extracted_details']['interest_rate']
            base_response += f" Your contract shows {rate}. "
            if '%' in rate:
                rate_num = float(rate.replace('%', ''))
                if rate_num > 6:
                    base_response += f"This is higher than average. Try negotiating down to 4-5%."
                else:
                    base_response += "This is reasonable."

        response = base_response

    elif any(word in question_lower for word in ['payment', 'monthly', 'installment']):
        response = "Monthly payments depend on loan term and down payment."

    elif any(word in question_lower for word in ['fee', 'charge']):
        response = "Many fees are negotiable. Ask for itemized list."

    else:
        response = "I can help with interest rates, fees, payments, or mileage questions."

    # Add risk-based advice
    if contract_data:
        risk_level = contract_data.get('risk_level', 'medium')
        if risk_level == 'high':
            response += " ⚠️ Note: This contract has high risk factors."
        elif risk_level == 'medium':
            response += " ⚠️ Note: This contract has some risk factors to review."

    return {
        "question": question,
        "response": response,
        "contract_context": contract_id is not None,
        "risk_level": contract_data.get('risk_level', 'unknown') if contract_data else 'unknown',
        "tips": [
            "Research market prices",
            "Get competing offers",
            "Read all terms carefully"
        ]
    }


if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)