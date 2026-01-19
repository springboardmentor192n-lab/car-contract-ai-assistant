from ocr_module.ocr_pipeline import run_ocr_pipeline
from llm_module.local_llm import analyze_contract_locally
import json


def run_full_pipeline(file_path):
    """
    OCR → Rule-based LLM → Structured output
    """

    # Step 1: OCR
    ocr_result = run_ocr_pipeline(file_path)
    extracted_text = ocr_result["extracted_text"]

    # Step 2: LLM-style analysis
    analysis_result = analyze_contract_locally(extracted_text)

    return {
        "ocr_method": ocr_result["method_used"],
        "analysis_result": analysis_result
    }


if __name__ == "__main__":
    result = run_full_pipeline("ocr_module/uploads/sample.pdf")

    print("\n--- OCR Method Used ---")
    print(result["ocr_method"])

    print("\n--- Contract Analysis Output ---")
    print(json.dumps(result["analysis_result"], indent=4, ensure_ascii=False))
