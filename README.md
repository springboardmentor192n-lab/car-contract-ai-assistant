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

<img width="1863" height="938" alt="Screenshot 2026-02-19 112109" src="https://github.com/user-attachments/assets/82dff2b7-a3fe-49fe-b0db-0988cbef5746" />

<img width="1869" height="914" alt="Screenshot 2026-02-19 112126" src="https://github.com/user-attachments/assets/38b02a5c-268a-4193-84a8-f90020f24ed5" />

<img width="1710" height="931" alt="Screenshot 2026-02-19 163201" src="https://github.com/user-attachments/assets/531e12f5-e344-468e-8d50-6d4a9826523b" />


