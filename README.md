🚗 Car Contract AI Assistant

An AI-powered system that extracts, analyzes, and explains car lease agreements using OCR, Large Language Models (LLMs), and real-world vehicle data APIs.

---

📌 Project Overview

The *Car Contract AI Assistant* is designed to help users understand car lease agreements easily.  
It takes a car lease contract (PDF or image) as input, extracts the text using OCR, identifies important vehicle details like the *VIN*, fetches official vehicle information using the *NHTSA API*, and performs *AI-based contract analysis and question answering*.

This project demonstrates the practical integration of *OCR, NLP, LLMs, APIs, and a Streamlit-based user interface*.

---

✨ Key Features

- 📄 *OCR-based Contract Text Extraction*
- 🔍 *Automatic VIN Detection from Contract*
- 🚘 *Vehicle Details Retrieval using NHTSA API*
- 🤖  *AI-powered Contract Analysis*
- 💬 *Interactive Chatbot for Contract Q&A*
- 🖥️ *User-friendly Streamlit Web Interface*

---

 🛠️ Technologies Used

- *Python*
- *Streamlit* – Web UI
- *pdfplumber* – OCR for PDF text extraction
- *Regular Expressions (Regex)* – VIN extraction
- *NHTSA Vehicle API*– Vehicle data lookup
- *Ollama (LLM)* – AI analysis and chatbot
- *Natural Language Processing (NLP)*

---

📂 Project Structure
car-contract-ai-assistant/
├── app.py               # Main Streamlit application 
├── ocr_pipeline.py      # OCR logic for extracting text ├── vin.py               # VIN extraction logic 
├── vin_api.py           # NHTSA API integration 
├── llm_analysis.py      # AI-based contract analysis
├── chatbot.py           # Contract Q&A chatbot
├── requirements.txt     # Python dependencies 
├── README.md            # Project documentation
├── car_lease_with_vin.pdf
├── CAR LEASE AGREEMENT.pdf
---

⚙️ How the System Works

1. User uploads a *car lease contract (PDF/Image)*
2. OCR extracts the *contract text*
3. VIN is automatically detected from the text
4. Vehicle details are fetched from *NHTSA API*
5. AI analyzes the contract clauses
6. User can ask *natural language questions* about the contract

---

▶️ How to Run the Project

1️⃣ Install Dependencies
```bash
pip install -r requirements.txt
2️⃣ Start Ollama (LLM Server)
Bash
ollama serve
3️⃣ Pull LLM Model (if not already done)
Bash
ollama pull llama2
4️⃣ Run the Streamlit App
Bash
streamlit run app.py
5️⃣ Open in Browser

http://localhost:8501
🧪 Sample Use Cases
Understanding penalties for late payments
Identifying lease duration and obligations
Fetching official vehicle safety information
Asking contract-related questions in simple language
🎯 Project Highlights
Real-world API integration (NHTSA)
End-to-end AI pipeline (OCR → NLP → LLM)
Practical use of AI for legal/contract analysis
Beginner-friendly but industry-relevant project
🚀 Future Enhancements
Support for scanned image-only contracts
Clause-level risk scoring
Multi-language contract analysis
Cloud deployment (AWS / GCP)
Contract comparison feature
👩‍💻 Author
Darpana Khaspa
AI/ML Intern - Infosys Springboard Program
