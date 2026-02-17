import os
import csv
import nltk

nltk.download('punkt')
from nltk.tokenize import sent_tokenize

# Base folder
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Input: cleaned text files
INPUT_FOLDER = os.path.join(BASE_DIR, "output_text")

# Output: dataset folder
DATASET_FOLDER = os.path.join(BASE_DIR, "dataset")
os.makedirs(DATASET_FOLDER, exist_ok=True)

# CSV file path
OUTPUT_CSV = os.path.join(DATASET_FOLDER, "sentences.csv")

print("📄 Creating dataset...")

rows = []

# Har text file ke liye
for file in os.listdir(INPUT_FOLDER):
    if file.endswith(".txt"):
        path = os.path.join(INPUT_FOLDER, file)

        with open(path, "r", encoding="utf-8") as f:
            text = f.read()

        # Text → sentences
        sentences = sent_tokenize(text)

        for s in sentences:
            s = s.strip()
            if len(s) > 10:
                rows.append([s, ""])   # label empty for now

print("Total sentences:", len(rows))

# CSV me save
with open(OUTPUT_CSV, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["sentence", "label"])
    writer.writerows(rows)

print("✅ Dataset created at:", OUTPUT_CSV)
