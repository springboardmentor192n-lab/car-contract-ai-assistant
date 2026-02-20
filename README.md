# 🚗 Car Lease AI Assistant

**Car Lease AI Assistant** is a comprehensive, AI-powered fintech application designed to help everyday car buyers understand, analyze, and negotiate complex lease and loan contracts.

By leveraging advanced OCR, Machine Learning classification, and Large Language Models, this application instantly identifies "gotchas" in dealer contracts, calculates fairness scores based on current market rates, and provides an interactive AI Negotiation assistant to help users secure better terms.

---

## ✨ Features

*   **📄 AI PDF Contract Analysis**: Upload a dealer contract (PDF) and instantly receive a simplified breakdown of the terms, including monthly payments, term length, money factor, and hidden fees.
*   **⚖️ Market Fairness Score**: Calculates a "Fairness Score" out of 100 by comparing the extracted contract terms against real-time market benchmarks and expected depreciation curves.
*   **🧠 Clause Classification ML Pipeline**: Uses a custom-trained Scikit-Learn machine learning pipeline to automatically categorize complex legal jargon into understandable sections (Financial, Warranty, Penalties).
*   **🏢 Vehicle History & Valuation**: Integrates with the NHTSA API to pull real-time vehicle details and recall information using the extracted VIN.
*   **💬 Interactive AI Negotiator**: A context-aware chatbot that reads your specific contract and provides tailored counter-offers, talking points, and pre-written emails to send to the dealership.
*   **📱 Cross-Platform UI**: Built with Flutter for a seamless, natively compiled, and responsive experience across Web, iOS, and Android.

---

## 🛠️ Technology Stack

### **Frontend (Mobile & Web)**
*   **Framework**: Flutter (Dart)
*   **State Management / Navigation**: GoRouter
*   **Networking**: Dio (HTTP client for API requests)
*   **Deployment**: Firebase Hosting

### **Backend (API & AI Processing)**
*   **Framework**: FastAPI (Python 3.10)
*   **Document Processing**: Tesseract OCR, Poppler, `pdf2image`
*   **Machine Learning**: `scikit-learn`, `joblib`
*   **LLM Provider**: Groq API (Llama 3 / Mixtral)
*   **Deployment**: Docker, Render.com

---

## 🚀 Live Demo

*   **Frontend Web App**: [https://carleaseai.web.app](https://carleaseai.web.app)
*   **Backend API Base**: `https://car-lease-ai-backend.onrender.com`

> **Note on Free Hosting**: The backend is hosted on a Render free tier instance. It may take up to **50 seconds to wake up** if it has been inactive for 15 minutes. Please be patient on the first contract upload!

---

## 💻 Local Development Setup

To run this project locally, you will need to start both the Python backend and the Flutter frontend.

### Prerequisites
*   Flutter SDK (^3.19.0 or higher)
*   Python 3.10+
*   Tesseract OCR installed on your machine and added to your System PATH
*   Poppler installed (required for `pdf2image`)
*   A Groq API Key

### 1. Backend Setup

1. Navigate to the project root:
   ```bash
   cd car_lease_ai
   ```
2. Create and activate a Python virtual environment:
   ```bash
   python -m venv .venv
   # Windows:
   .venv\Scripts\activate
   # Mac/Linux:
   source .venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r backend/requirements.txt
   pip install pdf2image pytesseract python-dotenv groq requests scikit-learn
   ```
4. Configure Environment Variables:
   Create a `.env` file in the root directory and add your Groq API key:
   ```env
   GROQ_API_KEY=your_groq_api_key_here
   ```
5. Run the FastAPI Server:
   ```bash
   uvicorn backend.main:app --host 127.0.0.1 --port 8000 --reload
   ```
   *The API will be available at `http://127.0.0.1:8000`. You can view Swagger documentation at `http://127.0.0.1:8000/docs`.*

### 2. Frontend Setup

1. Open a new terminal and navigate to the Flutter project folder:
   ```bash
   cd car_lease_ai/carAi
   ```
2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```
3. Ensure the `ApiService` is pointing to your local environment. Open `lib/services/api_service.dart` and verify:
   ```dart
   static String get baseUrl => 'http://127.0.0.1:8000';
   ```
4. Run the app:
   ```bash
   flutter run -d chrome
   ```

---

## 📁 Project Structure

```text
car_lease_ai/
├── backend/                  # FastAPI Application Core
│   ├── main.py               # API Entrypoint
│   ├── requirements.txt
│   ├── llm_service.py        # Groq API Prompts & Parsing
│   ├── vin_service.py        # NHTSA API Integration
│   └── fairness.py           # Contract Scoring Logic
├── carAi/                    # Flutter Frontend Source Code
│   ├── lib/
│   │   ├── screens/          # UI Views (Home, Analysis, Negotiation)
│   │   ├── services/         # API Service (Dio)
│   │   ├── models/           # Dart Data Classes
│   │   └── theme.dart        # Global App Styling
├── models/                   # Pre-trained ML Models (.pkl files)
├── ocr/                      # Core Text Extraction pipeline (Tesseract)
├── Dockerfile                # Render Deployment Production Config
└── README.md                 # You are here!
```

---

*This application was built as a portfolio project showcasing Full-Stack AI integration, Mobile/Web cross-platform UI, and NLP capabilities.*
