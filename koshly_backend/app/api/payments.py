from fastapi import APIRouter

router = APIRouter()


@router.post("/webhook")
async def razorpay_webhook():
    # TODO: HMAC-SHA256 verify Razorpay webhook and update Supabase
    return {"message": "payments.webhook — not yet implemented"}


@router.post("/create-order")
async def create_order():
    # TODO: Create Razorpay order and return order_id to Flutter
    return {"message": "payments.create-order — not yet implemented"}
