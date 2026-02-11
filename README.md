# LeaseWise AI – Car Lease & Loan Contract Intelligence Assistant

LeaseWise AI is an AI-powered application designed to help users **understand, analyze, and negotiate car lease or loan agreements before signing**. The platform combines OCR, Large Language Models (LLMs), and public vehicle data APIs to extract critical contract clauses, explain risks in simple language, and provide intelligent negotiation and pricing insights.

The project is built as a **full-stack system** with a FastAPI backend for AI processing and a Flutter-based frontend for a clean, modern user experience.

---

## 📁 Project Structure

```
car-contract-ai-assistant/
│
├── backend/
│   ├── app/
│   │   ├── main.py                 # FastAPI app entry point
│   │   ├── routes/
│   │   │   └── upload.py            # Contract upload & processing API
│   │   ├── services/
│   │   │   ├── ocr.py               # OCR logic (EasyOCR)
│   │   │   ├── text_cleaner.py      # Text preprocessing
│   │   │   ├── llm_extractor.py     # LLM-based SLA extraction (Ollama)
│   │   │   └── vin_service.py       # VIN decoding & vehicle info
│   │   └── storage/
│   │       └── contracts/           # Uploaded contracts (local storage)
│   ├── requirements.txt
│   └── venv/
│
├── frontend/
│   ├── lib/
│   │   ├── presentations/
│   │   │   ├── views/               # Screens (Dashboard, Upload, Chat, etc.)
│   │   │   ├── widgets/             # Reusable UI components
│   │   │   ├── controllers/         # UI logic controllers
│   │   │   └── bindings/            # App routes
│   │   ├── services/                # API service layer
│   │   └── theme/                   # App theme & styling
│   └── pubspec.yaml
│
└── README.md
```

---

## ✨ Key Features

### 📄 Contract Upload & OCR

* Upload car lease or loan agreements (PDF / image formats)
* OCR powered by **EasyOCR**
* Automatic text cleaning and preprocessing

### 🧠 AI-Based Contract Analysis

* Uses **LLMs via Ollama** to extract structured contract information:

  * Interest rate / APR
  * Lease term duration
  * Monthly payment
  * Down payment
  * Residual value
  * Mileage allowance & overage charges
  * Early termination clauses
  * Purchase / buyout options
  * Maintenance responsibilities
  * Warranty & insurance coverage
  * Penalties and late fees

### 💬 AI Contract Chatbot

* Chat with an AI assistant about the uploaded contract
* Ask questions like:

  * *“Is this lease risky?”*
  * *“What clauses should I negotiate?”*
  * *“Explain this penalty in simple terms”*

### 🚘 VIN-Based Vehicle Information

* VIN decoding using **NHTSA public API**
* Fetches:

  * Manufacturer details
  * Vehicle specifications
  * Recall history

### 💰 Vehicle Price Estimation

* Provides fair price and lease benchmarks using public data sources
* Helps users evaluate whether a deal is reasonable before negotiating

### 📰 Car News & Market Insights

* Dashboard shows latest car-related news and trends
* Keeps users informed about market movements that affect leasing decisions

---

## 🛠️ Tech Stack

### Frontend

* **Flutter (Web)**

### Backend

* **Python**

### AI & APIs

* Ollama (LLM execution locally)
* NHTSA VIN Decoder API (public)
* Public car information sources

---

## 🚀 Project Setup Instructions

### 🔹 Prerequisites

* Ollama installed locally
* Git for version control
* Chrome (for Flutter Web)

---

## 🔧 Backend Setup (FastAPI)

### 1️⃣ Navigate to backend directory

```bash
cd backend
```

### 2️⃣ Create and activate virtual environment

**Windows**

```bash
python -m venv venv
venv\Scripts\activate
```

**macOS / Linux**

```bash
python3 -m venv venv
source venv/bin/activate
```

### 3️⃣ Install backend dependencies

```bash
pip install -r requirements.txt
```

### 4️⃣ Start Ollama server

```bash
ollama serve
```

Pull the model if required:

```bash
ollama pull llama3.2
```

### 5️⃣ Run FastAPI backend

```bash
uvicorn app.main:app --reload
```

Backend will be available at:

```
http://127.0.0.1:8000
```

## 🎨 Frontend Setup (Flutter)

### 1️⃣ Navigate to frontend directory

```bash
cd frontend
```

### 2️⃣ Install Flutter dependencies

```bash
flutter pub get
```

### 3️⃣ Run Flutter web app

```bash
flutter run -d chrome
```

## 🚧 Current Limitations

* Contracts stored locally (no cloud storage)
* Price estimation uses public data only
* News data currently static (API integration planned)

---

## 🚀 Future Enhancements

. **Advanced Price Benchmarking**

   * Integration with additional market data sources

. **Model Fine-Tuning**

   * Domain-specific LLM tuning for automotive contracts

. **Personalized Insights**

   * Recommendations based on user history and vehicle preferences
