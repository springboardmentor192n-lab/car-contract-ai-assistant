import os
from openai import OpenAI
import json

class ContractAnalyzer:
    def __init__(self):
        api_key = os.getenv('OPENAI_API_KEY', 'your-api-key-here')
        if api_key and api_key != 'your-api-key-here':
            self.client = OpenAI(api_key=api_key)
            self.use_ai = True
        else:
            self.use_ai = False
    
    def analyze_contract(self, contract_text):
        """Analyze contract for risks, concerns, and suggestions"""
        
        if self.use_ai:
            return self._analyze_with_ai(contract_text)
        else:
            return self._analyze_template(contract_text)
    
    def _analyze_with_ai(self, contract_text):
        """Analyze contract using OpenAI API"""
        
        prompt = f"""Analyze the following car contract and provide:
1. Risk assessment score (0-100, where 0 is lowest risk)
2. Key concerns or red flags
3. Suggestions for improvement
4. Missing clauses or information

Contract:
{contract_text}

Provide the analysis in JSON format with keys: risk_score, concerns, suggestions, missing_clauses"""

        try:
            response = self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a legal analyst specializing in automotive contracts. Analyze contracts for risks and provide actionable feedback in JSON format."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.5,
                max_tokens=1000
            )
            
            analysis_text = response.choices[0].message.content
            
            # Try to parse JSON from response
            try:
                # Remove markdown code blocks if present
                if '```json' in analysis_text:
                    analysis_text = analysis_text.split('```json')[1].split('```')[0]
                elif '```' in analysis_text:
                    analysis_text = analysis_text.split('```')[1].split('```')[0]
                
                analysis = json.loads(analysis_text.strip())
                return analysis
            except:
                # If JSON parsing fails, return structured response
                return {
                    'risk_score': 50,
                    'concerns': [analysis_text],
                    'suggestions': ['Review the analysis above'],
                    'missing_clauses': []
                }
        
        except Exception as e:
            print(f"AI analysis error: {e}")
            return self._analyze_template(contract_text)
    
    def _analyze_template(self, contract_text):
        """Analyze contract using rule-based approach"""
        
        concerns = []
        suggestions = []
        missing_clauses = []
        risk_score = 30
        
        # Check for important keywords
        important_terms = {
            'insurance': 'Insurance clause',
            'liability': 'Liability clause',
            'warranty': 'Warranty information',
            'payment': 'Payment terms',
            'termination': 'Termination clause',
            'dispute': 'Dispute resolution',
            'signature': 'Signature section'
        }
        
        contract_lower = contract_text.lower()
        
        for term, clause_name in important_terms.items():
            if term not in contract_lower:
                missing_clauses.append(clause_name)
                risk_score += 10
        
        # Check contract length
        if len(contract_text) < 500:
            concerns.append("Contract appears too short and may be missing important details")
            risk_score += 15
        
        # Check for specific concerns
        if 'as is' in contract_lower and 'warranty' not in contract_lower:
            concerns.append("'AS IS' sale without warranty information may pose risks")
            risk_score += 10
        
        if 'vin' not in contract_lower:
            concerns.append("VIN number not clearly specified")
            risk_score += 15
        
        if '$' not in contract_text and 'price' not in contract_lower:
            concerns.append("Price not clearly specified")
            risk_score += 20
        
        # Generate suggestions
        if missing_clauses:
            suggestions.append(f"Add the following clauses: {', '.join(missing_clauses)}")
        
        if len(contract_text) < 1000:
            suggestions.append("Consider adding more detailed terms and conditions")
        
        suggestions.append("Have the contract reviewed by a legal professional")
        suggestions.append("Ensure all parties understand the terms before signing")
        
        # Cap risk score at 100
        risk_score = min(risk_score, 100)
        
        return {
            'risk_score': risk_score,
            'concerns': concerns if concerns else ['No major concerns detected'],
            'suggestions': suggestions,
            'missing_clauses': missing_clauses if missing_clauses else ['All major clauses present']
        }
