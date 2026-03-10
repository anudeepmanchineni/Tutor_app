# Exam-specific grading logic lives here.
# Each exam (IELTS, PTE, DET, CELPIP) will have its own grading function
# that constructs the rubric-anchored prompt and calls the appropriate LLM service.

from app.services.gemini import evaluate_with_gemini
from app.services.deepseek import evaluate_with_deepseek


async def grade_ielts(section_type: str, response_text: str) -> dict:
    # TODO: Build IELTS band descriptor prompt and parse structured score
    raise NotImplementedError


async def grade_pte(section_type: str, response_text: str) -> dict:
    # TODO: Build PTE rubric prompt and parse structured score
    raise NotImplementedError


async def grade_det(section_type: str, response_text: str) -> dict:
    # TODO: Build DET rubric prompt and parse structured score
    raise NotImplementedError


async def grade_celpip(section_type: str, response_text: str) -> dict:
    # TODO: Build CELPIP rubric prompt and parse structured score
    raise NotImplementedError
