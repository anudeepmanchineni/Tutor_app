from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api import auth, grading, payments

app = FastAPI(
    title="Koshly API",
    description="AI-powered English proficiency exam grading backend",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(grading.router, prefix="/grading", tags=["grading"])
app.include_router(payments.router, prefix="/payments", tags=["payments"])


@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "koshly-backend"}
