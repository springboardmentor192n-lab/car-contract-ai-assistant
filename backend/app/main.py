from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes.upload import router as upload_router
from app.routes.chat import router as chat_router
from app.routes.price import router as price_router
from app.routes.price_chat import router as price_chat_router

app = FastAPI(title="Car Contract AI")

# CORS settings - allow all for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(upload_router, prefix="/api")
app.include_router(chat_router, prefix="/api")
app.include_router(price_router, prefix="/api")
app.include_router(price_chat_router, prefix="/api")
