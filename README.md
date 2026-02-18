# 🚗 Car Lease AI Assistant

An AI-powered tool designed to analyze car lease contracts, extract key terms, and provide intelligent insights using **OCR** and **Large Language Models (LLMs)**.

---

## 🚀 Deployment

Live Demo: [View Live App](https://github.com/springboardmentor192n-lab/car-contract-ai-assistant) *(Update with your specific deployment URL)*

---

## ✨ Features

- **📄 Document Analysis**: Upload car lease contracts (PDF/Images) for automated review.
- **👁️ OCR Integration**: Uses Tesseract OCR to extract text from scanned documents and images.
- **🤖 AI Insights**: Leverages Ollama (Gemma 3) to answer complex questions about lease terms, fees, and obligations.
- **💻 Modern Interface**: Clean and responsive web interface built with React and Vite.

---

## 📸 Screenshots

![Application UI](screenshots/app_screenshot.png)
*AI-powered contract analysis dashboard*

## 🛠️ Tech Stack

- **Backend**: Python, FastAPI, Uvicorn
- **Frontend**: React, Vite, Vanilla CSS
- **AI/ML**: Ollama (Gemma 3:1b), PyTesseract (OCR)
- **Environment**: Window, Node.js, npm

---

## 📂 Project Structure

```text
raghuAi/
├── backend/            # Python FastAPI backend (app.py, main.py)
├── frontend/           # React + Vite frontend
├── uploads/            # Temporary storage for uploaded documents
├── ocr_pipline.py      # OCR processing logic
├── llm_analysis.py      # AI analysis integration
└── README.md           # Project documentation
```

---

## 🚀 Getting Started

### 📋 Prerequisites

1.  **Python 3.8+**
2.  **Node.js & npm**
3.  **Ollama**: 
    - Install from [ollama.com](https://ollama.com/)
    - Download the model: `ollama pull gemma3:1b`
4.  **Tesseract OCR**:
    - **Windows**: Download and install from [UB-Mannheim](https://github.com/UB-Mannheim/tesseract/wiki).
    - **Important**: Ensure install path is `C:\Program Files\Tesseract-OCR`.

### ⚙️ Installation

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd raghuAi
    ```

2.  **Backend Setup**:
    ```bash
    pip install -r requirements.txt
    ```

3.  **Frontend Setup**:
    ```bash
    cd frontend
    npm install
    cd ..
    ```

---

## 🏃 Execution

To run the application, you need to start **both** the backend and the frontend services.

### 1️⃣ Start the Backend
In your main terminal, run:
```bash
python main.py
```
The backend will be available at `http://localhost:8000`.

### 2️⃣ Start the Frontend
In a **new** terminal window, run:
```bash
cd frontend
npm run dev
```
The frontend will provide a URL (usually `http://localhost:5173`). Open this URL in your browser.

---

## 🔍 Troubleshooting

- **"Server not found"**: Ensure the backend terminal shows "Uvicorn running on http://0.0.0.0:8000".
- **"Tesseract not found"**: Verify Tesseract is installed at the expected path (see Prerequisites).
- **"Ollama Error"**: Ensure the Ollama app is running and you have downloaded the `gemma3:1b` model.

---

*Built with ❤️ for better contract transparency.*

🤝 **Contact & Contribution**  
Author: [Raghukn21](https://github.com/Raghukn21)
