# Dockerfile for Car Lease AI Assistant Backend

# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH=/app/backend:$PYTHONPATH

# Install system dependencies (Poppler for PDF conversion and Tesseract for OCR)
RUN apt-get update && apt-get install -y --no-install-recommends \
    poppler-utils \
    tesseract-ocr \
    libtesseract-dev \
    gcc \
    linux-libc-dev \
    && rm -rf /var/lib/apt/lists/*

# Add Tesseract Language data
RUN apt-get update && apt-get install -y tesseract-ocr-eng

# Set work directory
WORKDIR /app

# Install Python dependencies
COPY backend/requirements.txt /app/requirements.txt
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir pdf2image pytesseract python-dotenv groq gunicorn requests scikit-learn

# Copy the backend code into the container
COPY backend/ /app/backend/
COPY ocr/ /app/ocr/
COPY models/ /app/models/

# Copy the Tesseract config files if needed (Optional depending on how OCR is being called)
# If backend/ocr/text.py sets a static Windows path for Tesseract, we should override it to the standard Linux path: `/usr/bin/tesseract` via an env variable or sed later.

# Expose port (Render binds to $PORT dynamically, but Uvicorn needs a default)
EXPOSE 8000

# Run Uvicorn and bind to 0.0.0.0 and dynamically to the $PORT environment variable expected by Render
CMD gunicorn backend.main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:${PORT:-8000}
