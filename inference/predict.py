import joblib

# Load model
model = joblib.load("../models/clause_classifier.pkl")
print("✅ Model loaded successfully")

# Test sentences
test_sentences = [
    "Interest rate shall be 9.5% per annum.",
    "Late payment will attract penalty of 2% per month.",
    "The lease term shall be 36 months.",
    "The customer shall pay monthly EMI of Rs. 15,000.",
    "Mileage limit is 12000 km per year."
]

# ✅ VERY IMPORTANT: model expects LIST of strings (already correct)
preds = model.predict(test_sentences)

# Print results
print("\n📄 Predictions:\n")
for s, p in zip(test_sentences, preds):
    print(f"➡️ {s}")
    print(f"   🔖 Predicted Label: {p}\n")
