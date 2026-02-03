from ocr_module.ocr_pipeline import run_ocr_pipeline
from llm_module.local_llm import analyze_contract_locally
import json
from llm_module.chatbot import ask_contract_question

from ocr_module.ocr_pipeline import run_ocr_pipeline

from ocr_module.ocr_pipeline import run_ocr_pipeline
from llm_module.local_llm import analyze_contract_locally

def run_full_pipeline(file_path):
    ocr_result = run_ocr_pipeline(file_path)

    structured_data = analyze_contract_locally(
        ocr_result["extracted_text"]
    )

    return {
        "ocr_method": ocr_result["method_used"],
        "text": ocr_result["extracted_text"],
        "analysis": structured_data,
        "raw_text": ocr_result["extracted_text"]
    }




if __name__ == "__main__":
    result = run_full_pipeline("ocr_module/uploads/sample.pdf")

    print("\n--- OCR Method Used ---")
    print(result["ocr_method"])

    print("\n--- Contract Analysis Output ---")
    print(json.dumps(result["analysis_result"], indent=4, ensure_ascii=False))
