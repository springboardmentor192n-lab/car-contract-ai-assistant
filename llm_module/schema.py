LEASE_CONTRACT_SCHEMA = {

    "vehicle_details": {
        "vin": {
            "value": "",
            "explanation": "The Vehicle Identification Number is a unique code used to identify the car."
        },
        "brand": {
            "value": "",
            "explanation": "The company or manufacturer of the vehicle."
        },
        "model": {
            "value": "",
            "explanation": "The specific model name of the vehicle."
        },
        "year": {
            "value": "",
            "explanation": "The year in which the vehicle was manufactured."
        }
    },

    "lease_terms": {
        "lease_duration_months": {
            "value": "",
            "explanation": "The total time period for which the vehicle is leased."
        },
        "monthly_payment": {
            "value": "",
            "explanation": "The amount the customer must pay every month during the lease period."
        },
        "security_deposit": {
            "value": "",
            "explanation": "A refundable amount paid at the start of the lease as a safety guarantee."
        },
        "down_payment": {
            "value": "",
            "explanation": "The initial payment made before the lease starts."
        }
    },

    "mileage_terms": {
        "annual_mileage_limit": {
            "value": "",
            "explanation": "The maximum distance the vehicle can be driven in one year without extra charges."
        },
        "excess_mileage_fee": {
            "value": "",
            "explanation": "The charge applied for each extra kilometer driven beyond the allowed limit."
        }
    },

    "penalties_and_fees": {
        "late_payment_fee": {
            "value": "",
            "explanation": "The fee charged if the monthly payment is delayed."
        },
        "early_termination_fee": {
            "value": "",
            "explanation": "The amount charged if the customer ends the lease before the agreed duration."
        }
    },

    "purchase_option": {
        "buyout_available": {
            "value": "",
            "explanation": "Indicates whether the customer can buy the vehicle at the end of the lease."
        },
        "buyout_price": {
            "value": "",
            "explanation": "The price at which the customer can purchase the vehicle after the lease ends."
        }
    },

    "risk_flags": [
        "Short statements highlighting clauses that may cause financial or contractual risk to the customer."
    ],

    "missing_or_unclear_clauses": [
        "Clauses that are not clearly mentioned or missing from the contract."
    ],

    "disclaimer": "This analysis is AI-assisted and based only on the provided contract text. It is intended for informational purposes and does not constitute legal or financial advice."
}
