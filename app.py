import streamlit as st

from ocr_pipline import extract_text_pipeline
from llm_analysis import analyze_with_llm
from vin import extract_vin
from vin_api import fetch_vehicle_details
from chatbot import contract_chatbot

# page 
st.set_page_config(
    page_title="Car Contract AI Assistant",
    layout="wide"
)

st.title("Car Contract AI Assistant")
st.caption("AI-powered OCR + LLM system for car lease agreement analysis")

# sessions
if "contract_text" not in st.session_state:
    st.session_state.contract_text = None
if "analysis" not in st.session_state:
    st.session_state.analysis = None
if "vin" not in st.session_state:
    st.session_state.vin = None

# side bar
with st.sidebar:
    st.header("Upload Contract")
    uploaded_file = st.file_uploader(
        "Upload PDF / Image",
        type=["pdf", "jpg", "jpeg", "png"]
    )

    run_btn = st.button("Run OCR & AI Analysis")

# pipeline
if uploaded_file and run_btn:
    file_name = uploaded_file.name
    with open(file_name, "wb") as f:
        f.write(uploaded_file.getbuffer())

    with st.spinner("Extracting text using OCR..."):
        st.session_state.contract_text = extract_text_pipeline(file_name)

    with st.spinner("Analyzing contract with AI..."):
        st.session_state.analysis = analyze_with_llm(
            st.session_state.contract_text
        )
        st.session_state.vin = extract_vin(
            st.session_state.contract_text
        )

    st.success("Analysis completed successfully!")

# matrics
if st.session_state.contract_text:
    col1, col2, col3 = st.columns(3)

    with col1:
        st.metric("Document Status", "Processed")

    with col2:
        st.metric("VIN Detected", st.session_state.vin or "Not Found")

    with col3:
        st.metric("AI Analysis", "Ready")

# tabs
if st.session_state.contract_text:
    tab1, tab2, tab3, tab4 = st.tabs(
        ["OCR Text", "AI Analysis", "VIN Validation", "Chatbot"]
    )

    # ocr tab
    with tab1:
        st.subheader("OCR Extracted Text")
        st.text_area(
            "Extracted contract text",
            st.session_state.contract_text,
            height=400
        )

    # analaysis tab
    with tab2:
        st.subheader("AI-Based Contract Analysis")
        st.write(st.session_state.analysis)

    # vin tab
    with tab3:
        st.subheader("Vehicle Details from VIN")
        if st.session_state.vin:
            vehicle_info = fetch_vehicle_details(st.session_state.vin)
            if vehicle_info:
                st.json(vehicle_info)
            else:
                st.warning("No vehicle details found from VIN API.")
        else:
            st.warning("VIN not available in document.")

    # chatbot
    with tab4:
        st.subheader("Ask Questions About This Contract")

        user_question = st.text_input(
            "Type your question (e.g. Can I negotiate the monthly payment?)"
        )

        if user_question:
            with st.spinner("AI is thinking hmm hmm !..."):
                reply = contract_chatbot(
                    st.session_state.contract_text,
                    user_question
                )
            st.write(reply)