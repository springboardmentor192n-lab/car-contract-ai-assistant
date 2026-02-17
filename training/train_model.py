import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report
from sklearn.pipeline import Pipeline
import joblib

# Load dataset
df = pd.read_csv("../data/dataset/sentences1.csv", encoding="latin1")

print(df.columns)

# Drop empty rows
df = df.dropna()

print("After cleaning:", df.shape)

X = df["sentence"]
y = df["label"]

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# ✅ PIPELINE = Vectorizer + Model
pipeline = Pipeline([
    ("tfidf", TfidfVectorizer(
        lowercase=True,
        stop_words="english",
        ngram_range=(1,2),
        max_features=5000
    )),
    ("clf", LogisticRegression(max_iter=1000))
])

# Train
pipeline.fit(X_train, y_train)

# Evaluate
y_pred = pipeline.predict(X_test)
print(classification_report(y_test, y_pred))

# ✅ Save FULL pipeline (not only model)
joblib.dump(pipeline, "../models/clause_classifier.pkl")

print("✅ Pipeline trained and saved successfully!")
