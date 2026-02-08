import streamlit as st
import os
import re 
from dotenv import load_dotenv

from modules.ocr_engine import get_text_from_file
from modules.ai_analyzer import analyze_with_gemini
from modules.vin_lookup import lookup_vin
from modules.chatbot import get_chatbot_response 
from modules.price_engine import get_market_value, calculate_fairness_score

load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY") or st.secrets.get("GEMINI_API_KEY")

st.set_page_config(page_title="AutoSLA", layout="wide")

def to_float(val):
    """Robustly extracts numbers from strings like '$289.00' or '36 months'"""
    if not val: return 0.0
    try:
        clean = re.sub(r'[^\d.]', '', str(val))
        return float(clean) if clean else 0.0
    except:
        return 0.0

if "analysis_results" not in st.session_state:
    st.session_state.analysis_results = None
if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

st.title("AutoSLA: LLM-Based Car Contract Analysis System")
st.markdown("Upload your car lease or loan agreement to verify details against official records.")

with st.sidebar:
    st.header("Upload Portal")
    uploaded_file = st.file_uploader("Upload Contract (PDF or Image)", type=["pdf", "png", "jpg", "jpeg"])

if uploaded_file:
    if st.button("🚀 Run Analysis"):
        with st.spinner("🔍 Analyzing document..."):
            raw_text = get_text_from_file(uploaded_file)
            
            if not raw_text.strip():
                st.error("No text could be extracted.")
            else:
                analysis = analyze_with_gemini(raw_text, GEMINI_API_KEY)
                official_data = lookup_vin(analysis.get("vin", ""))

                # PRICE ENGINE
                m_val = get_market_value(analysis.get('year'), analysis.get('brand'), analysis.get('model'))
                f_score = calculate_fairness_score(analysis, m_val)

                st.session_state.analysis_results = {
                    "analysis": analysis,
                    "official_data": official_data,
                    "market_value": m_val,
                    "fairness_score": f_score
                }

if st.session_state.analysis_results:
    res = st.session_state.analysis_results
    analysis = res["analysis"]
    official_data = res["official_data"]
    score = res.get("fairness_score", 0)
    market_val = res.get("market_value", 0)

    st.success("Analysis Complete!")
    
    m_col1, m_col2, m_col3, m_col4 = st.columns(4)
    
    m_col1.metric("Monthly Payment", f"{analysis.get('monthly_payment', 'N/A')}")
    m_col2.metric("APR", f"{analysis.get('apr', 'N/A')}")
    m_col3.metric("Term", f"{analysis.get('lease_term', 'N/A')}")
    m_col4.metric("Upfront", f"{analysis.get('total_upfront', 'N/A')}")

    st.divider()

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
            st.write(f"**Make:** {official_data.get('make', 'N/A')}")
            st.write(f"**Model:** {official_data.get('model', 'N/A')}")
            st.write(f"**Official Year:** {official_data.get('model_year', 'N/A')}")
            st.write(f"**Manufacturer:** {official_data.get('manufacturer_name', 'N/A')}")
            
            ext_brand = str(analysis.get('brand', '')).upper()
            off_make = str(official_data.get('make', '')).upper()
            if ext_brand and off_make and (ext_brand in off_make or off_make in ext_brand):
                st.success("✅ VIN Verified: Contract matches official records.")
            else:
                st.error("❌ Brand mismatch detected!")
        else:
            st.error("Could not validate VIN.")

    st.divider()
    st.header("Deal Evaluation")
    
    monthly = to_float(analysis.get('monthly_payment', 0))
    term = to_float(analysis.get('lease_term', 0))
    upfront = to_float(analysis.get('total_upfront', 0))
    total_cost = (monthly * term) + upfront

    c_col1, c_col2, c_col3 = st.columns(3)
    c_col1.metric("Total Contract Cost", f"${total_cost:,.2f}")
    c_col2.metric("Estimated Market Value", f"${market_val:,.2f}")
    
    diff = total_cost - market_val
    c_col3.metric("Cost vs Market", f"${abs(diff):,.2f}", delta=f"{diff:,.2f}", delta_color="inverse")

    st.write(f"### Fairness Score: {score}/100")
    if score >= 80:
        st.success("✅ This is a highly competitive deal.")
    elif score >= 50:
        st.warning("⚠️ This deal is average. Consider negotiating the fees.")
    else:
        st.error("🚨 High financial risk or significantly overpriced.")
    
    st.progress(score / 100)

    with st.expander("🔍 See Score Breakdown"):
        st.write(f"- **Market Price Alignment:** Comparing total cost of **${total_cost:,.2f}** vs Market Value of **${market_val:,.2f}**.")        
        st.write(f"- **Interest Rate (APR):** Detected as **{analysis.get('apr', 'N/A')}**.")
        st.write(f"- **Contract Risks:** Deducted for **{len(flags)}** red flags found.")

    # --- CHATBOT SECTION ---
    st.divider()
    st.subheader("💬 Negotiation Assistant")

    for message in st.session_state.chat_history:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])

    if user_query := st.chat_input("Ask a question about your contract..."):
        st.session_state.chat_history.append({"role": "user", "content": user_query})
        with st.chat_message("user"):
            st.markdown(user_query)

        with st.chat_message("assistant"):
            with st.spinner("Thinking..."):
                # Pass the SCORE and TOTAL COST into the context so the AI can explain it!
                full_context = {**analysis, "fairness_score": score, "total_cost": total_cost}
                response = get_chatbot_response(user_query, full_context, GEMINI_API_KEY)
                st.markdown(response)
                st.session_state.chat_history.append({"role": "assistant", "content": response})

elif not uploaded_file:
    st.info("👋 Welcome! Please upload a contract in the sidebar to begin.")
