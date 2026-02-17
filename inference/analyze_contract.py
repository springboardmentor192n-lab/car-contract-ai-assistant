import os
import sys
import re
import json
import joblib

# --------------------------------------------------
# Path setup (project root)
# --------------------------------------------------
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, BASE_DIR)

# --------------------------------------------------
# Imports
# --------------------------------------------------
from ocr.text import extract_text

# --------------------------------------------------
# Paths
# --------------------------------------------------
MODEL_PATH = os.path.join(BASE_DIR, "models", "clause_classifier.pkl")
PDF_PATH = os.path.join(BASE_DIR, "data", "raw_pdfs", "sample.pdf")
OUTPUT_PATH = os.path.join(BASE_DIR, "output.json")

# --------------------------------------------------
# Helpers
# --------------------------------------------------
def split_into_sentences(text: str):
    sentences = re.split(r'(?<=[.!?])\s+', text)
    return [s.strip() for s in sentences if len(s.strip()) > 5]

# --------------------------------------------------
# Sanity checks
# --------------------------------------------------
if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"❌ Model not found at: {MODEL_PATH}")

if not os.path.exists(PDF_PATH):
    raise FileNotFoundError(f"❌ PDF not found at: {PDF_PATH}")

# --------------------------------------------------
# Load ML model
# --------------------------------------------------
print("📦 Loading clause classification model...")
model = joblib.load(MODEL_PATH)
print("✅ Model loaded successfully")

# --------------------------------------------------
# Step 1: OCR
# --------------------------------------------------
print("📄 Extracting text from PDF...")
try:
    text = extract_text(PDF_PATH)
except Exception as e:
    raise RuntimeError(f"❌ OCR failed: {str(e)}")

# --------------------------------------------------
# Step 2: Sentence splitting
# --------------------------------------------------
sentences = split_into_sentences(text)
print(f"🧾 Total sentences extracted: {len(sentences)}")

if not sentences:
    raise ValueError("❌ No readable sentences found. OCR output may be empty.")

# --------------------------------------------------
# Step 3: ML Prediction
# IMPORTANT: Pipeline expects RAW TEXT
# --------------------------------------------------
print("🤖 Classifying clauses...")
predictions = model.predict(sentences)

# --------------------------------------------------
# Step 4: Group by clause label
# --------------------------------------------------
results = {}
for sent, label in zip(sentences, predictions):
    results.setdefault(label, []).append(sent)

# --------------------------------------------------
# Step 5: Print results
# --------------------------------------------------
print("\n" + "=" * 60)
print("📊 CONTRACT ANALYSIS RESULT")
print("=" * 60)

for label, items in results.items():
    print(f"\n🔷 {label} ({len(items)})")
    print("-" * 50)
    for i, s in enumerate(items, 1):
        print(f"{i}. {s}")

print("\n✅ Analysis complete.")

# --------------------------------------------------
# Step 6: Save output to JSON
# --------------------------------------------------
with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
    json.dump(results, f, indent=4, ensure_ascii=False)

print(f"💾 Results saved to: {OUTPUT_PATH}")

