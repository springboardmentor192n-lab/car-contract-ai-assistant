import streamlit as st
import tempfile
from run_pipeline import run_full_pipeline
from llm_module.chatbot import ask_contract_question
from llm_module.vin_api import verify_vin_with_nhtsa

st.set_page_config(page_title="Car Lease Contract AI Assistant", page_icon="🚗", layout="wide")

st.markdown("""
    <h1 style='text-align: center; color: #2E86C1;'>🚗 Car Lease Contract AI Assistant</h1>
    <p style='text-align: center; font-size: 18px;'>Upload, analyze, and negotiate your car lease agreement with AI-powered insights.</p>
""", unsafe_allow_html=True)

# -------------------------
# Initialize session state
# -------------------------
if "contract_text" not in st.session_state:
    st.session_state.contract_text = ""

if "analysis" not in st.session_state:
    st.session_state.analysis = {}

if "ocr_method" not in st.session_state:
    st.session_state.ocr_method = ""

if "vin_data" not in st.session_state:
    st.session_state.vin_data = None

# -------------------------
# Upload file
# -------------------------
with st.expander("📤 Upload Lease Agreement", expanded=True):
    uploaded_file = st.file_uploader("Choose a PDF or image file", type=["pdf", "jpg", "jpeg", "png"])
    st.caption("Max size: 200MB • Supported formats: PDF, JPG, PNG")
    if uploaded_file:
        st.success(f"Uploaded: {uploaded_file.name}")

# -------------------------
# Run OCR
# -------------------------
if uploaded_file and st.button("Run OCR & AI Analysis"):
    file_extension = "." + uploaded_file.name.split(".")[-1]
    with tempfile.NamedTemporaryFile(delete=False, suffix=file_extension) as tmp:
        tmp.write(uploaded_file.getbuffer())
        temp_path = tmp.name

    with st.spinner("Processing document..."):
        result = run_full_pipeline(temp_path)

        st.session_state.contract_text = result["text"]
        st.session_state.analysis = result["analysis"]
        st.session_state.ocr_method = result["ocr_method"]

        # Reset VIN data when new file uploaded
        st.session_state.vin_data = None

    st.success("Analysis completed!")

# -------------------------
# DISPLAY RESULTS
# -------------------------
if st.session_state.contract_text:

    st.subheader("📄 OCR Method Used")
    st.write(st.session_state.ocr_method)

    st.subheader("📊 Extracted Contract Details")

    for section, fields in st.session_state.analysis.items():

        if isinstance(fields, dict):

            with st.container():
                st.markdown(f"## {section.replace('_',' ').title()}")
                st.divider()

                for key, value in fields.items():
                    st.markdown(f"### {key.replace('_',' ').title()}")

                    if value["value"]:
                        st.success(value["value"])
                    else:
                        st.warning("Not available")

                    st.caption(value["explanation"])

    analysis = st.session_state.get("analysis", {})

        # After your dict loop
    risk_flags = analysis.get("risk_flags", [])
    if risk_flags:
        st.subheader("⚠️ Risk Flags")
        for flag in risk_flags:
            st.error(flag)

    missing_clauses = analysis.get("missing_or_unclear_clauses", [])
    if missing_clauses:
        st.subheader("❓ Missing or Unclear Clauses")
        for clause in missing_clauses:
            st.warning(clause)
    # -------------------------
    # VIN Verification
    # -------------------------
    vin = st.session_state.analysis.get("vehicle_details", {}) \
                                     .get("vin", {}) \
                                     .get("value", "")

    if vin:

        st.subheader("🚘 VIN Verification (NHTSA API)")

        # Call API only once
        if st.session_state.vin_data is None:
            st.session_state.vin_data = verify_vin_with_nhtsa(vin)

        vin_data = st.session_state.vin_data

        if vin_data:
            st.success("VIN Verified Successfully")

            for key, value in vin_data.items():
                if value:
                    st.write(f"**{key}:** {value}")
        else:
            st.warning("Unable to verify VIN.")

    # -------------------------
    # CHAT SECTION
    # -------------------------
    st.subheader("💬 Ask Questions About the Contract")

    question = st.text_input(
        "Ask a question about this contract:",
        key="chat_input"
    )

    if question:
        answer = ask_contract_question(
            st.session_state.analysis,
            question
        )

        st.markdown("### ✅ Answer")
        st.write(answer)
