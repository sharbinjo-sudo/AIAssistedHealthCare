# Django Backend

Local backend for the existing Flutter health app. It uses Django, Django REST Framework, SimpleJWT, CORS headers, and SQLite (`db.sqlite3`).

## Flutter Mapping

| Flutter screen | API endpoint | Django model | Operation |
| --- | --- | --- | --- |
| Sign Up | `POST /api/register/` | `User`, `UserProfile`, `DashboardSnapshot` | Create user/profile |
| Login | `POST /api/login/` | `User` | Authenticate, return JWT |
| Personal Details | `GET/PUT/PATCH /api/profile/` | `UserProfile`, `DashboardSnapshot` | Read/update profile and metrics |
| Home Dashboard | `GET /api/dashboard/` | `DashboardSnapshot` | Read latest dashboard data |
| Mini Games | `POST /api/games/`, `GET /api/games/` | `GameResult` | Save/list game result |
| Medical Report Upload | `POST /api/reports/`, `GET /api/reports/analysis/` | `MedicalReport` | Upload/list/analyze report |
| Health Analysis | `GET /api/analysis/` | `DashboardSnapshot` | Read calculated analysis |
| AI Health Report | `GET /api/ai-report/` | `DashboardSnapshot`, `MedicalReport` | Read generated report data |
| AI Chat | `POST /api/chat/`, `GET /api/chat/`, `DELETE /api/chat/clear/` | `ChatMessage` | Save/list/clear chat |
| Future Health | `POST /api/future-health/`, `GET /api/future-health/` | `FutureHealthPrediction` | Create/list prediction |
| Diet | `GET /api/diet/` | Profile/dashboard derived | Read diet targets |
| Progress | `GET/POST/PUT/PATCH/DELETE /api/progress/` | `ProgressEntry` | CRUD progress entries |
| Report History | `GET/DELETE /api/reports/{id}/` | `MedicalReport` | List/delete reports |
| Profile | `GET /api/profile/`, `POST /api/logout/` | `UserProfile`, JWT blacklist | Read profile/logout |

## Setup

```powershell
cd backend
python -m pip install -r requirements.txt
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver 0.0.0.0:8000
```

Optional: copy `.env.example` to `.env` and set `DJANGO_SECRET_KEY`. A local development fallback key is configured so the backend runs immediately.

## Authentication

Protected endpoints require:

```http
Authorization: Bearer <access_token>
```

Register:

```http
POST /api/register/
Content-Type: application/json

{"name":"John","email":"john@example.com","password":"StrongPass123!"}
```

Login:

```http
POST /api/login/
Content-Type: application/json

{"email":"john@example.com","password":"StrongPass123!"}
```

Refresh:

```http
POST /api/token/refresh/
Content-Type: application/json

{"refresh":"<refresh_token>"}
```

## Sample Protected Requests

Update profile:

```http
PATCH /api/profile/
Authorization: Bearer <access_token>
Content-Type: application/json

{"age":28,"height":"175.0","weight":"72.0","blood_pressure":"120/80","sleep_hours":"7.5","water_intake":"2.5L"}
```

Dashboard:

```http
GET /api/dashboard/
Authorization: Bearer <access_token>
```

Response shape:

```json
{
  "success": true,
  "message": "Dashboard data retrieved successfully",
  "data": {
    "healthScore": 91,
    "bmi": 23.5,
    "bioAge": 23,
    "bp": "120/80",
    "heartRate": 74,
    "sleep": 7.5,
    "steps": 8230,
    "water": "2.5L",
    "calories": 640
  }
}
```

Chat:

```http
POST /api/chat/
Authorization: Bearer <access_token>
Content-Type: application/json

{"message":"What is my BMI?"}
```

Future health:

```http
POST /api/future-health/
Authorization: Bearer <access_token>
Content-Type: application/json

{"weight":"72.0","walking":"45.0","sleep":"7.5","water":"2.5","exercise":"4.0","smoking":"0.0","alcohol":"1.0"}
```

## Flutter Local Host Values

Use these base URLs from Flutter:

| Target | Base URL |
| --- | --- |
| Android Emulator | `http://10.0.2.2:8000/api` |
| Physical Android phone | `http://<computer-lan-ip>:8000/api` |
| iOS Simulator | `http://127.0.0.1:8000/api` |
| Physical iPhone | `http://<computer-lan-ip>:8000/api` |
| Flutter web on same machine | `http://127.0.0.1:8000/api` |

For physical devices, run Django with `python manage.py runserver 0.0.0.0:8000` and make sure the phone and computer are on the same network.

## Verification

```powershell
python manage.py check
python manage.py test api
```
