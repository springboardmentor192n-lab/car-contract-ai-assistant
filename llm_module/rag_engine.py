# llm_module/rag_engine.py

from sentence_transformers import SentenceTransformer
import faiss
import numpy as np
import ollama

# Load embedding model once
embedding_model = SentenceTransformer("all-MiniLM-L6-v2")


def build_vector_store(contract_text):
    paragraphs = contract_text.split("\n\n")

    chunks = []
    for p in paragraphs:
        if len(p.strip()) > 50:
            chunks.append(p.strip())

    embeddings = embedding_model.encode(chunks)

    dimension = embeddings.shape[1]
    index = faiss.IndexFlatL2(dimension)
    index.add(np.array(embeddings))

    return index, chunks





def retrieve_context(index, chunks, question, top_k=8):
    """
    Retrieves most relevant contract chunks
    """
    query_embedding = embedding_model.encode([question])
    D, I = index.search(np.array(query_embedding), top_k)

    relevant_chunks = [chunks[i] for i in I[0]]
    return "\n".join(relevant_chunks)


def ask_llm_with_context(context, question):
    """
    Sends retrieved context to local Ollama model
    """

    prompt = f"""
You are a contract analysis assistant.

You MUST answer strictly from the provided contract context.
If the information exists in the context, extract and state it clearly.
DO NOT guess.
DO NOT assume.
DO NOT invent details.

If information is missing, say:
"The contract does not mention this."

Context:
{context}

Question:
{question}

Answer:
"""

    response = ollama.chat(
        model="tinyllama",
        messages=[{"role": "user", "content": prompt}]
    )

    return response["message"]["content"]
