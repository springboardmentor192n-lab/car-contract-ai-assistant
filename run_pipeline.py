from ocr_module.ocr_pipeline import run_ocr_pipeline
from llm_module.local_llm import analyze_contract_locally
import json


def run_full_pipeline(file_path):
    """
    Runs the complete end-to-end pipeline:
    OCR -> Local LLM -> Structured JSON output
    """

    # Step 1: OCR
    ocr_result = run_ocr_pipeline(file_path)
    extracted_text = ocr_result["extracted_text"]

    # Step 2: Local LLM Analysis
    llm_result = analyze_contract_locally(extracted_text)

    return {
        "ocr_method": ocr_result["method_used"],
        "analysis_result": llm_result
    }


if __name__ == "__main__":
    result = run_full_pipeline("ocr_module/uploads/sample.pdf")

    print("\n--- OCR Method Used ---")
    print(result["ocr_method"])

    print("\n--- Contract Analysis Output ---")
    print(json.dumps(result["analysis_result"], indent=4))
