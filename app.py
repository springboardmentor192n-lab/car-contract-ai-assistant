import streamlit as st
from run_pipeline import run_full_pipeline
import tempfile

# Page config
st.set_page_config(
    page_title="Car Contract AI Assistant",
    layout="wide"
)

st.title("🚗 Car Contract AI Assistant")
st.write("Upload a car lease or rental agreement to analyze key contract terms.")

# File upload
uploaded_file = st.file_uploader(
    "Upload Lease Agreement (PDF / Image)",
    type=["pdf", "jpg", "jpeg", "png"]
)

if uploaded_file:
    # Save uploaded file temporarily
    with tempfile.NamedTemporaryFile(delete=False, suffix=uploaded_file.name) as tmp:
        tmp.write(uploaded_file.read())
        temp_path = tmp.name

    if st.button("Run OCR & AI Analysis"):
        with st.spinner("Processing document..."):
            result = run_full_pipeline(temp_path)

        st.success("Analysis completed!")

        # ---------------- OCR INFO ----------------
        st.subheader("📄 OCR Method Used")
        st.write(result["ocr_method"])

        # ---------------- AI ANALYSIS ----------------
        st.subheader("🧠 AI Analysis")

        analysis = result["analysis_result"]

        for section, fields in analysis.items():
            st.subheader(section.replace("_", " ").title())

            # Dictionary sections
            if isinstance(fields, dict):
                for key, value in fields.items():
                    st.markdown(f"**{key.replace('_', ' ').title()}**")

                    if value.get("value"):
                        st.write(value["value"])
                    else:
                        st.write("Not available")

                    st.caption(value.get("explanation", ""))

            # List sections (risk flags, missing clauses)
            elif isinstance(fields, list):
                if len(fields) == 0:
                    st.info("No issues detected.")
                else:
                    for item in fields:
                        st.warning(item)
