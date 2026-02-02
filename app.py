# app.py
from flask import Flask, render_template, request, jsonify
import os
from llm import extract_text, build_index, ask_llm

import os
os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"

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


if __name__ == "__main__":
    app.run(debug=True)
