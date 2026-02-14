# 🚗 Car Contract AI Assistant

An AI-powered contract analysis system designed to help users understand car lease agreements before signing. The system extracts key clauses, highlights risks, verifies VIN details using a government API, and provides a conversational chatbot interface for interactive contract understanding.

---

## 📌 Project Objective

Car lease and loan contracts are often complex and difficult to understand. This project aims to:

- Simplify contract language
- Extract important financial terms
- Identify risky clauses
- Highlight missing or unclear information
- Allow users to ask natural language questions about their contract
- Increase user confidence before signing

---

## 🧠 Core Functionality

### 1️⃣ Document Upload & OCR Processing

Users can upload:
- PDF contracts
- Image-based contracts (JPG, PNG)

The system:
- Uses **pdfplumber** for text-based PDFs
- Uses **EasyOCR** for scanned images
- Converts the document into machine-readable text

---

### 2️⃣ Structured Contract Extraction

The system extracts:

#### Vehicle Details
- VIN (Vehicle Identification Number)
- Brand / Manufacturer
- Model
- Year

#### Lease Terms
- Lease duration (months)
- Monthly payment
- Security deposit
- Down payment

#### Mileage Terms
- Annual mileage limit
- Excess mileage charges

#### Penalties & Fees
- Late payment fee
- Early termination fee

#### Purchase Option
- Buyout availability
- Buyout price

Each field includes a simple explanation for user clarity.

---

### 3️⃣ Risk & Missing Clause Detection

The system analyzes contract text to identify:

- Financial risk clauses
- Early termination penalties
- Excess mileage fees
- Missing purchase option details
- Unclear insurance responsibilities

This ensures users are aware of potential risks.

---

### 4️⃣ VIN Verification (NHTSA API Integration)

If a VIN is detected:

- The system validates it using the official **NHTSA VIN API**
- Confirms manufacturer
- Confirms model year
- Provides external validation layer

This adds real-world credibility and reduces fraud risk.

---

### 5️⃣ Contract-Aware Chatbot (RAG Architecture)

The chatbot allows users to ask questions such as:

- "What is the lease duration?"
- "How much is the security deposit?"
- "Is there a late payment fee?"
- "Is the vehicle under warranty?"
- "Is this car safe to buy?"

The system uses a Retrieval-Augmented Generation (RAG) architecture:

1. Contract text is chunked
2. Relevant sections are retrieved
3. Local LLM (via Ollama) generates grounded responses
4. If information is missing, it clearly states so

The chatbot answers only from the contract content to prevent hallucination.

---

## 🏗 System Architecture

User Upload
↓
OCR Layer (pdfplumber / EasyOCR)
↓
Text Cleaning
↓
Structured Extraction
↓
Risk & Missing Clause Detection
↓
VIN Verification (NHTSA API)
↓
RAG-based Chatbot
↓
Streamlit UI

---

## 🛠 Technologies Used

- Python
- Streamlit
- pdfplumber
- EasyOCR
- Regex-based extraction
- FAISS (vector search)
- sentence-transformers (embeddings)
- Ollama (Local LLM)
- NHTSA VIN API
- Git & GitHub

---

## 🚀 Deployment

🔗 **Live Deployment Link:**  
_(Add your deployed Streamlit link here — mandatory)_

Example:

---

## 📸 Screenshots & Demo

### Screenshots
[Upload Interface](screenshots/upload.png)
[Upload Interface](screenshots/ex1.png)
[Upload Interface](screenshots/vin_verify.png)
[Chatbot Interface](screenshots/chatbot.png)

---
## ⚠️ Challenges Faced

Handling OCR inconsistencies from scanned images

Managing memory limitations for local LLM models

Preventing hallucination in chatbot responses

Improving RAG retrieval accuracy

Handling different contract formats

Maintaining deterministic extraction reliability
--- 

## 📉 Limitations

Performance depends on document quality

Small local models may misinterpret complex clauses

Retrieval accuracy varies based on chunking

Does not replace legal advice

Limited by local hardware constraints
---

## 📈 Future Enhancements

Risk severity scoring system

Negotiation suggestion engine

Clause comparison across multiple contracts

Cloud deployment with larger LLM

Automatic contract summary generator

Financial impact calculator
---

## ⚖ Disclaimer

This system provides AI-assisted analysis for informational purposes only. It does not constitute legal or financial advice. Users should consult a qualified professional before making financial decisions.