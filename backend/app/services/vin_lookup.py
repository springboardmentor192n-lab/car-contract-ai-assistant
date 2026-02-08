from app.services.vin_decoder import decode_vin, get_vehicle_recalls

def get_comprehensive_vin_data(vin: str) -> dict:
    vehicle_info = decode_vin(vin)
    recalls = get_vehicle_recalls(vin)

    # Mock additional data since public APIs are limited
    # In a real app, use paid services like Carfax for accidents, service reports, odometer discrepancies
    mock_accidents = [
        {
            "date": "2022-05-15",
            "description": "Minor rear-end collision",
            "severity": "Minor"
        }
    ] if len(vin) % 2 == 0 else []  # Mock based on VIN for demo

    mock_service_reports = [
        {
            "date": "2023-01-10",
            "service": "Oil change and tire rotation",
            "mileage": 15000
        },
        {
            "date": "2023-06-20",
            "service": "Brake pad replacement",
            "mileage": 25000
        }
    ]

    mock_odometer_discrepancies = [
        {
            "reported_mileage": 30000,
            "actual_mileage": 32000,
            "discrepancy": 2000
        }
    ] if len(vin) % 3 == 0 else []

    return {
        "vehicle_info": vehicle_info,
        "recalls": recalls,
        "accidents": mock_accidents,
        "service_reports": mock_service_reports,
        "odometer_discrepancies": mock_odometer_discrepancies,
        "registration_details": {
            "status": "Active",
            "expiration_date": "2025-12-31",
            "owner": "Mock Owner"
        }
    }
