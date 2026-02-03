import streamlit as st
import tempfile
from run_pipeline import run_full_pipeline
from llm_module.chatbot import ask_contract_question

st.set_page_config(page_title="Car Contract AI Assistant", layout="wide")

st.title("🚗 Car Contract AI Assistant")

# -------------------------
# Initialize session state
# -------------------------
if "contract_text" not in st.session_state:
    st.session_state.contract_text = ""

if "analysis" not in st.session_state:
    st.session_state.analysis = {}

if "ocr_method" not in st.session_state:
    st.session_state.ocr_method = ""

# -------------------------
# Upload file
# -------------------------
uploaded_file = st.file_uploader(
    "Upload Lease Agreement (PDF / Image)",
    type=["pdf", "jpg", "jpeg", "png"]
)

# -------------------------
# Run OCR
# -------------------------
if uploaded_file and st.button("Run OCR & AI Analysis"):

    # ✅ SAVE FILE TO TEMP LOCATION
    with tempfile.NamedTemporaryFile(delete=False, suffix=uploaded_file.name) as tmp:
        tmp.write(uploaded_file.read())
        temp_path = tmp.name

    with st.spinner("Processing document..."):
        result = run_full_pipeline(temp_path)

        st.session_state.contract_text = result["text"]
        st.session_state.analysis = result["analysis"]
        st.session_state.ocr_method = result["ocr_method"]
        st.session_state.contract_text = result["raw_text"]

    st.success("Analysis completed!")

# -------------------------
# DISPLAY RESULTS
# -------------------------
if st.session_state.contract_text:

    st.subheader("📄 OCR Method Used")
    st.write(st.session_state.ocr_method)

    st.subheader("📊 Extracted Contract Details")

    for section, fields in st.session_state.analysis.items():
        st.markdown(f"### {section.replace('_', ' ').title()}")

        if isinstance(fields, dict):
            for key, value in fields.items():
                st.markdown(f"**{key.replace('_',' ').title()}**")
                st.write(value.get("value") or "Not available")
                st.caption(value.get("explanation", ""))

        elif isinstance(fields, list):
            for item in fields:
                st.warning(item)

    # -------------------------
    # CHAT SECTION
    # -------------------------
    st.subheader("💬 Ask Questions About the Contract")

    question = st.text_input("Ask a question about this contract:")

    if question:
        answer = ask_contract_question(
            st.session_state.analysis,
            question
        )

        st.markdown("### ✅ Answer")
        st.write(answer)
