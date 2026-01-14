from ocr_module.ocr_pipeline import run_ocr_pipeline

result = run_ocr_pipeline("ocr_module/uploads/car.jpg")

print("Method Used:", result["method_used"])
print("\nExtracted Text Preview:\n")
print(result["extracted_text"][:500])
