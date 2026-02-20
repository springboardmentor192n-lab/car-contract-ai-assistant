import ollama

print("Testing...")

response = ollama.chat(
    model="llama2",
    messages=[{"role": "user", "content": "Say hello in one sentence"}]
)

print(response["message"]["content"])
