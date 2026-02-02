import streamlit as st
import os
from dotenv import load_dotenv

# Import custom modules
from modules.ocr_engine import get_text_from_file
from modules.ai_analyzer import analyze_with_gemini
from modules.vin_lookup import lookup_vin

load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY") or st.secrets.get("GEMINI_API_KEY")

st.set_page_config(page_title="AutoSLA", layout="wide")

st.title("AutoSLA: LLM-Based Vehicle Contract Analysis System")
st.markdown("Upload your car lease or loan agreement to verify details against official records.")

with st.sidebar:
    st.header("Upload Portal")
    uploaded_file = st.file_uploader("Upload Contract (PDF or Image)", type=["pdf", "png", "jpg", "jpeg"])

if uploaded_file:
    if st.button("🚀 Run Analysis"):
        with st.spinner("🔍 Analyzing document..."):
            # 1. OCR
            raw_text = get_text_from_file(uploaded_file)
            
            if not raw_text.strip():
                st.error("No text could be extracted.")
            else:
                # 2. AI Analysis
                analysis = analyze_with_gemini(raw_text, GEMINI_API_KEY)
                
                # 3. VIN Validation
                official_data = lookup_vin(analysis.get("vin", ""))

                # --- DISPLAY RESULTS ---
                st.success("Analysis Complete!")
                
                # THE 4 METRICS (Supports $ and ₹ automatically)
                m_col1, m_col2, m_col3, m_col4 = st.columns(4)
                
                def clean_val(val):
                    return str(val).strip() if val not in [None, 0, "0"] else "N/A"

                m_col1.metric("Monthly Payment", clean_val(analysis.get('monthly_payment')))
                m_col2.metric("APR", f"{clean_val(analysis.get('apr'))}")
                m_col3.metric("Term", f"{clean_val(analysis.get('lease_term'))}")
                m_col4.metric("Upfront", clean_val(analysis.get('total_upfront')))

                st.divider()

                # DOCUMENT FINDINGS & NHTSA DATA
                left, right = st.columns(2)
                
                with left:
                    st.subheader("📑 Document Findings")
                    st.write(f"**Vehicle:** {analysis.get('year', '')} {analysis.get('brand', '')} {analysis.get('model', '')}")
                    st.write(f"**VIN:** `{analysis.get('vin', 'NOT FOUND')}`")
                    st.write(f"**Mileage Limit:** {analysis.get('mileage_limit', 'N/A')}")
                    
                    st.warning("⚠️ Red Flags Detected:")
                    flags = analysis.get('red_flags', [])
                    for flag in flags:
                        st.write(f"- {flag}")

                with right:
                    st.subheader("✅ NHTSA Official Data")
                    if official_data:
                        st.write(f"**Actual Make:** {official_data.get('make', 'N/A')}")
                        st.write(f"**Actual Model:** {official_data.get('model', 'N/A')}")
                        st.write(f"**Official Year:** {official_data.get('model_year', 'N/A')}")
                        st.write(f"**Manufacturer:** {official_data.get('manufacturer_name', 'N/A')}")
                        
                        # Comparison Logic
                        ext_brand = str(analysis.get('brand', '')).upper()
                        off_make = str(official_data.get('make', '')).upper()
                        
                        if ext_brand and off_make and (ext_brand in off_make or off_make in ext_brand):
                            st.balloons()
                            st.success("✅ Verification Success: Contract matches official records.")
                        else:
                            st.error("❌ Verification Warning: Brand mismatch detected!")
                    else:
                        st.error("Could not validate VIN with official database.")

                # --- REPORT DOWNLOAD ---
                report_text = f"AutoSLA Report\nVIN: {analysis.get('vin')}\nPayment: {analysis.get('monthly_payment')}"
                st.download_button("📥 Download Audit Report", report_text, file_name="Report.txt")

else:
    st.info("👋 Welcome! Please upload a contract in the sidebar to begin.")