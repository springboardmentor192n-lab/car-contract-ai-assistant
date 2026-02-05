Car Contract AI Assistant

An AI-powered system designed to analyze car lease agreements using OCR, Large Language Models (LLMs), VIN validation, and an interactive chatbot interface.

Project Overview

The Car Contract AI Assistant automates the review and understanding of car lease agreements by:

Extracting text from PDFs and scanned documents using OCR

Analyzing contract clauses with a Large Language Model

Detecting and validating vehicle VIN details

Allowing users to ask contract-related questions through a chatbot

The system follows a modular architecture and is implemented as a web application using Streamlit.

Key Features
OCR Pipeline

Supports both text-based and scanned PDFs

Handles image formats such as JPG and PNG

Built using pdfplumber and Tesseract OCR

LLM-Based Contract Analysis

Automatic contract summarization

Detection of lease duration and payment details

Identification of potentially risky clauses

Suggestions for negotiation and improvements

VIN Detection and Validation

Automatic extraction of VIN from contracts

Vehicle detail validation using the NHTSA VIN Decoder API

Contract Chatbot

Natural language question-answering on contract content

Powered by a local LLM using Ollama

Interactive User Interface

Web-based UI built with Streamlit

Separate sections for OCR output, AI analysis, VIN validation, and chatbot

Tech Stack

Programming Language: Python

OCR Tools: pdfplumber, pytesseract, pdf2image, Pillow

LLM: Ollama (LLaMA 3 – Local)

UI Framework: Streamlit

External API: NHTSA VIN Decoder

Version Control: Git and GitHub

Project Structure
car-contract-ai-assistant/
│
├── app.py              # Streamlit UI
├── ocr_pipeline.py     # OCR logic
├── llm_analysis.py     # LLM-based contract analysis
├── chatbot.py          # Contract Q&A chatbot
├── vin_api.py          # VIN validation via API
├── requirements.txt
└── README.md

How to Run the Project
Step 1: Install Dependencies
pip install -r requirements.txt

Step 2: Run the Streamlit Application
streamlit run app.py

Step 3: Upload a car lease agreement (PDF or image) and start analysis
Current Status

OCR pipeline completed

LLM-based contract analysis implemented

VIN validation integrated

Contract chatbot functionality added

UI and chatbot interaction improvements are ongoing

Internship Context

This project was developed as part of the Infosys Springboard – AI/ML Internship Program, with a focus on:

Applied Artificial Intelligence

Modular system design

End-to-end AI application development

Future Enhancements

End-to-end negotiation chatbot workflow

Risk scoring mechanism for contracts

Database integration for contract storage

Improved UI/UX and response persistence
