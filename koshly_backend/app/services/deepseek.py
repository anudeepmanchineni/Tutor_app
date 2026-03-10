from openai import AsyncOpenAI
from app.core.config import settings

# DeepSeek uses an OpenAI-compatible API endpoint
client = AsyncOpenAI(
    api_key=settings.DEEPSEEK_API_KEY,
    base_url="https://api.deepseek.com",
)


async def evaluate_with_deepseek(prompt: str) -> str:
    """Send a grading prompt to DeepSeek and return the raw text response."""
    response = await client.chat.completions.create(
        model="deepseek-chat",
        messages=[{"role": "user", "content": prompt}],
    )
    return response.choices[0].message.content
