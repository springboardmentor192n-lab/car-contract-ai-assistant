import json
import os
from datetime import datetime
import hashlib

class Database:
    def __init__(self, db_file='database.json'):
        self.db_file = db_file
        self.data = self._load_data()
    
    def _load_data(self):
        """Load data from JSON file"""
        if os.path.exists(self.db_file):
            try:
                with open(self.db_file, 'r') as f:
                    return json.load(f)
            except:
                return {'users': {}, 'contracts': []}
        return {'users': {}, 'contracts': []}
    
    def _save_data(self):
        """Save data to JSON file"""
        with open(self.db_file, 'w') as f:
            json.dump(self.data, f, indent=2)
    
    def _hash_password(self, password):
        """Hash password using SHA-256"""
        return hashlib.sha256(password.encode()).hexdigest()
    
    def create_user(self, username, password):
        """Create a new user"""
        if username in self.data['users']:
            return False
        
        self.data['users'][username] = {
            'password': self._hash_password(password),
            'created_at': datetime.now().isoformat()
        }
        self._save_data()
        return True
    
    def verify_user(self, username, password):
        """Verify user credentials"""
        if username not in self.data['users']:
            return False
        
        return self.data['users'][username]['password'] == self._hash_password(password)
    
    def change_password(self, username, old_password, new_password):
        """Change user password"""
        if not self.verify_user(username, old_password):
            return False
        
        self.data['users'][username]['password'] = self._hash_password(new_password)
        self._save_data()
        return True
    
    def save_contract(self, contract_data):
        """Save a new contract"""
        contract_id = len(self.data['contracts']) + 1
        contract_data['contract_id'] = f"CNT-{contract_id:05d}"
        contract_data['created_at'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        self.data['contracts'].append(contract_data)
        self._save_data()
        return True
    
    def get_user_contracts(self, username):
        """Get all contracts for a user"""
        return [c for c in self.data['contracts'] if c.get('username') == username]
    
    def get_contract_by_id(self, contract_id):
        """Get a specific contract by ID"""
        for contract in self.data['contracts']:
            if contract['contract_id'] == contract_id:
                return contract
        return None
    
    def update_contract_status(self, contract_id, new_status):
        """Update contract status"""
        for contract in self.data['contracts']:
            if contract['contract_id'] == contract_id:
                contract['status'] = new_status
                contract['updated_at'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                self._save_data()
                return True
        return False
    
    def delete_contract(self, contract_id):
        """Delete a contract"""
        self.data['contracts'] = [c for c in self.data['contracts'] 
                                  if c['contract_id'] != contract_id]
        self._save_data()
        return True
    
    def get_all_contracts(self):
        """Get all contracts"""
        return self.data['contracts']
