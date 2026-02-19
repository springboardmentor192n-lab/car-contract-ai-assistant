
import os
import sys
import asyncio
import io
from PIL import Image
import fitz

# Add current directory to path
sys.path.append(os.getcwd())

from services.ocr_service import ocr_service
from services.llm_extraction_service import llm_service
from config import settings

async def run_pipeline_test():
    print("--- Pipeline Test V2 ---")
    
    # 1. Check API Keys
    print(f"OpenAI Key Configured: {bool(settings.OPENAI_API_KEY)}")
    print(f"Groq Key Configured: {bool(settings.GROQ_API_KEY)}")
    
    # 2. Check Uploads Dir
    if not os.path.exists("uploads"):
        os.makedirs("uploads")
        print("Created uploads directory.")
    
    test_pdf_path = "uploads/test_pipeline.pdf"
    
    # 3. Create a Test PDF (Image based to force OCR)
    print("\n--- Creating Test PDF (Image-based) ---")
    doc = fitz.open()
    page = doc.new_page()
    page.insert_text((50, 100), "This is a test contract for pipeline verification.\nTerm: 12 months.\nPenalty: $500.", fontsize=16)
    
    # Convert to image and back to PDF to simulate scanned PDF
    pix = page.get_pixmap()
    img_data = pix.tobytes("png")
    img = Image.open(io.BytesIO(img_data))
    img.save("uploads/temp_page.png")
    
    img_pdf = fitz.open()
    img_page = img_pdf.new_page(width=img.width, height=img.height)
    img_page.insert_image(img_page.rect, filename="uploads/temp_page.png")
    img_pdf.save(test_pdf_path)
    img_pdf.close()
    
    print(f"Created {test_pdf_path}")
    
    # 4. Run OCR Service
    print("\n--- Running OCR Service ---")
    try:
        text = await ocr_service.extract_text_from_file(test_pdf_path, "test_pipeline.pdf")
        print(f"OCR extracted {len(text)} characters.")
        print(f"Preview: {text[:100]}...")
        
        if len(text.strip()) == 0:
            print("[FAILURE] OCR returned empty text.")
            return
            
    except Exception as e:
        print(f"[FAILURE] OCR Service threw exception: {e}")
        import traceback
        traceback.print_exc()
        return

    # 5. Run LLM Service
    print("\n--- Running LLM Service ---")
    try:
        extracted = await llm_service.extract_data(text)
        print("LLM Result Type:", type(extracted))
        if "error" in extracted:
            print(f"[FAILURE] LLM Returned Error: {extracted['error']}")
        else:
            print("[SUCCESS] LLM Extracted Data successfully.")
            print(extracted)
            
    except Exception as e:
        print(f"[FAILURE] LLM Service threw exception: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(run_pipeline_test())
