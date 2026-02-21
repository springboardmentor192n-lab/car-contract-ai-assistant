**Car AI Assistant**

Car AI Assistant is a locally hosted full-stack AI application designed to analyze car lease contracts using large language models and perform real-time VIN (Vehicle Identification Number) lookups using government automotive data APIs.

The system integrates modern NLP techniques with structured API-based vehicle data retrieval inside a clean single-page web interface.

** Overview**

This project combines document understanding, semantic search, and instruction-tuned LLM reasoning to simplify automotive paperwork and vehicle data access.

It provides two core functionalities:

Contract Analysis – Upload a lease contract (PDF/Image) and ask natural language questions about its content.

VIN Lookup – Enter a 17-character VIN to retrieve structured vehicle details from the NHTSA database.

** AI Architecture**

The application follows a semantic retrieval + LLM reasoning pipeline:

Contract Document

→ Sentence Embeddings

→ Context Extraction

→ Instruction-Tuned LLM Response

** AI Models Used**

** LLM – Mistral 7B Instruct**

Model: mistralai/Mistral-7B-Instruct-v0.2

Accessed securely via Hugging Face Inference API (using access token authentication).

This 7B parameter instruction-tuned model is responsible for:

Understanding contract context

Interpreting user queries

Generating structured natural language responses

** Embedding Model – Sentence Transformers**

Model: sentence-transformers/all-MiniLM-L6-v2

Used to generate semantic embeddings for:

Contract text representation

Context similarity matching

Improved question-answer relevance

This enables efficient semantic understanding before passing context to the LLM.

** External Integrations**

** NHTSA Vehicle API**

VIN lookup functionality integrates with the National Highway Traffic Safety Administration (NHTSA) public API to retrieve structured vehicle specifications based on a VIN.

** Hugging Face API**

Model inference is performed via Hugging Face using secure token-based authentication.

** Tech Stack**

Backend

Python

Flask

Requests

Sentence-Transformers

Hugging Face Inference API

Frontend



HTML5

CSS3

Vanilla JavaScript (Fetch API)

setup and requirements:

1. System Requirements

Python 3.9 or 3.10

Minimum 8GB RAM recommended

Active internet connection (required for Hugging Face API and NHTSA API access)

2. Required External Tools

The project uses OCR and PDF image processing. The following tools must be installed separately:

Tesseract OCR

Install Tesseract OCR from:
https://github.com/tesseract-ocr/tesseract

Ensure the installation directory is added to your system PATH.

Poppler (Required for PDF Image Conversion)

Install Poppler for your operating system and add it to PATH.
This is required for processing scanned PDF documents.

3. Clone the Repository
git clone <your-repository-url>
cd car-ai-assistant
4. Create and Activate Virtual Environment
python -m venv .venv

Windows:

.venv\Scripts\activate

macOS/Linux:

source .venv/bin/activate
5. Install Project Dependencies:
pip install -r requirements.txt,
6. Configure Environment Variables

Set your Hugging Face API token as an environment variable.

Windows (PowerShell):

setx HF_TOKEN "your_token_here"

macOS/Linux:

export HF_TOKEN="your_token_here"

Restart your terminal after setting the variable.

7. Run the Application

python app.py

Open the application in your browser:

http://127.0.0.1:5000



<img width="1863" height="938" alt="Screenshot 2026-02-19 112109" src="https://github.com/user-attachments/assets/82dff2b7-a3fe-49fe-b0db-0988cbef5746" />

<img width="1869" height="914" alt="Screenshot 2026-02-19 112126" src="https://github.com/user-attachments/assets/38b02a5c-268a-4193-84a8-f90020f24ed5" />

<img width="1710" height="931" alt="Screenshot 2026-02-19 163201" src="https://github.com/user-attachments/assets/531e12f5-e344-468e-8d50-6d4a9826523b" />


