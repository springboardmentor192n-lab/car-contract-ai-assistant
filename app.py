# app.py
from flask import Flask, render_template, request, jsonify
import os
from vin_lookup import lookup_vin
from llm import extract_text, build_index, ask_llm
import os
os.environ["TRANSFORMERS_NO_ADVISORY_WARNINGS"] = "1"

app = Flask(__name__)
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/analyze", methods=["POST"])
def analyze():
    file = request.files["file"]
    question = request.form["question"]
    path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(path)
    text = extract_text(path)
    build_index(text)
    answer = ask_llm(question)
    return jsonify({"result": answer})

# ---------- VIN LOOKUP ----------
@app.route("/vin", methods=["POST"])
def vin_lookup_route():
    data = request.get_json()
    vin = data.get("vin")
    if not vin:
        return jsonify({"error": "VIN is required"}), 400
    result = lookup_vin(vin)
    return jsonify(result)

# ---------- RUN ----------
if __name__ == "__main__":
    app.run(debug=True)
