# Car Lease AI Assistant

This project consists of a Flutter frontend and a Python FastAPI backend.

## Prerequisites

-   Flutter SDK
-   Python 3.10+
-   Tesseract OCR (Installed and added to PATH)

## 1. Backend Setup

The backend handles PDF analysis using OCR and ML models.

### Install Dependencies
```bash
pip install -r backend/requirements.txt
pip install pdf2image pytesseract python-dotenv groq
```

### Run Backend
From the root directory:
```bash
uvicorn backend.main:app --host 127.0.0.1 --port 8000 --reload
```
The API will be available at `http://127.0.0.1:8000`.
Docs: `http://127.0.0.1:8000/docs`

## 2. Frontend Setup

The frontend is a Flutter app located in the `carAi` folder.

### Install Dependencies
```bash
cd carAi
flutter pub get
```

### Run App
```bash
flutter run
```
Select your target device (Chrome, Windows, Android Emulator).

## 3. Usage

1.  Open the Flutter app.
2.  Navigate to **Contract Analysis**.
3.  Click **Upload** to select a PDF contract.
4.  The app will send the PDF to the backend and display:
    -   AI Summary
    -   Fairness Score
    -   Extracted Terms
    -   Price Estimation (if VIN is found)

## Troubleshooting

-   **Backend Connection**: Ensure the backend is running on `127.0.0.1:8000`. If running on an Android Emulator, you may need to change the base URL in `lib/services/api_service.dart` to `10.0.2.2:8000`.
-   **OCR Errors**: Ensure Tesseract is installed and the path in `backend/ocr/text.py` matches your installation.
