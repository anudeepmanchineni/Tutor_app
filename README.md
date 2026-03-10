# Koshly — AI-Powered English Proficiency Exam Grading Platform

Koshly is a high-margin, automated EdTech platform providing examiner-level grading for international English proficiency exams (IELTS, PTE, DET, CELPIP). It replaces expensive human tutors with a mathematically consistent AI pipeline, targeting high-intent students in study-abroad markets like Andhra Pradesh.

---

## Exams Supported

| Exam | Full Name |
|---|---|
| IELTS | International English Language Testing System |
| PTE | Pearson Test of English |
| DET | Duolingo English Test |
| CELPIP | Canadian English Language Proficiency Index Program |

---

## Tech Stack

### Frontend
| Package | Version | Purpose |
|---|---|---|
| Flutter SDK | >=3.x | Cross-platform UI (iOS, Android, Web) |
| flutter_riverpod | ^2.x | State management |
| supabase_flutter | ^2.x | Auth + database client |
| dio | ^5.x | HTTP client for backend API calls |
| envied | ^0.5.x | Secure env variable injection via --dart-define |
| go_router | ^13.x | Declarative navigation |
| razorpay_flutter | ^1.x | Razorpay payment SDK |

### Backend
| Package | Version | Purpose |
|---|---|---|
| fastapi | ^0.111.x | Async web framework |
| uvicorn[standard] | ^0.29.x | ASGI server |
| pydantic | ^2.x | Request/response validation |
| pydantic-settings | ^2.x | Settings management from .env |
| supabase | ^2.x | Supabase Python client |
| google-generativeai | ^0.7.x | Gemini Flash integration |
| openai | ^1.x | DeepSeek API (OpenAI-compatible endpoint) |
| httpx | ^0.27.x | Async HTTP client |
| python-dotenv | ^1.x | Load .env locally |
| razorpay | ^1.x | Razorpay server-side SDK |
| cryptography | ^42.x | HMAC-SHA256 webhook verification |

### Infrastructure
| Service | Purpose |
|---|---|
| Supabase | PostgreSQL database + Row Level Security + Auth |
| Google OAuth | User authentication (via Supabase Auth provider) |
| Google Gemini Flash | Primary AI grading model |
| DeepSeek | Secondary AI model (cost optimization / cross-validation) |
| Razorpay | Payment gateway (UPI + Cards) |

---

## Project Structure

```
koshly/
├── backend/                    # FastAPI Python backend
│   ├── app/
│   │   ├── main.py             # FastAPI entry point
│   │   ├── api/                # Route handlers
│   │   │   ├── grading.py
│   │   │   ├── payments.py
│   │   │   └── auth.py
│   │   ├── services/           # Business logic
│   │   │   ├── gemini.py
│   │   │   ├── deepseek.py
│   │   │   └── grader.py
│   │   ├── models/             # Pydantic models
│   │   └── core/
│   │       ├── config.py
│   │       └── supabase.py
│   ├── requirements.txt
│   └── .env                    # Backend secrets (never commit)
│
├── frontend/                   # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── models/
│   │   └── services/
│   ├── pubspec.yaml
│   └── .env                    # Flutter env (never commit)
│
├── .env.example                # Safe env template (commit this)
├── .gitignore
├── README.md
└── CLAUDE.md                   # Claude AI session context
```

---

## Environment Setup

### 1. Clone the repository
```bash
git clone <repo-url>
cd koshly
```

### 2. Configure environment variables
```bash
cp .env.example .env
# Fill in all values in .env — see .env.example for reference
```

### 3. Backend setup
```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### 4. Frontend setup
```bash
cd frontend
flutter pub get
flutter run --dart-define-from-file=.env
```

---

## Environment Variables

See [.env.example](.env.example) for the full list of required variables.

**Never commit `.env` files.** They contain secrets and are excluded via `.gitignore`.

---

## AI Grading Pipeline

1. Student submits writing or speaking response via Flutter app.
2. Flutter sends the response to the FastAPI backend.
3. FastAPI routes to the exam-specific grader service.
4. Gemini Flash evaluates against the official band descriptors for that exam.
5. DeepSeek cross-validates or provides a cost-optimized alternative score.
6. A structured score (band score + subscores + feedback) is returned.
7. Result is stored in Supabase and displayed to the student.

---

## Payment Flow

1. Student selects a plan → Flutter calls FastAPI to create a Razorpay order.
2. Razorpay SDK on Flutter handles the payment UI (UPI / Card).
3. On success, Razorpay sends a webhook to FastAPI.
4. FastAPI verifies the webhook using HMAC-SHA256 with the Razorpay webhook secret.
5. On verification success, Supabase is updated to grant the student access.

---

## Security Notes

- Supabase Row Level Security (RLS) is enabled on all tables.
- The Supabase **service role key** is only used server-side (FastAPI). Never in Flutter.
- Razorpay webhooks are HMAC-SHA256 verified before any order fulfillment.
- Google OAuth is handled via Supabase Auth — no custom OAuth server needed.
- All secrets are loaded from `.env` — never hardcoded.
