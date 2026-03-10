# CLAUDE.md — Koshly Project Context

> This file is auto-loaded at the start of every Claude session.
> It is the single source of truth for project conventions, architecture, and decisions.

---

## Project Overview

**Koshly** is a high-margin, automated EdTech platform that provides examiner-level grading for international English proficiency exams:
- **IELTS** (International English Language Testing System)
- **PTE** (Pearson Test of English)
- **DET** (Duolingo English Test)
- **CELPIP** (Canadian English Language Proficiency Index Program)

Target market: High-intent students in regions like Andhra Pradesh preparing for study-abroad programs. Koshly replaces expensive human tutors with a mathematically consistent AI grading pipeline.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (iOS, Android, Web) + Riverpod (state management) |
| Backend | Python FastAPI (stateless, async) |
| Database | Supabase (PostgreSQL + Row Level Security) |
| Auth | Supabase + Google OAuth |
| AI/LLM | Google Gemini Flash + DeepSeek |
| Payments | Razorpay (UPI + Cards) + FastAPI webhook verification |

---

## Repository Structure (Target)

```
koshly/
├── backend/                    # FastAPI Python backend
│   ├── app/
│   │   ├── main.py             # FastAPI entry point
│   │   ├── api/                # Route handlers
│   │   │   ├── grading.py      # AI grading endpoints
│   │   │   ├── payments.py     # Razorpay webhooks
│   │   │   └── auth.py         # Auth helpers
│   │   ├── services/           # Business logic
│   │   │   ├── gemini.py       # Gemini Flash integration
│   │   │   ├── deepseek.py     # DeepSeek integration
│   │   │   └── grader.py       # Exam-specific grading logic
│   │   ├── models/             # Pydantic models
│   │   └── core/
│   │       ├── config.py       # Settings from .env
│   │       └── supabase.py     # Supabase client
│   ├── requirements.txt
│   └── .env                    # Backend secrets (never commit)
│
├── frontend/                   # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── providers/          # Riverpod providers
│   │   ├── screens/            # UI screens per exam/section
│   │   ├── models/             # Dart data models
│   │   └── services/           # API clients, Supabase SDK calls
│   ├── pubspec.yaml
│   └── .env                    # Flutter env (use --dart-define or envied)
│
├── .env.example                # Safe-to-commit env template
├── .gitignore
├── README.md
└── CLAUDE.md                   # This file
```

---

## Key Conventions

### General
- **Ask before acting**: No code changes, business logic, or architecture decisions without user consent.
- **No assumptions**: If something is unclear, ask.
- **Minimal changes**: Only change what is directly requested.

### Backend (FastAPI)
- All endpoints are **async**.
- Business logic lives in `services/`, not in route handlers.
- Use **Pydantic v2** for all request/response models.
- Settings loaded via `pydantic-settings` from `.env`.
- Supabase interactions use the `supabase-py` client with the **service role key** (server-side only).
- Razorpay webhook payloads must be **HMAC-SHA256 verified** before processing.

### Frontend (Flutter)
- State management: **Riverpod** only (no Provider, no BLoC).
- API calls go through service classes, never directly from UI widgets.
- Auth state managed via Supabase Flutter SDK + Riverpod stream providers.
- Environment variables injected via `--dart-define` or the `envied` package (never hardcoded).

### Database (Supabase)
- All tables must have **Row Level Security (RLS)** enabled.
- Use Supabase migrations for all schema changes.
- Never expose the **service role key** to the client/Flutter app.

### AI Grading Pipeline
- Gemini Flash: primary model for writing/speaking grading.
- DeepSeek: secondary model (cost optimization or cross-validation).
- Grading output must be deterministic and rubric-anchored per exam band descriptors.
- Each exam (IELTS, PTE, DET, CELPIP) has its own grading rubric service.

### Payments
- Razorpay for UPI + Cards.
- All payment verification happens server-side (FastAPI webhook).
- Order creation → payment capture → webhook verification → Supabase update.

---

## Environment Variables

All secrets live in `.env`. See `.env.example` for the full list.
**Critical**: Never commit `.env`. It is in `.gitignore`.

---

## Exams in Scope (All Four from Day One)

| Exam | Sections Graded |
|---|---|
| IELTS | Writing Task 1, Writing Task 2, Speaking |
| PTE | Write Essay, Summarize Written Text, Speaking |
| DET | Writing, Speaking, Interactive Writing |
| CELPIP | Writing Task 1, Writing Task 2, Speaking |

---

## Memory Notes

- This project was initialized on 2026-03-10.
- Working directory: `c:\Users\91720\Tutor_app\Tutor_app`
- User requires consent before any code changes or business logic decisions.
