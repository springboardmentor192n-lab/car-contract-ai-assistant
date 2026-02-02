# ai_engine.py
import os
import pdfplumber
import pytesseract
from pdf2image import convert_from_path
from PIL import Image
import numpy as np
import faiss
from sentence_transformers import SentenceTransformer
from langchain_text_splitters import RecursiveCharacterTextSplitter
from huggingface_hub import InferenceClient

# ---------- OCR ----------
def extract_text(file_path):
    text = ""
    if file_path.endswith(".pdf"):
        with pdfplumber.open(file_path) as pdf:
            for page in pdf.pages:
                text += page.extract_text() or ""

        if len(text.strip()) < 50:
            for img in convert_from_path(file_path):
                text += pytesseract.image_to_string(img)

    return text


# ---------- VECTOR STORE ----------
embedder = SentenceTransformer("all-MiniLM-L6-v2")
splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)

chunks = []
index = None


def build_index(text):
    global chunks, index
    chunks = splitter.split_text(text)
    vectors = embedder.encode(chunks)

    dim = vectors.shape[1]
    index = faiss.IndexFlatL2(dim)
    index.add(np.array(vectors))


def retrieve(query, k=5):
    q_vec = embedder.encode([query])
    _, ids = index.search(np.array(q_vec), k)
    return "\n\n".join([chunks[i] for i in ids[0]])


# ---------- LLM ----------



client = InferenceClient(
    provider="featherless-ai",
    api_key=os.environ["HF_TOKEN"],
)


def ask_llm(question):
    context = retrieve(question)

    messages = [
        {
            "role": "system",
            "content": "You are a car lease contract expert. Use only the provided contract text and highlight risks."
        },
        {
            "role": "user",
            "content": f"""
CONTRACT:
{context}

QUESTION:
{question}
"""
        }
    ]

    response = client.chat_completion(
        model="mistralai/Mistral-7B-Instruct-v0.2",
        messages=messages,
        max_tokens=300
    )

    return response.choices[0].message["content"]