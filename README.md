# Car Contract AI Assistant

A comprehensive AI-powered application for reviewing, analyzing, and negotiating car lease and loan contracts. This project features a robust **FastAPI** backend and a cross-platform **Flutter** frontend.

## 🚀 Features

- **Contract Analysis**: Upload PDF contracts for automated OCR and AI analysis to extract key terms, clauses, and hidden fees.
- **Risk Assessment**: Identifies potential risks, predatory terms, and financial pitfalls in contracts.
- **Negotiation Chatbot**: AI-driven chatbot to guide users through negotiation strategies based on contract details.
- **VIN Decoding**: Integrated VIN decoding to verify vehicle details.
- **Price Estimation**: Estimation of fair market value and lease payments.
- **Cross-Platform**: Accessible via Web, Windows, and potentially Mobile.

## 🛠️ Tech Stack

### Backend
- **Framework**: FastAPI (Python)
- **Database**: SQLite (default) / PostgreSQL (supported)
- **AI/ML**: OpenAI GPT-4, Groq (Llama 3), PyMuPDF, Pytesseract, PDF2Image
- **Authentication**: JWT (OAuth2 with Password Flow)

### Frontend
- **Framework**: Flutter
- **State Management**: Provider
- **Networking**: Dio
- **UI**: Material Design 3

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Python 3.8+**: [Download Python](https://www.python.org/downloads/)
- **Flutter SDK**: [Download Flutter](https://docs.flutter.dev/get-started/install)
- **Poppler**: Required for PDF processing.
    - *Windows*: Download binary and add `bin` folder to PATH.
    - *Mac*: `brew install poppler`
    - *Linux*: `sudo apt-get install poppler-utils`
- **Tesseract OCR**: Required for OCR capabilities.
    - *Windows*: [Download Installer](https://github.com/UB-Mannheim/tesseract/wiki)
    - *Mac*: `brew install tesseract`
    - *Linux*: `sudo apt-get install tesseract-ocr`

## ⚙️ Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository_url>
cd contract_anti
```

### 2. Backend Setup
Navigate to the backend directory:
```bash
cd backend
```

Create and activate a virtual environment:
```bash
# Windows
python -m venv venv
.\venv\Scripts\activate

# Mac/Linux
python3 -m venv venv
source venv/bin/activate
```

Install dependencies:
```bash
pip install -r requirements.txt
```

**Configuration (.env):**
Create a `.env` file in the `backend` directory with the following variables:
```env
# Database
DATABASE_URL=sqlite:///./sql_app.db
# Or for PostgreSQL: postgresql://user:password@localhost/dbname


https://github.com/user-attachments/assets/ae607308-cb91-4a0a-909f-50529771c70a


# Security
SECRET_KEY=your_super_secret_key_here
ALGORITHM=HS256

# AI APIs
OPENAI_API_KEY=sk-your-openai-key
GROQ_API_KEY=gsk_your_groq_key

# Optional
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_SERVER=localhost
POSTGRES_PORT=5432
POSTGRES_DB=contract_db
```

Run the Backend Server:
```bash
uvicorn main:app --reload
```
*The API will be available at `http://127.0.0.1:8000` by default. Swagger docs at `/docs`.*

### 3. Frontend Setup
Navigate to the frontend directory:
```bash
cd ../frontend
```

Install Flutter dependencies:
```bash
flutter pub get
```

**Configuration:**
Check `lib/services/api_service.dart`. Ensure the `baseUrl` matches your running backend port (default is usually `8000`, but code might target `8001` or similar).

Run the Application:
```bash
# For Windows
flutter run -d windows

# For Web
flutter run -d chrome
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| **PDF Upload Fails** | Ensure `Poppler` is installed and added to your system PATH. |
| **OCR returns empty text** | Ensure `Tesseract OCR` is installed and available in PATH. |
| **Database Connection Error** | Check `DATABASE_URL` in `.env`. Ensure the database server is running (if using Postgres). |
| **Frontend Connection Refused** | Verify backend is running. Check `api_service.dart` `baseUrl`. Use `10.0.2.2` for Android emulators. |
| **Missing API Keys** | Ensure `OPENAI_API_KEY` and `GROQ_API_KEY` are set in `.env` for AI features to work. |

## 🤝 Contributing
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
