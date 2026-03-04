import streamlit as st
from datetime import datetime
import json
import os
from contract_generator import ContractGenerator
from contract_analyzer import ContractAnalyzer
from database import Database

# Page configuration
st.set_page_config(
    page_title="Car Contract AI Assistant",
    page_icon="🚗",
    layout="wide"
)

# Initialize session state
if 'logged_in' not in st.session_state:
    st.session_state.logged_in = False
if 'username' not in st.session_state:
    st.session_state.username = None
if 'db' not in st.session_state:
    st.session_state.db = Database()

# Initialize AI components
generator = ContractGenerator()
analyzer = ContractAnalyzer()

def login_page():
    st.title("🚗 Car Contract AI Assistant")
    st.subheader("Login")
    
    col1, col2, col3 = st.columns([1, 2, 1])
    
    with col2:
        username = st.text_input("Username")
        password = st.text_input("Password", type="password")
        
        col_a, col_b = st.columns(2)
        with col_a:
            if st.button("Login", use_container_width=True):
                if st.session_state.db.verify_user(username, password):
                    st.session_state.logged_in = True
                    st.session_state.username = username
                    st.rerun()
                else:
                    st.error("Invalid credentials")
        
        with col_b:
            if st.button("Register", use_container_width=True):
                if username and password:
                    if st.session_state.db.create_user(username, password):
                        st.success("Registration successful! Please login.")
                    else:
                        st.error("Username already exists")
                else:
                    st.error("Please fill all fields")

def main_app():
    st.sidebar.title(f"Welcome, {st.session_state.username}!")
    
    menu = st.sidebar.radio(
        "Navigation",
        ["Dashboard", "Create Contract", "View Contracts", "AI Analysis", "Settings"]
    )
    
    if st.sidebar.button("Logout"):
        st.session_state.logged_in = False
        st.session_state.username = None
        st.rerun()
    
    if menu == "Dashboard":
        show_dashboard()
    elif menu == "Create Contract":
        create_contract()
    elif menu == "View Contracts":
        view_contracts()
    elif menu == "AI Analysis":
        ai_analysis()
    elif menu == "Settings":
        settings()

def show_dashboard():
    st.title("📊 Dashboard")
    
    contracts = st.session_state.db.get_user_contracts(st.session_state.username)
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric("Total Contracts", len(contracts))
    with col2:
        active = len([c for c in contracts if c.get('status') == 'active'])
        st.metric("Active Contracts", active)
    with col3:
        draft = len([c for c in contracts if c.get('status') == 'draft'])
        st.metric("Draft Contracts", draft)
    with col4:
        completed = len([c for c in contracts if c.get('status') == 'completed'])
        st.metric("Completed", completed)
    
    st.subheader("Recent Contracts")
    if contracts:
        for contract in contracts[-5:]:
            with st.expander(f"Contract #{contract['contract_id']} - {contract['customer_name']}"):
                col1, col2 = st.columns(2)
                with col1:
                    st.write(f"**Type:** {contract['type']}")
                    st.write(f"**Status:** {contract['status']}")
                    st.write(f"**Vehicle:** {contract['vehicle_make']} {contract['vehicle_model']}")
                with col2:
                    st.write(f"**Price:** ${contract['price']:,.2f}")
                    st.write(f"**Date:** {contract['created_at']}")
    else:
        st.info("No contracts yet. Create your first contract!")

def create_contract():
    st.title("📝 Create New Contract")
    
    tab1, tab2 = st.tabs(["Manual Entry", "AI Generation"])
    
    with tab1:
        manual_contract_form()
    
    with tab2:
        ai_contract_form()

def manual_contract_form():
    with st.form("manual_contract"):
        st.subheader("Contract Details")
        col1, col2 = st.columns(2)
        
        with col1:
            contract_type = st.selectbox("Contract Type", ["Sale", "Rental", "Lease"])
            status = st.selectbox("Status", ["Draft", "Pending", "Active"])
        
        with col2:
            start_date = st.date_input("Start Date", datetime.now())
            end_date = st.date_input("End Date")
        
        st.subheader("Customer Information")
        col1, col2 = st.columns(2)
        
        with col1:
            customer_name = st.text_input("Customer Name*")
            customer_email = st.text_input("Customer Email*")
            customer_phone = st.text_input("Customer Phone*")
        
        with col2:
            customer_address = st.text_area("Customer Address*")
            license_number = st.text_input("License Number*")
        
        st.subheader("Vehicle Information")
        col1, col2, col3 = st.columns(3)
        
        with col1:
            vehicle_make = st.text_input("Make*")
            vehicle_model = st.text_input("Model*")
        
        with col2:
            vehicle_year = st.number_input("Year*", min_value=1900, max_value=2030, value=2024)
            vehicle_vin = st.text_input("VIN*")
        
        with col3:
            vehicle_color = st.text_input("Color")
            vehicle_mileage = st.number_input("Mileage", min_value=0, value=0)
        
        st.subheader("Terms")
        col1, col2 = st.columns(2)
        
        with col1:
            price = st.number_input("Price ($)*", min_value=0.0, value=0.0, step=100.0)
            deposit = st.number_input("Deposit ($)", min_value=0.0, value=0.0, step=100.0)
        
        with col2:
            payment_method = st.selectbox("Payment Method", ["Cash", "Check", "Bank Transfer", "Financing"])
            duration = st.number_input("Duration (months)", min_value=0, value=0)
        
        st.subheader("Contract Content")
        contract_content = st.text_area("Contract Text*", height=200)
        
        submitted = st.form_submit_button("Create Contract")
        
        if submitted:
            if all([customer_name, customer_email, customer_phone, customer_address, 
                   license_number, vehicle_make, vehicle_model, vehicle_vin, 
                   price > 0, contract_content]):
                
                contract_data = {
                    'type': contract_type.lower(),
                    'status': status.lower(),
                    'customer_name': customer_name,
                    'customer_email': customer_email,
                    'customer_phone': customer_phone,
                    'customer_address': customer_address,
                    'license_number': license_number,
                    'vehicle_make': vehicle_make,
                    'vehicle_model': vehicle_model,
                    'vehicle_year': vehicle_year,
                    'vehicle_vin': vehicle_vin,
                    'vehicle_color': vehicle_color,
                    'vehicle_mileage': vehicle_mileage,
                    'start_date': str(start_date),
                    'end_date': str(end_date),
                    'price': price,
                    'deposit': deposit,
                    'payment_method': payment_method,
                    'duration': duration,
                    'content': contract_content,
                    'username': st.session_state.username
                }
                
                if st.session_state.db.save_contract(contract_data):
                    st.success("✅ Contract created successfully!")
                    st.balloons()
                else:
                    st.error("Failed to create contract")
            else:
                st.error("Please fill all required fields (*)")

def ai_contract_form():
    st.info("🤖 Let AI generate a professional contract for you!")
    
    with st.form("ai_contract"):
        col1, col2 = st.columns(2)
        
        with col1:
            contract_type = st.selectbox("Contract Type", ["Sale", "Rental", "Lease"])
            customer_name = st.text_input("Customer Name*")
            customer_email = st.text_input("Customer Email*")
            customer_phone = st.text_input("Customer Phone*")
            license_number = st.text_input("License Number*")
        
        with col2:
            vehicle_make = st.text_input("Vehicle Make*")
            vehicle_model = st.text_input("Vehicle Model*")
            vehicle_year = st.number_input("Year*", min_value=1900, max_value=2030, value=2024)
            vehicle_vin = st.text_input("VIN*")
            price = st.number_input("Price ($)*", min_value=0.0, value=0.0, step=100.0)
        
        generate_btn = st.form_submit_button("🚀 Generate Contract with AI")
        
        if generate_btn:
            if all([customer_name, customer_email, vehicle_make, vehicle_model, vehicle_vin, price > 0]):
                with st.spinner("Generating contract with AI..."):
                    contract_text = generator.generate_contract(
                        contract_type=contract_type.lower(),
                        customer_name=customer_name,
                        customer_email=customer_email,
                        customer_phone=customer_phone,
                        license_number=license_number,
                        vehicle_make=vehicle_make,
                        vehicle_model=vehicle_model,
                        vehicle_year=vehicle_year,
                        vehicle_vin=vehicle_vin,
                        price=price
                    )
                    
                    st.success("✅ Contract generated successfully!")
                    st.text_area("Generated Contract", contract_text, height=400)
                    
                    if st.button("Save This Contract"):
                        contract_data = {
                            'type': contract_type.lower(),
                            'status': 'draft',
                            'customer_name': customer_name,
                            'customer_email': customer_email,
                            'customer_phone': customer_phone,
                            'customer_address': '',
                            'license_number': license_number,
                            'vehicle_make': vehicle_make,
                            'vehicle_model': vehicle_model,
                            'vehicle_year': vehicle_year,
                            'vehicle_vin': vehicle_vin,
                            'vehicle_color': '',
                            'vehicle_mileage': 0,
                            'start_date': str(datetime.now().date()),
                            'end_date': '',
                            'price': price,
                            'deposit': 0,
                            'payment_method': 'Cash',
                            'duration': 0,
                            'content': contract_text,
                            'username': st.session_state.username
                        }
                        
                        if st.session_state.db.save_contract(contract_data):
                            st.success("Contract saved!")
                            st.balloons()
            else:
                st.error("Please fill all required fields")

def view_contracts():
    st.title("📋 View Contracts")
    
    contracts = st.session_state.db.get_user_contracts(st.session_state.username)
    
    if not contracts:
        st.info("No contracts found. Create your first contract!")
        return
    
    # Filters
    col1, col2, col3 = st.columns(3)
    with col1:
        filter_type = st.selectbox("Filter by Type", ["All", "Sale", "Rental", "Lease"])
    with col2:
        filter_status = st.selectbox("Filter by Status", ["All", "Draft", "Pending", "Active", "Completed"])
    with col3:
        search = st.text_input("Search by Customer Name")
    
    # Apply filters
    filtered_contracts = contracts
    if filter_type != "All":
        filtered_contracts = [c for c in filtered_contracts if c['type'] == filter_type.lower()]
    if filter_status != "All":
        filtered_contracts = [c for c in filtered_contracts if c['status'] == filter_status.lower()]
    if search:
        filtered_contracts = [c for c in filtered_contracts if search.lower() in c['customer_name'].lower()]
    
    st.write(f"Showing {len(filtered_contracts)} contracts")
    
    for contract in filtered_contracts:
        with st.expander(f"Contract #{contract['contract_id']} - {contract['customer_name']}"):
            col1, col2 = st.columns(2)
            
            with col1:
                st.subheader("Contract Details")
                st.write(f"**Type:** {contract['type'].title()}")
                st.write(f"**Status:** {contract['status'].title()}")
                st.write(f"**Created:** {contract['created_at']}")
                
                st.subheader("Customer Information")
                st.write(f"**Name:** {contract['customer_name']}")
                st.write(f"**Email:** {contract['customer_email']}")
                st.write(f"**Phone:** {contract['customer_phone']}")
                st.write(f"**License:** {contract['license_number']}")
            
            with col2:
                st.subheader("Vehicle Information")
                st.write(f"**Vehicle:** {contract['vehicle_year']} {contract['vehicle_make']} {contract['vehicle_model']}")
                st.write(f"**VIN:** {contract['vehicle_vin']}")
                
                st.subheader("Terms")
                st.write(f"**Price:** ${contract['price']:,.2f}")
                st.write(f"**Deposit:** ${contract['deposit']:,.2f}")
                st.write(f"**Payment Method:** {contract['payment_method']}")
            
            st.subheader("Contract Content")
            st.text_area("", contract['content'], height=200, key=f"content_{contract['contract_id']}")
            
            col_a, col_b, col_c = st.columns(3)
            with col_a:
                if st.button("Analyze with AI", key=f"analyze_{contract['contract_id']}"):
                    with st.spinner("Analyzing..."):
                        analysis = analyzer.analyze_contract(contract['content'])
                        st.json(analysis)
            
            with col_b:
                new_status = st.selectbox("Update Status", 
                                         ["draft", "pending", "active", "completed", "cancelled"],
                                         key=f"status_{contract['contract_id']}")
                if st.button("Update", key=f"update_{contract['contract_id']}"):
                    st.session_state.db.update_contract_status(contract['contract_id'], new_status)
                    st.success("Status updated!")
                    st.rerun()
            
            with col_c:
                if st.button("Delete", key=f"delete_{contract['contract_id']}"):
                    if st.session_state.db.delete_contract(contract['contract_id']):
                        st.success("Contract deleted!")
                        st.rerun()

def ai_analysis():
    st.title("🤖 AI Contract Analysis")
    
    st.write("Analyze any contract text for risks, issues, and suggestions.")
    
    contract_text = st.text_area("Paste Contract Text Here", height=300)
    
    if st.button("Analyze Contract"):
        if contract_text:
            with st.spinner("Analyzing contract with AI..."):
                analysis = analyzer.analyze_contract(contract_text)
                
                col1, col2 = st.columns(2)
                
                with col1:
                    st.metric("Risk Score", f"{analysis['risk_score']}/100")
                    
                    st.subheader("Concerns")
                    for concern in analysis['concerns']:
                        st.warning(f"⚠️ {concern}")
                
                with col2:
                    st.subheader("Suggestions")
                    for suggestion in analysis['suggestions']:
                        st.info(f"💡 {suggestion}")
                    
                    st.subheader("Missing Clauses")
                    for clause in analysis['missing_clauses']:
                        st.error(f"❌ {clause}")
        else:
            st.error("Please enter contract text")

def settings():
    st.title("⚙️ Settings")
    
    st.subheader("User Information")
    st.write(f"**Username:** {st.session_state.username}")
    
    st.subheader("Change Password")
    with st.form("change_password"):
        old_password = st.text_input("Current Password", type="password")
        new_password = st.text_input("New Password", type="password")
        confirm_password = st.text_input("Confirm New Password", type="password")
        
        if st.form_submit_button("Change Password"):
            if new_password == confirm_password:
                if st.session_state.db.change_password(st.session_state.username, old_password, new_password):
                    st.success("Password changed successfully!")
                else:
                    st.error("Current password is incorrect")
            else:
                st.error("Passwords do not match")
    
    st.subheader("Export Data")
    if st.button("Export All Contracts"):
        contracts = st.session_state.db.get_user_contracts(st.session_state.username)
        st.download_button(
            "Download JSON",
            data=json.dumps(contracts, indent=2),
            file_name=f"contracts_{st.session_state.username}.json",
            mime="application/json"
        )

# Main app logic
if st.session_state.logged_in:
    main_app()
else:
    login_page()
