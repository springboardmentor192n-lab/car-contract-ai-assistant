# 🚗 AutoFinance Guardian

> **AI-Powered Auto Financing Assistant**
> Analyze contracts, get market insights, perform VIN lookups, and negotiate smarter — all from a beautiful Flutter app backed by a scalable FastAPI backend.

---

## 🌐 Live Demo

🔗 https://autofinance-guardian.web.app/

---

## 📸 Screenshots

> Add your real screenshots inside the `/screenshots` folder and update paths below.

| Home                      | Contract Analysis             | VIN Lookup               | Market Insights             | Negotiation Support              |
| ------------------------- | ----------------------------- | ------------------------ | --------------------------- | -------------------------------- |
| ![](screenshots/home.png) | ![](screenshots/contract.png) | ![](screenshots/vin.png) | ![](screenshots/market.png) | ![](screenshots/negotiation.png) |

---

# ✨ Features

## 📄 Contract Analysis

* Upload loan/lease contracts (PDF)
* Extract key financial terms
* Identify hidden clauses & risks
* AI-powered negotiation suggestions

## 🚘 VIN Lookup

* Decode vehicle details instantly
* Manufacturer, model, year, specs
* Fraud & history awareness ready

## 📊 Market Data Insights

* Real-time car price trends
* Interest rate benchmarks
* Smart affordability recommendations

## 🤝 Negotiation Support

* AI negotiation strategy generator
* Dealer comparison insights
* Smart loan vs lease suggestions

## 🔐 Secure User Management

* Firebase Authentication (Email / Google)
* JWT-secured API communication
* Personalized financial dashboards

---

# 🧠 System Architecture

```
Flutter Mobile/Web App
        │
        │ HTTPS REST API
        ▼
FastAPI Backend (Render)
        │
        ├── Contract AI Analysis
        ├── Market Data Service
        ├── VIN Decoder Service
        │
        ▼
PostgreSQL Database
        │
        ▼
External APIs / AI Models
```

---

# 🛠️ Tech Stack

## 🎨 Frontend

* Flutter (Dart)
* Firebase Hosting
* Firebase Authentication
* Provider State Management

## 🔙 Backend

* Python
* FastAPI
* SQLAlchemy ORM
* Alembic Migrations
* Uvicorn ASGI Server

## 🗄️ Database

* PostgreSQL (Production)
* SQLite (Development)

## ☁️ Deployment

* Backend: Render
* Frontend: Firebase Hosting

---

# 📁 Project Structure

```
autofinance_guardian/
├── backend/
│   ├── core/            # Security & configs
│   ├── models/          # ORM + Pydantic schemas
│   ├── routes/          # API endpoints
│   ├── services/        # AI, VIN, Market logic
│   ├── tests/           # Unit & integration tests
│   ├── utils/           # Helpers
│   ├── main.py          # FastAPI entry
│   ├── database.py      # DB engine/session
│   ├── crud.py          # CRUD operations
│   └── requirements.txt
│
├── frontend/guardian_app/
│   ├── lib/
│   │   ├── core/        # API + shared utils
│   │   ├── features/    # Feature modules
│   │   ├── models/      # Data models
│   │   ├── providers/   # State management
│   │   └── screens/     # UI screens
│   └── pubspec.yaml
│
└── screenshots/         # App UI screenshots
```

---

# 🚀 Local Setup Guide

## 🔧 Prerequisites

* Python 3.9+
* Flutter SDK
* Firebase CLI
* Git

---

# 🔙 Backend Setup (FastAPI)

```bash
git clone https://github.com/your-username/autofinance_guardian.git
cd autofinance_guardian/backend

python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

pip install -r requirements.txt
alembic upgrade head

uvicorn main:app --reload
```

Backend runs at:

```
http://127.0.0.1:8000
```

---

# 📱 Frontend Setup (Flutter)

```bash
cd ../frontend/guardian_app
flutter pub get
flutter run
```

---

# 🔗 Environment Variables

Create `.env` inside backend:

```
DATABASE_URL=postgresql://user:password@host:5432/autofinance
SECRET_KEY=supersecretkey
FIREBASE_PROJECT_ID=your_project_id
```

---

# ☁️ Production Deployment

## 🔙 Backend → Render

1. Push backend to GitHub
2. Create Web Service on Render
3. Settings:

```
Build Command: pip install -r requirements.txt
Start Command: uvicorn main:app --host 0.0.0.0 --port 10000
```

Backend URL:

```
https://your-backend.onrender.com
```

---

## 🎨 Frontend → Firebase Hosting

```bash
flutter build web
firebase login
firebase init
firebase deploy
```

App live at:

```
https://autofinance-guardian.web.app
```

---

# 🔌 API Endpoints Overview

| Method | Endpoint            | Description                    |
| ------ | ------------------- | ------------------------------ |
| POST   | `/analyze-contract` | Upload & analyze loan contract |
| GET    | `/vin/{vin}`        | Vehicle VIN lookup             |
| GET    | `/market`           | Market financial insights      |
| POST   | `/auth/login`       | User authentication            |

---

# 🔒 Security

* Firebase JWT Authentication
* Secure API token validation
* Encrypted user session handling
* Role-based access ready

---

# 📊 Future Enhancements

* 📈 Loan EMI calculator with AI suggestions
* 🧠 LLM-powered contract clause explanation
* 📉 Interest rate prediction model
* 📲 Native iOS & Android releases

---

# 🤝 Contributing

Pull requests are welcome!
For major changes, please open an issue first to discuss what you would like to change.

```bash
git checkout -b feature/new-feature
git commit -m "Add new feature"
git push origin feature/new-feature
```

---

# 📄 License

MIT License © 2026 AutoFinance Guardian

---

# ⭐ Support

If you like this project, give it a ⭐ on GitHub and share it with others!

> Built with ❤️ using Flutter, FastAPI, Firebase & Render.
