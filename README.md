🚗 AutoFinance Guardian

AutoFinance Guardian is a comprehensive full-stack application designed to assist users in navigating the complexities of auto financing. It provides tools for contract analysis, market data insights, negotiation support, and VIN lookup, all accessible through a user-friendly Flutter mobile application and powered by a robust Python backend.

✨ Features

📄 Contract Analysis: Upload and analyze loan or lease contracts to identify key terms, potential pitfalls, and areas for negotiation.

📊 Market Data Insights: Access real-time or historical market data for vehicle pricing, interest rates, and other relevant financial indicators.

🤝 Negotiation Support: Receive AI-powered recommendations and strategies to enhance your negotiation position with dealerships or lenders.

🚘 VIN Lookup: Quickly retrieve detailed information about a vehicle using its Vehicle Identification Number (VIN).

🔐 User Management: Secure user authentication and management for personalized experiences.

🗄️ Database Management: Robust data persistence using SQLAlchemy and Alembic for migrations.

🛠️ Technologies Used
🔙 Backend

Python: Programming language

FastAPI: Web framework for building APIs

SQLAlchemy: ORM (Object Relational Mapper) for database interactions

SQLite: Default database (can be configured for others)

Alembic: Database migrations tool

Pydantic: Data validation and settings management

Uvicorn: ASGI server for running the FastAPI application

pytest: Testing framework

🎨 Frontend

Flutter: UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase

Dart: Programming language for Flutter

⚙️ Setup and Installation
✅ Prerequisites

Python 3.8+

Flutter SDK

Git

🔧 Backend Setup

Clone the repository:

git clone https://github.com/your-username/autofinance_guardian.git
cd autofinance_guardian/backend


Create and activate a virtual environment:

python -m venv venv
.\venv\Scripts\activate


Install dependencies:

pip install -r requirements.txt


Database Migrations:
Initialize and apply database migrations.

alembic upgrade head


Run the backend server:

uvicorn main:app --reload


The backend API will be accessible at:
👉 http://127.0.0.1:8000

📱 Frontend Setup

Navigate to the frontend directory:

cd ../frontend/guardian_app


Get Flutter packages:

flutter pub get


Run the Flutter application:

flutter run


This will launch the application on a connected device or emulator.

🗂️ Project Structure
autofinance_guardian/
├── backend/
│   ├── core/                  # Core configurations and security
│   ├── models/                # Database ORM models and Pydantic schemas
│   ├── routes/                # API endpoints
│   ├── services/              # Business logic and external integrations (AI, Market Data, VIN)
│   ├── tests/                 # Unit and integration tests for the backend
│   ├── utils/                 # Utility functions
│   ├── main.py                # Main FastAPI application entry point
│   ├── database.py            # Database session and engine setup
│   ├── crud.py                # CRUD operations for database models
│   ├── requirements.txt       # Python dependencies
│   ├── alembic.ini            # Alembic configuration
│   └── ...
├── frontend/
│   └── guardian_app/
│       ├── lib/               # Dart source code for the Flutter app
│       │   ├── core/          # Core utilities and shared components
│       │   ├── features/      # Feature-specific modules (e.g., contract_analysis, market_data)
│       │   ├── models/        # Data models for the frontend
│       │   ├── providers/     # State management providers
│       │   └── screens/       # UI screens
│       ├── pubspec.yaml       # Flutter project dependencies
│       └── ...
└── sample_contracts/          # Directory containing sample PDF contracts

🚀 Usage

Once both the backend and frontend are running:

Register a new user or log in through the mobile application.

Utilize the different features: upload contracts for analysis, browse market data, or perform VIN lookups.

Follow the in-app instructions to interact with the AutoFinance Guardian services.

📄 License

(Consider adding a LICENSE file and mentioning it here, e.g., MIT License)
