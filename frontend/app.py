import streamlit as st
import requests
import json
import pandas as pd
from datetime import datetime
import uuid

# Page configuration
st.set_page_config(
    page_title="Car Contract AI Assistant",
    page_icon="🚗",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        color: #1E3A8A;
        margin-bottom: 1rem;
    }
    .risk-high {
        color: #DC2626;
        font-weight: bold;
    }
    .risk-medium {
        color: #D97706;
        font-weight: bold;
    }
    .risk-low {
        color: #059669;
        font-weight: bold;
    }
    .metric-card {
        background-color: #F3F4F6;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #3B82F6;
    }
    .contract-card {
        border: 1px solid #E5E7EB;
        border-radius: 0.5rem;
        padding: 1rem;
        margin-bottom: 1rem;
        background-color: #F9FAFB;
    }
    .stButton button {
        width: 100%;
    }
</style>
""", unsafe_allow_html=True)

# Initialize session state
if "chat_history" not in st.session_state:
    st.session_state.chat_history = []
if "contract_data" not in st.session_state:
    st.session_state.contract_data = None
if "contracts_history" not in st.session_state:
    st.session_state.contracts_history = []
if "session_id" not in st.session_state:
    st.session_state.session_id = str(uuid.uuid4())
if "view_contract_id" not in st.session_state:
    st.session_state.view_contract_id = None


# Helper functions
def check_backend_status():
    """Check if backend is running"""
    try:
        response = requests.get("http://localhost:8000/", timeout=3)
        return response.status_code == 200
    except:
        return False


def format_file_size(size_bytes):
    """Format file size in human readable format"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f} TB"


def get_risk_color(score):
    """Get color based on risk score"""
    if score >= 70:
        return "🔴 High"
    elif score >= 40:
        return "🟡 Medium"
    else:
        return "🟢 Low"


# Sidebar
with st.sidebar:
    st.markdown('<h2 style="color: #1E3A8A;">🚗 Car Contract AI</h2>', unsafe_allow_html=True)

    # Backend status
    backend_status = check_backend_status()
    if backend_status:
        st.success("✅ Backend Connected")
    else:
        st.error("❌ Backend Disconnected")
        st.info("Run: `python -m uvicorn app.main:app --reload`")

    st.markdown("---")

    # Navigation
    menu = st.radio(
        "**Navigation**",
        ["📊 Dashboard", "📄 Upload Contract", "💬 Negotiation Assistant", "🚗 VIN Lookup", "📚 My Contracts"],
        label_visibility="collapsed"
    )

    st.markdown("---")

    # Session info
    with st.expander("Session Info"):
        st.write(f"**Session ID:** {st.session_state.session_id[:8]}...")
        if st.session_state.contract_data:
            st.write(f"**Current Contract:** {st.session_state.contract_data.get('filename', 'None')}")
        st.write(f"**Chat History:** {len(st.session_state.chat_history)} messages")
        st.write(f"**Saved Contracts:** {len(st.session_state.contracts_history)}")

        if st.button("🔄 Clear Session", type="secondary"):
            st.session_state.chat_history = []
            st.session_state.view_contract_id = None
            st.rerun()

    st.markdown("---")
    st.caption("Week 6 Implementation - Complete")

# Main content
if menu == "📊 Dashboard":
    st.markdown('<h1 class="main-header">Car Contract AI Assistant</h1>', unsafe_allow_html=True)

    # Welcome message
    col1, col2 = st.columns([3, 1])
    with col1:
        st.markdown("""
        ### 🤖 AI-Powered Contract Analysis

        This assistant helps you:
        - 📄 **Analyze** car lease/loan contracts
        - ⚠️ **Identify** risks and red flags
        - 💬 **Negotiate** better terms
        - 🚗 **Verify** vehicle information
        - 💡 **Get** personalized recommendations

        **Upload your first contract to get started!**
        """)

    with col2:
        st.image("https://cdn-icons-png.flaticon.com/512/2061/2061878.png", width=150)

    st.markdown("---")

    # Quick stats
    col1, col2, col3, col4 = st.columns(4)

    with col1:
        st.metric("Backend Status", "Online" if backend_status else "Offline")

    with col2:
        total_contracts = len(st.session_state.contracts_history)
        if st.session_state.contract_data:
            total_contracts += 1
        st.metric("Total Contracts", total_contracts)

    with col3:
        avg_risk = 0
        if st.session_state.contracts_history:
            avg_risk = sum(c.get('risk_score', 0) for c in st.session_state.contracts_history) / len(
                st.session_state.contracts_history)
        if st.session_state.contract_data:
            contracts = st.session_state.contracts_history + [st.session_state.contract_data]
            avg_risk = sum(c.get('risk_score', 0) for c in contracts) / len(contracts)
        st.metric("Avg Risk Score", f"{avg_risk:.1f}/100")

    with col4:
        st.metric("Chat Messages", len(st.session_state.chat_history))

    st.markdown("---")

    # Recent activity
    st.subheader("Recent Activity")

    if st.session_state.contracts_history or st.session_state.contract_data:
        recent_contracts = st.session_state.contracts_history[-3:]  # Last 3
        if st.session_state.contract_data:
            recent_contracts = [st.session_state.contract_data] + recent_contracts

        for contract in recent_contracts[:3]:
            with st.container():
                col1, col2, col3 = st.columns([3, 1, 2])
                col1.write(f"**{contract.get('filename', 'Unknown')}**")
                risk_score = contract.get('risk_score', 0)
                col2.metric("Risk", risk_score)
                col3.write(f"**Level:** {get_risk_color(risk_score)}")
                st.divider()
    else:
        st.info("No contracts yet. Upload your first contract to see activity here.")

    # Quick actions
    st.subheader("Quick Actions")
    col1, col2, col3 = st.columns(3)

    with col1:
        if st.button("📄 Upload Contract", type="primary"):
            st.session_state.menu = "📄 Upload Contract"
            st.rerun()

    with col2:
        if st.button("💬 Ask Chatbot"):
            st.session_state.menu = "💬 Negotiation Assistant"
            st.rerun()

    with col3:
        if st.button("🚗 Check VIN"):
            st.session_state.menu = "🚗 VIN Lookup"
            st.rerun()

elif menu == "📄 Upload Contract":
    st.markdown('<h1 class="main-header">📄 Upload & Analyze Contract</h1>', unsafe_allow_html=True)

    # File upload section
    col1, col2 = st.columns([2, 1])

    with col1:
        uploaded_file = st.file_uploader(
            "**Drag and drop your contract file here**",
            type=['pdf', 'txt', 'docx', 'doc', 'png', 'jpg', 'jpeg'],
            help="Supported formats: PDF, TXT, DOCX, DOC, Images"
        )

    with col2:
        st.markdown("""
        ### 📋 Supported Files
        - **PDF Documents** (Best for text extraction)
        - **Text Files** (.txt)
        - **Word Documents** (.docx, .doc)
        - **Images** (.png, .jpg, .jpeg)

        ### ⚡ Quick Tips
        - Clear, scanned documents work best
        - File size limit: 50MB
        - Processing time: 10-30 seconds
        """)

    if uploaded_file:
        st.markdown("---")

        # File info
        col1, col2, col3 = st.columns(3)
        file_size = len(uploaded_file.getvalue())

        with col1:
            st.markdown(f"""
            <div class="metric-card">
                <h4>File Info</h4>
                <p><strong>Name:</strong> {uploaded_file.name}</p>
                <p><strong>Type:</strong> {uploaded_file.type}</p>
                <p><strong>Size:</strong> {format_file_size(file_size)}</p>
            </div>
            """, unsafe_allow_html=True)

        with col2:
            st.markdown("""
            <div class="metric-card">
                <h4>What We Analyze</h4>
                <p>• Interest Rates & APR</p>
                <p>• Monthly Payments</p>
                <p>• Fees & Charges</p>
                <p>• Mileage Limits</p>
            </div>
            """, unsafe_allow_html=True)

        with col3:
            st.markdown("""
            <div class="metric-card">
                <h4>What You Get</h4>
                <p>• Risk Score (0-100)</p>
                <p>• Red Flag Detection</p>
                <p>• Negotiation Tips</p>
                <p>• Contract Summary</p>
            </div>
            """, unsafe_allow_html=True)

        # Analyze button
        if st.button("🔍 Analyze Contract", type="primary", use_container_width=True):
            if not backend_status:
                st.error("Backend server is not running. Please start the backend first.")
                st.code("cd backend\npython -m uvicorn app.main:app --reload")
            else:
                with st.spinner("🔬 Analyzing contract... This may take a moment."):
                    try:
                        # Prepare and send file
                        files = {"file": (uploaded_file.name, uploaded_file.getvalue())}
                        response = requests.post(
                            "http://localhost:8000/api/contracts/upload",
                            files=files,
                            timeout=60
                        )

                        if response.status_code == 200:
                            data = response.json()

                            # Save to session
                            st.session_state.contract_data = data
                            if data not in st.session_state.contracts_history:
                                st.session_state.contracts_history.append(data)

                            st.success("✅ Analysis Complete!")
                            st.balloons()

                            # Show results immediately
                            st.rerun()

                        else:
                            st.error(f"❌ Upload failed with status {response.status_code}")
                            try:
                                error_data = response.json()
                                st.error(f"Error: {error_data.get('detail', 'Unknown error')}")
                            except:
                                st.error(f"Response: {response.text}")

                    except requests.exceptions.Timeout:
                        st.error("⏰ Request timed out. The file might be too large.")
                    except requests.exceptions.ConnectionError:
                        st.error("🔌 Connection error. Please check if backend is running.")
                    except Exception as e:
                        st.error(f"❌ Unexpected error: {str(e)}")

    # Display analysis results if available
    if st.session_state.contract_data:
        data = st.session_state.contract_data
        st.markdown("---")
        st.markdown("<h2>📊 Analysis Results</h2>", unsafe_allow_html=True)

        # Risk summary
        risk_score = data.get('risk_score', 0)
        risk_level = data.get('risk_level', 'medium')

        col1, col2, col3, col4 = st.columns(4)

        with col1:
            st.metric("Risk Score", f"{risk_score}/100")

        with col2:
            risk_color_class = f"risk-{risk_level}"
            st.markdown(f"<h3 class='{risk_color_class}'>{risk_level.title()} Risk</h3>", unsafe_allow_html=True)

        with col3:
            st.metric("File Type", data.get('file_type', 'unknown').upper())

        with col4:
            st.metric("File Size", format_file_size(data.get('file_size', 0)))

        # Extracted details
        if data.get('extracted_details'):
            st.subheader("📋 Extracted Contract Terms")

            # Create columns for display
            details = data['extracted_details']
            num_cols = 3
            items_per_col = (len(details) + num_cols - 1) // num_cols

            cols = st.columns(num_cols)
            for i, (key, value) in enumerate(details.items()):
                col_idx = i % num_cols
                with cols[col_idx]:
                    st.markdown(f"""
                    <div style="padding: 0.5rem; margin: 0.25rem 0; background: #F0F9FF; border-radius: 0.25rem;">
                        <strong>{key.replace('_', ' ').title()}:</strong><br>
                        <span style="color: #1E40AF; font-size: 1.1rem;">{value}</span>
                    </div>
                    """, unsafe_allow_html=True)

        # Recommendations
        if data.get('recommendations'):
            st.subheader("💡 Recommendations")
            for i, rec in enumerate(data['recommendations'], 1):
                st.markdown(f"{i}. **{rec}**")

        # Extracted text
        if data.get('extracted_text'):
            with st.expander("📝 View Extracted Text", expanded=False):
                st.text_area("", value=data['extracted_text'], height=300, disabled=True)

        # Download and actions
        st.markdown("---")
        col1, col2, col3 = st.columns(3)

        with col1:
            # Download JSON report
            analysis_json = json.dumps(data, indent=2)
            st.download_button(
                label="📥 Download Report (JSON)",
                data=analysis_json,
                file_name=f"contract_analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json",
                mime="application/json",
                use_container_width=True
            )

        with col2:
            if st.button("💬 Ask About This Contract", use_container_width=True):
                st.session_state.menu = "💬 Negotiation Assistant"
                st.rerun()

        with col3:
            if st.button("📊 View Detailed Analysis", use_container_width=True):
                st.session_state.view_contract_id = data.get('contract_id')
                st.session_state.menu = "📚 My Contracts"
                st.rerun()

        # Raw data
        with st.expander("🔧 View Raw Analysis Data", expanded=False):
            st.json(data)

elif menu == "💬 Negotiation Assistant":
    st.markdown('<h1 class="main-header">💬 Negotiation Assistant</h1>', unsafe_allow_html=True)

    # Contract context
    if st.session_state.contract_data:
        contract = st.session_state.contract_data
        with st.container():
            col1, col2, col3 = st.columns([3, 1, 1])
            col1.write(f"**Current Contract:** {contract.get('filename')}")
            col2.write(f"**Risk:** {contract.get('risk_score')}/100")
            col3.write(f"**Level:** {get_risk_color(contract.get('risk_score', 0))}")
            st.divider()

    # Chat container
    chat_container = st.container()

    with chat_container:
        # Display chat history
        for message in st.session_state.chat_history:
            if message["role"] == "user":
                with st.chat_message("user", avatar="👤"):
                    st.write(message["content"])
            else:
                with st.chat_message("assistant", avatar="🤖"):
                    st.write(message["content"])

                    # Show tips if available
                    if message.get("tips"):
                        with st.expander("💡 Negotiation Tips", expanded=False):
                            for tip in message["tips"]:
                                st.write(f"• {tip}")

    # Chat input
    if prompt := st.chat_input("Ask me about negotiating your contract..."):
        # Add user message to history
        st.session_state.chat_history.append({
            "role": "user",
            "content": prompt,
            "timestamp": datetime.now().isoformat()
        })

        # Get chatbot response
        with st.chat_message("assistant", avatar="🤖"):
            with st.spinner("Thinking..."):
                try:
                    # Prepare request
                    params = {"question": prompt}

                    # Add contract context if available
                    if st.session_state.contract_data:
                        contract_id = st.session_state.contract_data.get('contract_id')
                        if contract_id:
                            params["contract_id"] = contract_id

                    response = requests.get(
                        "http://localhost:8000/api/chatbot/ask",
                        params=params,
                        timeout=15
                    )

                    if response.status_code == 200:
                        data = response.json()
                        bot_response = data.get("response", "I'm not sure how to answer that.")
                        tips = data.get("tips", [])

                        # Display response
                        st.write(bot_response)

                        # Add to history
                        st.session_state.chat_history.append({
                            "role": "assistant",
                            "content": bot_response,
                            "tips": tips,
                            "timestamp": datetime.now().isoformat()
                        })

                        # Show tips
                        if tips:
                            with st.expander("💡 Negotiation Tips", expanded=True):
                                for tip in tips:
                                    st.write(f"• {tip}")

                    else:
                        st.error("Chatbot service error. Please try again.")

                except Exception as e:
                    st.error(f"Connection error: {str(e)}")
                    st.info("Make sure the backend server is running.")

    # Quick questions
    st.markdown("---")
    st.subheader("💡 Quick Questions")

    col1, col2, col3 = st.columns(3)
    quick_questions = [
        ("How do I negotiate interest rate?", "📉"),
        ("What fees can I ask to waive?", "💰"),
        ("Is my monthly payment fair?", "⚖️"),
        ("What about mileage limits?", "🛣️"),
        ("Early termination options?", "⏱️"),
        ("Security deposit advice?", "🔒")
    ]

    for i, (question, icon) in enumerate(quick_questions):
        col_idx = i % 3
        if col_idx == 0 and col1.button(f"{icon} {question}", key=f"q_{i}", use_container_width=True):
            st.session_state.chat_history.append({
                "role": "user",
                "content": question,
                "timestamp": datetime.now().isoformat()
            })
            st.rerun()
        elif col_idx == 1 and col2.button(f"{icon} {question}", key=f"q_{i}", use_container_width=True):
            st.session_state.chat_history.append({
                "role": "user",
                "content": question,
                "timestamp": datetime.now().isoformat()
            })
            st.rerun()
        elif col_idx == 2 and col3.button(f"{icon} {question}", key=f"q_{i}", use_container_width=True):
            st.session_state.chat_history.append({
                "role": "user",
                "content": question,
                "timestamp": datetime.now().isoformat()
            })
            st.rerun()

    # Clear chat button
    if st.button("🗑️ Clear Chat History", type="secondary"):
        st.session_state.chat_history = []
        st.rerun()

elif menu == "🚗 VIN Lookup":
    st.markdown('<h1 class="main-header">🚗 Vehicle VIN Lookup</h1>', unsafe_allow_html=True)

    col1, col2 = st.columns([3, 1])

    with col1:
        vin = st.text_input(
            "**Enter 17-character Vehicle Identification Number (VIN):**",
            value="1HGCM82633A123456",
            placeholder="Example: 1HGCM82633A123456",
            help="VIN must be exactly 17 characters (letters and numbers, no I, O, Q)"
        )

    with col2:
        use_mock = st.checkbox("Use Mock Data", value=True,
                               help="Use sample data for testing. Uncheck for real API (requires internet)")

    st.markdown("---")

    if st.button("🔍 Lookup Vehicle", type="primary"):
        if not vin:
            st.warning("Please enter a VIN number")
        elif len(vin) != 17:
            st.error("VIN must be exactly 17 characters")
        else:
            with st.spinner("🔍 Fetching vehicle information..."):
                try:
                    response = requests.get(
                        f"http://localhost:8000/api/vin/decode/{vin}",
                        params={"use_mock": use_mock},
                        timeout=10
                    )

                    if response.status_code == 200:
                        data = response.json()

                        if data.get("valid"):
                            st.success("✅ Vehicle Found!")

                            # Display vehicle info in cards
                            col1, col2, col3, col4 = st.columns(4)

                            with col1:
                                st.markdown(f"""
                                <div class="metric-card">
                                    <h4>Make</h4>
                                    <h2>{data.get('make', 'Unknown')}</h2>
                                </div>
                                """, unsafe_allow_html=True)

                            with col2:
                                st.markdown(f"""
                                <div class="metric-card">
                                    <h4>Model</h4>
                                    <h2>{data.get('model', 'Unknown')}</h2>
                                </div>
                                """, unsafe_allow_html=True)

                            with col3:
                                st.markdown(f"""
                                <div class="metric-card">
                                    <h4>Year</h4>
                                    <h2>{data.get('year', 'Unknown')}</h2>
                                </div>
                                """, unsafe_allow_html=True)

                            with col4:
                                st.markdown(f"""
                                <div class="metric-card">
                                    <h4>Body Type</h4>
                                    <h2>{data.get('body_type', 'Unknown')}</h2>
                                </div>
                                """, unsafe_allow_html=True)

                            # Additional details
                            if data.get('engine'):
                                st.info(f"**Engine:** {data.get('engine')}")

                            # Recall information
                            if data.get('recalls'):
                                recalls = data['recalls']
                                if recalls.get('count', 0) > 0:
                                    st.warning(f"⚠️ **{recalls['count']} Recall(s) Found**")

                                    for recall in recalls.get('recalls', []):
                                        with st.container():
                                            st.write(f"**{recall.get('date', 'Unknown date')}**")
                                            st.write(recall.get('description', 'No description'))
                                            st.divider()
                                else:
                                    st.success("✅ No recalls found for this vehicle")

                            # Market value
                            if data.get('market_value'):
                                st.info(f"**Estimated Market Value:** {data.get('market_value')}")

                            # Source info
                            st.caption(f"Data source: {data.get('source', 'Unknown')}")

                            # Raw data
                            with st.expander("View Raw API Response"):
                                st.json(data)

                        else:
                            st.error(f"❌ Invalid VIN: {data.get('error', 'Unknown error')}")

                    else:
                        st.error(f"❌ VIN lookup failed with status {response.status_code}")

                except Exception as e:
                    st.error(f"❌ Error: {str(e)}")
                    st.info("Make sure backend server is running.")

    # Example VINs
    st.markdown("---")
    st.subheader("📋 Example VINs for Testing")

    example_vins = [
        ("Toyota Camry", "1HGCM82633A123456"),
        ("Honda Civic", "2HGFA16507H123456"),
        ("Ford F-150", "1FTFW1ET7EFA12345"),
        ("Tesla Model 3", "5YJ3E1EAXJF123456")
    ]

    cols = st.columns(4)
    for i, (make_model, example_vin) in enumerate(example_vins):
        with cols[i]:
            if st.button(f"{make_model}", key=f"vin_{i}", use_container_width=True):
                st.session_state.example_vin = example_vin
                st.rerun()

    if st.session_state.get('example_vin'):
        st.info(f"Example VIN inserted: {st.session_state.example_vin}")
        vin = st.session_state.example_vin

elif menu == "📚 My Contracts":
    st.markdown('<h1 class="main-header">📚 My Contracts</h1>', unsafe_allow_html=True)

    # Check if viewing specific contract
    if st.session_state.view_contract_id or st.session_state.contract_data:
        contract_to_view = None

        # Find the contract to view
        if st.session_state.view_contract_id:
            # Look in history
            for contract in st.session_state.contracts_history:
                if contract.get('contract_id') == st.session_state.view_contract_id:
                    contract_to_view = contract
                    break

        if not contract_to_view and st.session_state.contract_data:
            contract_to_view = st.session_state.contract_data

        if contract_to_view:
            # Back button
            if st.button("← Back to Contract List"):
                st.session_state.view_contract_id = None
                st.rerun()

            # Detailed contract view
            st.subheader(f"Contract Details: {contract_to_view.get('filename')}")

            # Risk summary
            risk_score = contract_to_view.get('risk_score', 0)

            col1, col2, col3 = st.columns(3)
            col1.metric("Risk Score", f"{risk_score}/100")
            col2.metric("Risk Level", get_risk_color(risk_score))
            col3.metric("File Type", contract_to_view.get('file_type', 'unknown').upper())

            # Extracted details as table
            if contract_to_view.get('extracted_details'):
                st.subheader("Extracted Terms")
                df = pd.DataFrame(
                    list(contract_to_view['extracted_details'].items()),
                    columns=['Term', 'Value']
                )
                st.dataframe(df, use_container_width=True)

            # Recommendations
            if contract_to_view.get('recommendations'):
                st.subheader("Recommendations")
                for rec in contract_to_view['recommendations']:
                    st.write(f"• {rec}")

            # Full JSON view
            with st.expander("View Full Contract Data"):
                st.json(contract_to_view)

            # Action buttons
            col1, col2 = st.columns(2)
            with col1:
                # Download
                analysis_json = json.dumps(contract_to_view, indent=2)
                st.download_button(
                    label="📥 Download Report",
                    data=analysis_json,
                    file_name=f"contract_{contract_to_view.get('filename', 'details')}.json",
                    mime="application/json",
                    use_container_width=True
                )

            with col2:
                if st.button("💬 Ask About This Contract", use_container_width=True):
                    st.session_state.contract_data = contract_to_view
                    st.session_state.menu = "💬 Negotiation Assistant"
                    st.rerun()

            st.divider()

    # Contract list
    st.subheader("Contract History")

    # Combine current and historical contracts
    all_contracts = st.session_state.contracts_history.copy()
    if st.session_state.contract_data:
        # Check if current contract is already in history
        current_in_history = any(
            c.get('contract_id') == st.session_state.contract_data.get('contract_id')
            for c in all_contracts
        )
        if not current_in_history:
            all_contracts.append(st.session_state.contract_data)

    if all_contracts:
        # Sort by risk score (descending)
        all_contracts.sort(key=lambda x: x.get('risk_score', 0), reverse=True)

        for contract in all_contracts:
            with st.container():
                col1, col2, col3, col4 = st.columns([3, 1, 1, 1])

                with col1:
                    st.write(f"**{contract.get('filename', 'Unknown Contract')}**")
                    if contract.get('file_type'):
                        st.caption(f"Type: {contract.get('file_type').upper()}")

                with col2:
                    risk_score = contract.get('risk_score', 0)
                    st.metric("Risk", risk_score, delta=None)

                with col3:
                    st.write(f"**{get_risk_color(risk_score)}**")

                with col4:
                    if st.button("View", key=f"view_{contract.get('contract_id', id(contract))}",
                                 use_container_width=True):
                        st.session_state.view_contract_id = contract.get('contract_id')
                        st.rerun()

                st.divider()

        # Summary statistics
        st.subheader("📈 Contract Statistics")

        if all_contracts:
            total_contracts = len(all_contracts)
            avg_risk = sum(c.get('risk_score', 0) for c in all_contracts) / total_contracts
            high_risk = sum(1 for c in all_contracts if c.get('risk_score', 0) >= 70)
            medium_risk = sum(1 for c in all_contracts if 40 <= c.get('risk_score', 0) < 70)
            low_risk = sum(1 for c in all_contracts if c.get('risk_score', 0) < 40)

            col1, col2, col3, col4 = st.columns(4)
            col1.metric("Total Contracts", total_contracts)
            col2.metric("Average Risk", f"{avg_risk:.1f}/100")
            col3.metric("High Risk", high_risk)
            col4.metric("Low Risk", low_risk)

            # Risk distribution chart
            risk_data = pd.DataFrame({
                'Risk Level': ['High', 'Medium', 'Low'],
                'Count': [high_risk, medium_risk, low_risk]
            })
            st.bar_chart(risk_data.set_index('Risk Level'))

    else:
        st.info("No contracts found. Upload your first contract to see it here!")

        col1, col2 = st.columns(2)
        with col1:
            if st.button("📄 Upload Contract Now", type="primary", use_container_width=True):
                st.session_state.menu = "📄 Upload Contract"
                st.rerun()

        with col2:
            if st.button("🚀 Go to Dashboard", use_container_width=True):
                st.session_state.menu = "📊 Dashboard"
                st.rerun()

# Footer
st.markdown("---")
footer_col1, footer_col2, footer_col3 = st.columns([2, 1, 1])

with footer_col1:
    st.caption("© 2024 Car Contract AI Assistant - Week 6 Complete Implementation")

with footer_col2:
    if st.button("🔄 Restart App"):
        for key in list(st.session_state.keys()):
            del st.session_state[key]
        st.rerun()

with footer_col3:
    if st.button("ℹ️ About"):
        st.info("""
        **Car Contract AI Assistant**

        Week 6 Implementation Features:
        - 📄 Contract upload & analysis
        - ⚠️ Risk scoring (0-100)
        - 💬 AI negotiation chatbot
        - 🚗 VIN vehicle lookup
        - 📚 Contract history & management
        - 📥 Report export (JSON)

        Built with: FastAPI, Streamlit, Python
        """)