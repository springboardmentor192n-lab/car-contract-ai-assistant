import os
from openai import OpenAI
from datetime import datetime

class ContractGenerator:
    def __init__(self):
        api_key = os.getenv('OPENAI_API_KEY', 'your-api-key-here')
        if api_key and api_key != 'your-api-key-here':
            self.client = OpenAI(api_key=api_key)
            self.use_ai = True
        else:
            self.use_ai = False
    
    def generate_contract(self, contract_type, customer_name, customer_email, 
                         customer_phone, license_number, vehicle_make, 
                         vehicle_model, vehicle_year, vehicle_vin, price):
        """Generate a professional car contract using AI or template"""
        
        if self.use_ai:
            return self._generate_with_ai(
                contract_type, customer_name, customer_email, customer_phone,
                license_number, vehicle_make, vehicle_model, vehicle_year,
                vehicle_vin, price
            )
        else:
            return self._generate_template(
                contract_type, customer_name, customer_email, customer_phone,
                license_number, vehicle_make, vehicle_model, vehicle_year,
                vehicle_vin, price
            )
    
    def _generate_with_ai(self, contract_type, customer_name, customer_email,
                         customer_phone, license_number, vehicle_make,
                         vehicle_model, vehicle_year, vehicle_vin, price):
        """Generate contract using OpenAI API"""
        
        prompt = f"""Generate a professional car {contract_type} contract with the following details:

Customer Information:
- Name: {customer_name}
- Email: {customer_email}
- Phone: {customer_phone}
- License Number: {license_number}

Vehicle Information:
- Make: {vehicle_make}
- Model: {vehicle_model}
- Year: {vehicle_year}
- VIN: {vehicle_vin}

Terms:
- Price: ${price:,.2f}
- Date: {datetime.now().strftime('%B %d, %Y')}

Please generate a complete, legally sound contract including:
1. Title and parties involved
2. Vehicle description
3. Terms and conditions
4. Payment terms
5. Warranties and representations
6. Liability and insurance
7. Signatures section

Make it professional and comprehensive."""

        try:
            response = self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a legal expert specializing in automotive contracts. Generate professional, legally sound contracts."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=2000
            )
            
            return response.choices[0].message.content
        except Exception as e:
            print(f"AI generation error: {e}")
            return self._generate_template(
                contract_type, customer_name, customer_email, customer_phone,
                license_number, vehicle_make, vehicle_model, vehicle_year,
                vehicle_vin, price
            )
    
    def _generate_template(self, contract_type, customer_name, customer_email,
                          customer_phone, license_number, vehicle_make,
                          vehicle_model, vehicle_year, vehicle_vin, price):
        """Generate contract using template"""
        
        date = datetime.now().strftime('%B %d, %Y')
        
        if contract_type == 'sale':
            return f"""
VEHICLE SALE CONTRACT

This Vehicle Sale Agreement ("Agreement") is entered into on {date}

BETWEEN:
Seller: [Dealer/Seller Name]
Address: [Seller Address]

AND:
Buyer: {customer_name}
Email: {customer_email}
Phone: {customer_phone}
License Number: {license_number}

VEHICLE DESCRIPTION:
Make: {vehicle_make}
Model: {vehicle_model}
Year: {vehicle_year}
VIN: {vehicle_vin}

TERMS AND CONDITIONS:

1. PURCHASE PRICE
The total purchase price for the vehicle is ${price:,.2f} (US Dollars).

2. PAYMENT TERMS
Payment shall be made in full at the time of signing this agreement.

3. VEHICLE CONDITION
The vehicle is sold in "AS IS" condition. The Buyer has inspected the vehicle and accepts it in its current condition.

4. TITLE TRANSFER
The Seller agrees to transfer the title of the vehicle to the Buyer upon receipt of full payment.

5. WARRANTIES
The Seller makes no warranties, express or implied, regarding the vehicle's condition, except as required by law.

6. LIABILITIES
The Buyer assumes all liability for the vehicle from the date of this agreement.

7. INSURANCE
The Buyer is responsible for obtaining insurance coverage for the vehicle.

8. GOVERNING LAW
This agreement shall be governed by the laws of the applicable state/jurisdiction.

SIGNATURES:

Seller: _____________________ Date: _____
Name: [Seller Name]

Buyer: _____________________ Date: _____
Name: {customer_name}

Witness: _____________________ Date: _____
"""
        
        elif contract_type == 'rental':
            return f"""
VEHICLE RENTAL AGREEMENT

This Vehicle Rental Agreement ("Agreement") is entered into on {date}

BETWEEN:
Rental Company: [Company Name]
Address: [Company Address]

AND:
Renter: {customer_name}
Email: {customer_email}
Phone: {customer_phone}
License Number: {license_number}

VEHICLE DESCRIPTION:
Make: {vehicle_make}
Model: {vehicle_model}
Year: {vehicle_year}
VIN: {vehicle_vin}

RENTAL TERMS:

1. RENTAL PERIOD
The rental period begins on {date} and continues as agreed.

2. RENTAL RATE
The rental rate is ${price:,.2f} per period as specified.

3. SECURITY DEPOSIT
A security deposit may be required and will be refunded upon return of the vehicle in good condition.

4. USE OF VEHICLE
The Renter agrees to use the vehicle for lawful purposes only and in accordance with all traffic laws.

5. MAINTENANCE
The Renter is responsible for checking oil, water, and tire pressure regularly.

6. INSURANCE
The Renter must maintain valid insurance coverage for the rental period.

7. RETURN CONDITION
The vehicle must be returned in the same condition as received, normal wear and tear excepted.

8. PROHIBITED USES
The vehicle shall not be used for racing, towing, or any illegal activities.

9. LIABILITY
The Renter is liable for all damage to the vehicle during the rental period.

10. TERMINATION
Either party may terminate this agreement with proper notice as specified.

SIGNATURES:

Rental Company: _____________________ Date: _____
Representative: [Name]

Renter: _____________________ Date: _____
Name: {customer_name}
"""
        
        else:  # lease
            return f"""
VEHICLE LEASE AGREEMENT

This Vehicle Lease Agreement ("Agreement") is entered into on {date}

BETWEEN:
Lessor: [Leasing Company Name]
Address: [Company Address]

AND:
Lessee: {customer_name}
Email: {customer_email}
Phone: {customer_phone}
License Number: {license_number}

VEHICLE DESCRIPTION:
Make: {vehicle_make}
Model: {vehicle_model}
Year: {vehicle_year}
VIN: {vehicle_vin}

LEASE TERMS:

1. LEASE AMOUNT
The total lease amount is ${price:,.2f} payable in monthly installments.

2. LEASE PERIOD
The lease period is as agreed between the parties.

3. MONTHLY PAYMENT
Monthly payment amount and due date to be specified in the payment schedule.

4. SECURITY DEPOSIT
A security deposit is required and will be held for the duration of the lease.

5. MILEAGE LIMIT
The lease includes a specified mileage limit. Excess mileage will incur additional charges.

6. MAINTENANCE
The Lessee is responsible for routine maintenance and keeping the vehicle in good condition.

7. INSURANCE
The Lessee must maintain comprehensive insurance coverage throughout the lease period.

8. EARLY TERMINATION
Early termination of the lease may result in penalties as specified.

9. END OF LEASE OPTIONS
At the end of the lease, the Lessee may have options to purchase, return, or extend the lease.

10. WEAR AND TEAR
Normal wear and tear is acceptable. Excessive damage will be charged to the Lessee.

11. DEFAULT
Failure to make payments or breach of terms may result in repossession of the vehicle.

SIGNATURES:

Lessor: _____________________ Date: _____
Representative: [Name]

Lessee: _____________________ Date: _____
Name: {customer_name}
"""
