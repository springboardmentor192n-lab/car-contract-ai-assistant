# backend/app/api/contracts.py
from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.contract_service import ContractService
import uuid

router = APIRouter(prefix="/api/contracts", tags=["contracts"])

# Simple in-memory "database" for testing
contracts_db = {}
next_id = 1


@router.post("/upload-enhanced")
async def upload_enhanced(file: UploadFile = File(...), session_id: str = None):
    """Upload and analyze contract"""

    if not file.filename:
        raise HTTPException(400, "No file provided")

    # Read file
    contents = await file.read()

    # Generate session ID if not provided
    if not session_id:
        session_id = str(uuid.uuid4())

    # Use a temporary user ID
    user_id = "user_" + session_id

    # Create service and analyze
    # Note: For now, we'll pass None as db parameter
    service = ContractService(db=None)

    try:
        result = await service.analyze_and_save_contract(
            user_id=user_id,
            session_id=session_id,
            file_bytes=contents,
            filename=file.filename
        )

        # Store in simple "database"
        global next_id
        contracts_db[next_id] = result
        contract_id = next_id
        next_id += 1

        return {
            "success": True,
            "session_id": session_id,
            "contract_id": contract_id,
            "analysis": result["analysis"],
            "extraction": result["extraction"]
        }

    except Exception as e:
        raise HTTPException(500, f"Analysis failed: {str(e)}")


@router.get("/{contract_id}")
async def get_contract(contract_id: int):
    """Get contract by ID"""
    if contract_id not in contracts_db:
        raise HTTPException(404, "Contract not found")

    return {
        "contract_id": contract_id,
        **contracts_db[contract_id]["contract_info"]
    }


@router.get("/user/{user_id}")
async def get_user_contracts(user_id: str, limit: int = 20):
    """Get user's contracts"""
    # Filter contracts by user_id (simplified)
    user_contracts = []
    for cid, contract in contracts_db.items():
        if contract["contract_info"]["user_id"] == user_id:
            user_contracts.append({
                "id": cid,
                **contract["contract_info"]
            })

    return {
        "user_id": user_id,
        "total": len(user_contracts),
        "contracts": user_contracts[:limit]
    }


@router.get("/stats/{user_id}")
async def get_contract_stats(user_id: str):
    """Get contract statistics"""
    # Calculate stats from user contracts
    user_contracts = []
    for cid, contract in contracts_db.items():
        if contract["contract_info"]["user_id"] == user_id:
            user_contracts.append(contract)

    if not user_contracts:
        return {
            "total_contracts": 0,
            "analyzed_contracts": 0,
            "analysis_rate": 0,
            "risk_distribution": {"low": 0, "medium": 0, "high": 0},
            "average_risk_score": 0
        }

    # Calculate average risk
    total_score = sum(c["analysis"]["risk_score"] for c in user_contracts)
    avg_score = total_score / len(user_contracts)

    # Count risk levels
    risk_counts = {"low": 0, "medium": 0, "high": 0}
    for contract in user_contracts:
        level = contract["analysis"]["risk_level"]
        risk_counts[level] = risk_counts.get(level, 0) + 1

    return {
        "total_contracts": len(user_contracts),
        "analyzed_contracts": len(user_contracts),
        "analysis_rate": 100,
        "risk_distribution": risk_counts,
        "average_risk_score": round(avg_score, 2)
    }