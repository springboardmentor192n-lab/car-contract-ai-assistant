"""
Test script for Car Contract AI Assistant
Run this to verify the installation and basic functionality
"""

import sys
import os

def test_imports():
    """Test if all required packages are installed"""
    print("Testing imports...")
    try:
        import streamlit
        print("✓ Streamlit installed")
    except ImportError:
        print("✗ Streamlit not installed")
        return False
    
    try:
        import openai
        print("✓ OpenAI installed")
    except ImportError:
        print("✗ OpenAI not installed")
        return False
    
    try:
        from dotenv import load_dotenv
        print("✓ python-dotenv installed")
    except ImportError:
        print("✗ python-dotenv not installed")
        return False
    
    return True

def test_modules():
    """Test if all custom modules can be imported"""
    print("\nTesting custom modules...")
    try:
        from contract_generator import ContractGenerator
        print("✓ contract_generator.py working")
    except Exception as e:
        print(f"✗ contract_generator.py error: {e}")
        return False
    
    try:
        from contract_analyzer import ContractAnalyzer
        print("✓ contract_analyzer.py working")
    except Exception as e:
        print(f"✗ contract_analyzer.py error: {e}")
        return False
    
    try:
        from database import Database
        print("✓ database.py working")
    except Exception as e:
        print(f"✗ database.py error: {e}")
        return False
    
    return True

def test_database():
    """Test database operations"""
    print("\nTesting database operations...")
    try:
        from database import Database
        db = Database('test_database.json')
        
        # Test user creation
        result = db.create_user('testuser', 'testpass123')
        if result:
            print("✓ User creation working")
        else:
            print("✗ User creation failed")
            return False
        
        # Test user verification
        result = db.verify_user('testuser', 'testpass123')
        if result:
            print("✓ User verification working")
        else:
            print("✗ User verification failed")
            return False
        
        # Test contract creation
        contract_data = {
            'type': 'sale',
            'status': 'draft',
            'customer_name': 'Test Customer',
            'customer_email': 'test@example.com',
            'customer_phone': '1234567890',
            'customer_address': '123 Test St',
            'license_number': 'TEST123',
            'vehicle_make': 'Toyota',
            'vehicle_model': 'Camry',
            'vehicle_year': 2024,
            'vehicle_vin': '12345678901234567',
            'vehicle_color': 'Blue',
            'vehicle_mileage': 0,
            'start_date': '2024-01-01',
            'end_date': '2024-12-31',
            'price': 25000,
            'deposit': 5000,
            'payment_method': 'Cash',
            'duration': 12,
            'content': 'Test contract content',
            'username': 'testuser'
        }
        
        result = db.save_contract(contract_data)
        if result:
            print("✓ Contract creation working")
        else:
            print("✗ Contract creation failed")
            return False
        
        # Test contract retrieval
        contracts = db.get_user_contracts('testuser')
        if len(contracts) > 0:
            print("✓ Contract retrieval working")
        else:
            print("✗ Contract retrieval failed")
            return False
        
        # Cleanup
        if os.path.exists('test_database.json'):
            os.remove('test_database.json')
            print("✓ Test database cleaned up")
        
        return True
    
    except Exception as e:
        print(f"✗ Database test error: {e}")
        return False

def test_contract_generator():
    """Test contract generation"""
    print("\nTesting contract generator...")
    try:
        from contract_generator import ContractGenerator
        generator = ContractGenerator()
        
        contract = generator.generate_contract(
            contract_type='sale',
            customer_name='John Doe',
            customer_email='john@example.com',
            customer_phone='1234567890',
            license_number='DL123456',
            vehicle_make='Toyota',
            vehicle_model='Camry',
            vehicle_year=2024,
            vehicle_vin='12345678901234567',
            price=25000
        )
        
        if contract and len(contract) > 100:
            print("✓ Contract generation working")
            return True
        else:
            print("✗ Contract generation failed")
            return False
    
    except Exception as e:
        print(f"✗ Contract generator error: {e}")
        return False

def test_contract_analyzer():
    """Test contract analysis"""
    print("\nTesting contract analyzer...")
    try:
        from contract_analyzer import ContractAnalyzer
        analyzer = ContractAnalyzer()
        
        test_contract = """
        VEHICLE SALE CONTRACT
        This agreement is between Seller and Buyer for the sale of a 2024 Toyota Camry.
        Price: $25,000
        VIN: 12345678901234567
        """
        
        analysis = analyzer.analyze_contract(test_contract)
        
        if 'risk_score' in analysis and 'concerns' in analysis:
            print("✓ Contract analysis working")
            return True
        else:
            print("✗ Contract analysis failed")
            return False
    
    except Exception as e:
        print(f"✗ Contract analyzer error: {e}")
        return False

def main():
    """Run all tests"""
    print("=" * 50)
    print("Car Contract AI Assistant - Test Suite")
    print("=" * 50)
    
    all_passed = True
    
    if not test_imports():
        all_passed = False
        print("\n⚠️  Please install required packages:")
        print("pip install -r requirements.txt")
    
    if not test_modules():
        all_passed = False
    
    if not test_database():
        all_passed = False
    
    if not test_contract_generator():
        all_passed = False
    
    if not test_contract_analyzer():
        all_passed = False
    
    print("\n" + "=" * 50)
    if all_passed:
        print("✅ All tests passed! Application is ready to use.")
        print("\nTo start the application, run:")
        print("streamlit run app.py")
    else:
        print("❌ Some tests failed. Please check the errors above.")
    print("=" * 50)

if __name__ == "__main__":
    main()
