from llm_module.rag_engine import (
    build_vector_store,
    retrieve_context,
    ask_llm_with_context
)

def ask_contract_question(contract_text, question):
    """
    Full RAG-based chatbot
    """

    index, chunks = build_vector_store(contract_text)

    context = retrieve_context(index, chunks, question)

    answer = ask_llm_with_context(context, question)

    return answer
