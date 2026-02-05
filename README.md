# 🚗 Car Contract AI Assistant

An AI-powered car lease contract analysis system that extracts key clauses from lease agreements (PDF or image), highlights financial risks, validates VIN using the NHTSA API, and allows users to interact with the contract through a chatbot interface.

---

## 📌 Project Overview

This system processes lease agreements and:

- Extracts structured contract data
- Identifies potential financial risks
- Detects missing or unclear clauses
- Verifies Vehicle Identification Number (VIN) via NHTSA API
- Provides an interactive chatbot interface

The system is built with a modular and explainable architecture to ensure reliability and avoid hallucinated outputs.

---
## 📑 Features
- Upload PDFs or Images of car lease contracts.
- OCR Extraction using Tesseract or other OCR engines.
- Structured Data Extraction with regex rules for:
    - Vehicle details (VIN, brand, model, year)
    - Lease terms (monthly payment, duration, deposit)
    - Mileage limits and excess fees
    - Penalties and buyout options
- LLM‑based Risk Analysis:
    - Flags risky clauses (e.g., vague obligations, hidden fees).
    - Detects missing or unclear clauses (e.g., insurance, maintenance).
- VIN Verification via NHTSA API.
- Interactive Q&A Chatbot to answer contract‑specific questions.
- Streamlit UI for a clean, user‑friendly experience.

---
## 🏗️ System Architecture

User Upload
↓
OCR Layer (pdfplumber / EasyOCR)
↓
Structured Extraction (Rule-Based Regex)
↓
Risk & Clause Analysis
↓
VIN Verification (NHTSA API)
↓
Chatbot Interface (Structured QA)
↓
Streamlit UI
---

## 🛠️ Technologies Used

- Python
- Streamlit
- pdfplumber
- EasyOCR
- Regex-based structured extraction
- NHTSA VIN API
- Git & GitHub

--- 
## 🚀 How to Run

### 1. Clone Repository

git clone <your-repo-url>
cd car-contract-ai-assistant


### 2. Install Dependencies

pip install -r requirements.txt


### 3. Run Application

streamlit run app.py
---

## 🔍 Design Philosophy

- Deterministic extraction for reliability
- No hallucinated financial data
- Modular architecture
- API-based external validation
- Extendable to negotiation assistant

---

## 📈 Future Scope

- Automated negotiation suggestions
- Risk severity scoring
- Clause comparison between contracts
- Full LLM-based RAG chatbot
- Deployment on cloud platform

---
