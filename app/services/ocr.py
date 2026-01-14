import easyocr
from pdf2image import convert_from_path
import tempfile
import os

reader = easyocr.Reader(['en'], gpu=False)


def extract_text_from_image(image_path: str) -> str:
    """
    Extract text from image using EasyOCR
    """
    results = reader.readtext(image_path, detail=0)
    return " ".join(results)


def extract_text_from_pdf(pdf_path: str) -> str:
    """
    Convert PDF pages to images and run OCR
    """
    pages = convert_from_path(pdf_path)
    text = []

    for page in pages:
        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as temp_img:
            page.save(temp_img.name)
            text.append(extract_text_from_image(temp_img.name))
            os.remove(temp_img.name)

    return " ".join(text)


def extract_text(file_path: str) -> str:
    """
    Decide OCR method based on file type
    """
    if file_path.lower().endswith(".pdf"):
        return extract_text_from_pdf(file_path)
    else:
        return extract_text_from_image(file_path)

# from paddleocr import PaddleOCR
# from pdf2image import convert_from_path
# import tempfile
# import os

# ocr = PaddleOCR(use_angle_cls=True, lang='en')


# def extract_text_from_image(image_path: str) -> str:
#     result = ocr.ocr(image_path)
#     text = []

#     for line in result:
#         for word in line:
#             text.append(word[1][0])

#     return " ".join(text)


# def extract_text_from_pdf(pdf_path: str) -> str:
#     pages = convert_from_path(pdf_path)
#     text = []

#     for page in pages:
#         with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as temp_img:
#             page.save(temp_img.name)
#             text.append(extract_text_from_image(temp_img.name))
#             os.remove(temp_img.name)

#     return " ".join(text)


# def extract_text(file_path: str) -> str:
#     if file_path.lower().endswith(".pdf"):
#         return extract_text_from_pdf(file_path)
#     else:
#         return extract_text_from_image(file_path)
