
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import settings
from routers import auth, contract, vin, negotiation
from database import engine, Base

from fastapi import Request
import time

from starlette.middleware.base import BaseHTTPMiddleware

from fastapi import FastAPI, Request, Response
import time

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title=settings.PROJECT_NAME, version=settings.PROJECT_VERSION)

# Unified CORS & PNA Middleware
@app.middleware("http")
async def ultimate_cors_middleware(request: Request, call_next):
    origin = request.headers.get("origin", "*")
    
    # Preflight Check
    if request.method == "OPTIONS":
        response = Response(status_code=204)
        response.headers["Access-Control-Allow-Origin"] = origin
        response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS, PATCH"
        response.headers["Access-Control-Allow-Headers"] = "*"
        response.headers["Access-Control-Allow-Private-Network"] = "true"
        response.headers["Access-Control-Allow-Credentials"] = "true"
        response.headers["Access-Control-Max-Age"] = "86400"
        return response

    try:
        response = await call_next(request)
    except Exception as e:
        print(f"CRITICAL ERROR: {e}")
        response = Response(status_code=500, content=f"Internal Server Error: {str(e)}")

    response.headers["Access-Control-Allow-Origin"] = origin
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS, PATCH"
    response.headers["Access-Control-Allow-Headers"] = "*"
    response.headers["Access-Control-Allow-Private-Network"] = "true"
    response.headers["Access-Control-Allow-Credentials"] = "true"
    
    return response

# Dedicated preflight catcher for routers that might bypass middleware
@app.options("/{path:path}")
async def preflight_handler(path: str, request: Request):
    origin = request.headers.get("origin", "*")
    response = Response(status_code=204)
    response.headers["Access-Control-Allow-Origin"] = origin
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS, PATCH"
    response.headers["Access-Control-Allow-Headers"] = "*"
    response.headers["Access-Control-Allow-Private-Network"] = "true"
    response.headers["Access-Control-Allow-Credentials"] = "true"
    return response

# Include Routers
app.include_router(auth.router)
app.include_router(contract.router)
app.include_router(vin.router)
app.include_router(negotiation.router)

@app.get("/")
def read_root():
    return {"message": "AI Car Contract Assistant API Ready"}
