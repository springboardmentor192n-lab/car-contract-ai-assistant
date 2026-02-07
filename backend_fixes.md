It appears the Flutter frontend successfully compiled and launched! However, the errors you're seeing in the backend terminal output and frontend console indicate issues with your FastAPI backend.

These are not frontend errors; your Flutter application is correctly attempting to communicate with the backend endpoints as designed. The problem lies with the FastAPI server not being set up to handle those requests.

Here's how to resolve these backend issues:

### 1. Resolve WebSocket Library Not Found Errors (`/ws/activity` 404 and "No supported WebSocket library detected")

Your FastAPI server (running with Uvicorn) is reporting that it cannot find a supported WebSocket library. This is preventing it from establishing WebSocket connections, even if the route were defined.

**Action:** Install the necessary WebSocket library for Uvicorn.

1.  **Stop your FastAPI server** (if it's still running) by pressing `Ctrl+C` in the backend terminal.
2.  **Activate your Python virtual environment** (if you haven't already). Navigate to `E:\autofinance_guardian\backend` and run:
    *   **Windows (PowerShell):** `.\venv\Scripts\Activate.ps1`
    *   **Windows (Command Prompt):** `.\venv\Scripts\activate.bat`
    *   **macOS/Linux:** `source venv/bin/activate`
3.  **Install Uvicorn with standard dependencies (which include WebSocket support) or install `websockets` directly:**
    ```bash
    pip install "uvicorn[standard]"
    # OR:
    # pip install websockets
    ```
4.  **Restart your FastAPI server:**
    ```bash
    uvicorn main:app --reload
    ```

### 2. Implement the `/ws/activity` WebSocket Endpoint in FastAPI

The `404 Not Found` for `/ws/activity` means your FastAPI application doesn't have a route defined for WebSocket connections at that path.

**Action:** Add the WebSocket endpoint to your FastAPI `main.py` (or relevant routing file in `backend/routes`).

*   **Example for `backend/main.py`:**

    ```python
    # backend/main.py

    from fastapi import FastAPI, WebSocket, WebSocketDisconnect
    from fastapi.middleware.cors import CORSMiddleware
    # ... other imports ...

    app = FastAPI()

    # Configure CORS (ensure your Flutter Web app's origin is allowed, e.g., "http://localhost:5000")
    origins = [
        "http://localhost",
        "http://localhost:8000",
        "http://localhost:5000", # Add the origin where your Flutter Web app is served
        # Add any other origins your frontend might be running on (e.g., LAN IP)
    ]

    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ... other routes (e.g., VIN, analyze_contract) ...

    # WebSocket endpoint for real-time activity
    @app.websocket("/ws/activity")
    async def websocket_activity_endpoint(websocket: WebSocket):
        await websocket.accept()
        try:
            while True:
                # You would typically send real-time activity updates here
                # For now, let's just keep the connection alive or send a mock message
                await websocket.send_json({"id": "mock_id", "title": "Backend online", "type": "backend_status", "status": "Connected", "timestamp": str(datetime.now())})
                await asyncio.sleep(10) # Send a message every 10 seconds
        except WebSocketDisconnect:
            print("Client disconnected from /ws/activity")
        except Exception as e:
            print(f"WebSocket error: {e}")

    # ... rest of your main.py ...
    ```

### 3. Implement the `POST /analyze_contract` Endpoint in FastAPI

The `404 Not Found` for `POST /analyze_contract` means this API endpoint is also missing from your backend.

**Action:** Add this API endpoint to your FastAPI `main.py` (or relevant routing file in `backend/routes`). This endpoint should accept a multipart file upload and return the structured analysis result.

*   **Example for `backend/main.py` (or a router file like `backend/routes/contract.py`):**

    ```python
    # backend/main.py (or backend/routes/contract.py)

    import time
    from fastapi import UploadFile, File, Form, HTTPException
    from pydantic import BaseModel

    # Define the response model based on frontend's expectation
    class ContractAnalysisResponse(BaseModel):
        file_name: str
        risk_level: str
        hidden_fees: list[str]
        penalties: list[str]
        unfair_clauses: list[str]
        summary: str

    # ... (if using a router, define router = APIRouter() and use @router.post) ...

    @app.post("/analyze_contract", response_model=ContractAnalysisResponse)
    async def analyze_contract_endpoint(file: UploadFile = File(...)):
        # Simulate AI analysis
        file_content = await file.read()
        print(f"Received file: {file.filename}, size: {len(file_content)} bytes for analysis.")
        
        # Simulate processing time
        time.sleep(2)

        # MOCK LOGIC: Provide a mock response based on filename or some simple heuristic
        file_name_lower = file.filename.lower()
        if "bad" in file_name_lower or "highrisk" in file_name_lower:
            risk_level = "High"
            hidden_fees = ["Excessive late payment fee (5%)", "Undisclosed administration charges (\$150)"]
            penalties = ["Early termination fee = 3 months payments", "High interest rate increase on default"]
            unfair_clauses = ["Lender can unilaterally change terms", "Arbitration clause favors lender"]
            summary = "This contract contains several high-risk clauses, including unilateral term changes and high hidden fees. Proceed with extreme caution and seek legal advice."
        elif "medium" in file_name_lower:
            risk_level = "Medium"
            hidden_fees = ["Minor documentation fee (\$25)"]
            penalties = ["Standard late payment fee (\$35)"]
            unfair_clauses = []
            summary = "The contract has a few areas for review, but overall appears manageable. Pay attention to documentation fees and standard penalties."
        else:
            risk_level = "Low"
            hidden_fees = []
            penalties = ["Standard late payment fee (\$30)"]
            unfair_clauses = []
            summary = "This contract appears to have fair and standard terms. The only penalty noted is for late payments, which is common. This is a low-risk agreement."
        
        return ContractAnalysisResponse(
            file_name=file.filename,
            risk_level=risk_level,
            hidden_fees=hidden_fees,
            penalties=penalties,
            unfair_clauses=unfair_clauses,
            summary=summary
        )
    ```
    *   **Important:** Remember to add `from datetime import datetime` and `import asyncio` if you use the WebSocket example. Also, add `from fastapi import UploadFile, File, Form, HTTPException` and `from pydantic import BaseModel` and `import time` for the `analyze_contract` endpoint example.

After making these changes to your FastAPI backend, **restart your FastAPI server** and then refresh your Flutter Web application in the browser.

Let me know once you've updated your backend, and we can confirm the frontend communication.