
-- MySQL Schema for Car Contract AI Assistant

-- Drop tables if they exist to allow for clean re-creation
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS negotiation_sessions;
DROP TABLE IF EXISTS price_benchmarks;
DROP TABLE IF EXISTS market_data;
DROP TABLE IF EXISTS contracts;
DROP TABLE IF EXISTS vin_data;
DROP TABLE IF EXISTS users;

-- 1. `users` table: For user authentication
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. `vin_data` table: Stores details about VINs
CREATE TABLE vin_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vin VARCHAR(17) NOT NULL UNIQUE, -- Standard VIN length is 17 characters
    make VARCHAR(255),
    model VARCHAR(255),
    year INT,
    trim VARCHAR(255),
    data_json JSON, -- Stores raw JSON response from VIN lookup API
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. `contracts` table: Stores details about uploaded contracts
CREATE TABLE contracts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    file_path VARCHAR(512) NOT NULL,
    original_filename VARCHAR(255),
    upload_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ocr_text LONGTEXT, -- Stores extracted text from OCR
    risk_analysis_results JSON, -- Stores JSON results from risk analysis
    status VARCHAR(50) DEFAULT 'uploaded', -- e.g., 'uploaded', 'processing', 'analyzed', 'error'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. `market_data` table: Stores market rate information
CREATE TABLE market_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    region VARCHAR(255),
    vehicle_type VARCHAR(255),
    make VARCHAR(255),
    model VARCHAR(255),
    year INT,
    average_price DECIMAL(10, 2),
    data_source VARCHAR(255),
    recorded_at DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 5. `price_benchmarks` table: Stores price benchmark data for vehicles
CREATE TABLE price_benchmarks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vin_id INT, -- Optional: Link to vin_data if benchmark is VIN-specific
    make VARCHAR(255),
    model VARCHAR(255),
    year INT,
    trim VARCHAR(255),
    mileage_range_start INT,
    mileage_range_end INT,
    condition_grade VARCHAR(50), -- e.g., 'Excellent', 'Good', 'Fair', 'Poor'
    average_benchmark_price DECIMAL(10, 2) NOT NULL,
    source VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vin_id) REFERENCES vin_data(id) ON DELETE SET NULL
);

-- 6. `negotiation_sessions` table: Manages individual negotiation chats
CREATE TABLE negotiation_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    contract_id INT, -- Optional: Link to a specific contract being negotiated
    vin_id INT, -- Optional: Link to a specific VIN data being negotiated
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active', -- e.g., 'active', 'completed', 'archived'
    summary TEXT, -- AI-generated summary of the negotiation
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE SET NULL,
    FOREIGN KEY (vin_id) REFERENCES vin_data(id) ON DELETE SET NULL
);

-- 7. `messages` table: Stores messages within negotiation sessions
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    sender ENUM('user', 'ai') NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES negotiation_sessions(id) ON DELETE CASCADE
);
