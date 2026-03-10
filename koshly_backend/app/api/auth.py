from fastapi import APIRouter

router = APIRouter()


@router.get("/me")
async def get_current_user():
    # TODO: Validate Supabase JWT and return user profile
    return {"message": "auth.me — not yet implemented"}
