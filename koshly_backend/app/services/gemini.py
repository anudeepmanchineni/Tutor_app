import google.generativeai as genai
from app.core.config import settings

genai.configure(api_key=settings.GEMINI_API_KEY)

model = genai.GenerativeModel("gemini-1.5-flash")


async def evaluate_with_gemini(prompt: str) -> str:
    """Send a grading prompt to Gemini Flash and return the raw text response."""
    response = await model.generate_content_async(prompt)
    return response.text
