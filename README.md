Car Contract AI Assistant ( Yash )

A production-oriented AI system for automated analysis of car lease agreements using OCR, Large Language Models, VIN validation, and an interactive question-answering interface.

Overview

Car Contract AI Assistant is designed to reduce manual effort in reviewing vehicle lease agreements by transforming unstructured contract documents into structured, explainable insights.

The system performs document ingestion, semantic contract analysis, vehicle identity verification, and conversational querying through a single unified interface.

Core Capabilities
Document Ingestion and OCR

Processes both digital and scanned lease agreements

Supports PDF, JPG, and PNG formats

Robust text extraction using pdfplumber and Tesseract OCR

Intelligent Contract Analysis

High-level contract summarization

Automated extraction of lease duration, payment terms, and obligations

Identification of high-risk or ambiguous clauses

Context-aware improvement and negotiation suggestions

VIN Extraction and Verification

Automatic detection of Vehicle Identification Number (VIN)

Real-time validation using the NHTSA VIN Decoder API

Vehicle metadata verification against official records

Contract Question-Answering

Natural language interaction with contract content

Context-preserving responses powered by a local LLM via Ollama

Eliminates the need to manually search contract clauses

Web-Based User Interface

Interactive Streamlit application

Clearly separated analysis modules for transparency

Real-time feedback and results visualization

Technology Stack

Language: Python

OCR: pdfplumber, pytesseract, pdf2image, Pillow

Large Language Model: Ollama (LLaMA 3 – Local)

Frontend: Streamlit

External API: NHTSA VIN Decoder

Version Control: Git, GitHub

System Architecture
car-contract-ai-assistant/
│
├── app.py              # Streamlit application layer
├── ocr_pipeline.py     # Document OCR and preprocessing
├── llm_analysis.py     # Semantic contract analysis engine
├── chatbot.py          # Conversational contract assistant
├── vin_api.py          # VIN extraction and validation
├── requirements.txt
└── README.md

Execution Guide
Dependency Installation
pip install -r requirements.txt

Application Startup
streamlit run app.py

Usage

Upload a car lease agreement (PDF or image) to receive structured insights, verified vehicle details, and conversational explanations.

Project Status

OCR pipeline implemented and stable

Contract analysis module integrated with LLM

VIN detection and validation operational

Chatbot interaction functional

UI refinements and conversational improvements in progress

Academic and Internship Context

Developed under the Infosys Springboard – AI/ML Internship Program, emphasizing:

Applied Artificial Intelligence systems

Scalable modular design

Real-world document intelligence workflows

Roadmap

Multi-step negotiation chatbot flows

Quantitative risk scoring for lease contracts

Persistent storage and contract history tracking

Enhanced UI/UX and response memory
