# backend/app/services/chatbot.py
import random
from typing import List, Dict


class SimpleChatbot:
    def __init__(self, contract_data: Dict = None):
        self.contract_data = contract_data or {}
        self.conversation_history = []

        # Predefined responses
        self.responses = {
            "interest": [
                "Interest rates are negotiable. Current market average is 4-6% APR.",
                "If your credit score is above 700, you should aim for under 5% APR.",
                "Compare rates from at least 3 different lenders before negotiating.",
                "Ask if they can match or beat rates from other dealerships."
            ],
            "payment": [
                "Monthly payment depends on loan term. 36-48 months is standard.",
                "A larger down payment can reduce your monthly payments.",
                "Ask about bi-weekly payments to save on interest over time.",
                "Check if there are any prepayment penalties before signing."
            ],
            "fee": [
                "Common negotiable fees: documentation fee, acquisition fee, dealer prep.",
                "Ask for an itemized list of all fees and challenge any over $500.",
                "Many 'admin' or 'processing' fees are pure profit for dealers.",
                "Try to get at least 2-3 fees waived or reduced."
            ],
            "mileage": [
                "Standard lease mileage is 12,000 miles per year.",
                "If you drive less, ask for lower payments with reduced mileage.",
                "Excess mileage charges should be under $0.25 per mile.",
                "Consider your daily commute when setting mileage limits."
            ],
            "termination": [
                "Early termination fees can be expensive - understand them fully.",
                "Ask about lease transfer options if you need to end early.",
                "Some leases allow early buyout after a certain period.",
                "Check if there are 'hardship' provisions for job loss or illness."
            ],
            "general": [
                "What specific term would you like help negotiating?",
                "I can help with interest rates, fees, payments, or mileage.",
                "Always get competing offers to use as leverage.",
                "Don't feel pressured to sign immediately - take your time."
            ]
        }

    def get_response(self, user_message: str) -> str:
        """Get response based on user message"""
        user_message = user_message.lower()
        self.conversation_history.append(f"User: {user_message}")

        # Check keywords and get response
        if any(word in user_message for word in ['interest', 'apr', 'rate']):
            response = random.choice(self.responses["interest"])
        elif any(word in user_message for word in ['payment', 'monthly', 'installment']):
            response = random.choice(self.responses["payment"])
        elif any(word in user_message for word in ['fee', 'charge', 'cost', 'admin']):
            response = random.choice(self.responses["fee"])
        elif any(word in user_message for word in ['mileage', 'miles', 'limit']):
            response = random.choice(self.responses["mileage"])
        elif any(word in user_message for word in ['termination', 'end', 'cancel', 'early']):
            response = random.choice(self.responses["termination"])
        else:
            response = random.choice(self.responses["general"])

        self.conversation_history.append(f"Assistant: {response}")
        return response

    def get_negotiation_tips(self) -> List[str]:
        """Get personalized negotiation tips"""
        tips = []

        # Check contract data for specific advice
        if self.contract_data:
            risk_score = self.contract_data.get('risk_score', 0)

            if risk_score > 70:
                tips.append("⚠️ High risk contract - consider professional review")
            elif risk_score > 50:
                tips.append("⚠️ Moderate risk - focus on negotiating key terms")

            # Check specific terms
            extracted = self.contract_data.get('quick_extraction', {})
            if extracted.get('interest_rate'):
                tips.append(f"📊 Interest rate: {extracted['interest_rate']} - aim for 4-6%")

            if extracted.get('monthly_payment'):
                tips.append(f"💰 Monthly payment: {extracted['monthly_payment']} - compare with market")

        # Add general tips
        general_tips = [
            "💰 Research the car's fair market value on KBB or Edmunds",
            "📝 Get all promises and terms in writing",
            "⏰ Never rush - take the contract home to review",
            "🔍 Read the fine print on fees and penalties",
            "📊 Get pre-approved from your bank before dealership financing"
        ]

        # Combine and limit to 5 tips
        tips.extend(general_tips)
        return tips[:5]