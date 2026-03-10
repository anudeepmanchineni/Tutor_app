from fastapi import APIRouter

router = APIRouter()


@router.post("/evaluate")
async def evaluate_response():
    # TODO: Accept submission, route to exam-specific grader service
    return {"message": "grading.evaluate — not yet implemented"}
