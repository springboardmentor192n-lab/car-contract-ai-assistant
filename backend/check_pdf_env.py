
import os
import sys
import asyncio

async def check_env():
    output_file = "check_output_v2.txt"
    with open(output_file, "w") as f:
        def log(msg):
            print(msg)
            f.write(msg + "\n")

        log("--- Environment Check V2 ---")
        
        log("\n--- Checking Dependencies ---")
        
        # Check Tesseract
        tesseract_path = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
        if os.path.exists(tesseract_path):
            log(f"[OK] Tesseract found at: {tesseract_path}")
        else:
            log(f"[WARNING] Tesseract NOT found at: {tesseract_path}")
            
        # Check Poppler (User mentioned path)
        poppler_path = r'C:\poppler-25.12.0\Library\bin'
        if os.path.exists(poppler_path):
             log(f"[OK] User Poppler path found: {poppler_path}")
             os.environ["PATH"] += os.pathsep + poppler_path
        else:
             log(f"[WARNING] User Poppler path NOT found: {poppler_path}")

        # Test OCR Service with Fallback Trigger
        log("\n--- Testing OCR Service (Fallback Path) ---")
        try:
            sys.path.append(os.getcwd())
            from services.ocr_service import ocr_service
            
            # Create a PDF with SHORT text to trigger fallback (< 50 chars)
            import fitz
            doc = fitz.open()
            page = doc.new_page()
            # Make text large enough for OCR to see carefully
            page.insert_text((50, 100), "Fallback Test", fontsize=24) 
            doc.save("test_fallback.pdf")
            doc.close()
            log("[INFO] Created test_fallback.pdf (content length < 50)")

            # Test with the created PDF
            text = await ocr_service.extract_text_from_file("test_fallback.pdf", "test_fallback.pdf")
            log(f"OCR Service Result: '{text.strip()}'")
            
            if "Fallback Test" in text:
                log("[SUCCESS] OCR Service extracted text (likely via fallback if logic holds).")
            else:
                log("[FAILURE] OCR Service did NOT extract expected text.")
                
        except Exception as e:
            log(f"[CRITICAL FAIL] OCR Service invocation failed: {e}")
            import traceback
            log(traceback.format_exc())

if __name__ == "__main__":
    asyncio.run(check_env())
