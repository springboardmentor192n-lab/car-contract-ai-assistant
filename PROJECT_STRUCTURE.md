# Project Structure

## Overview

This document describes the structure and organization of the Car Contract AI Assistant project.

## Directory Structure

```
car-contract-ai-assistant/
│
├── app.py                          # Main Streamlit application
├── contract_generator.py           # AI contract generation module
├── contract_analyzer.py            # AI contract analysis module
├── database.py                     # Database operations module
├── test_app.py                     # Test suite for the application
│
├── requirements.txt                # Python dependencies
├── .env.example                    # Environment variables template
├── .env                            # Environment variables (create this)
├── .gitignore                      # Git ignore rules
│
├── README.md                       # Main documentation
├── SETUP_GUIDE.md                  # Detailed setup instructions
├── FEATURES_DOCUMENTATION.md       # Complete features list
├── PROJECT_STRUCTURE.md            # This file
├── API_DOCUMENTATION.md            # API documentation (legacy)
├── DEPLOYMENT.md                   # Deployment guide (legacy)
├── CONTRIBUTING.md                 # Contribution guidelines
├── LICENSE                         # MIT License
│
└── database.json                   # Auto-generated database file
```

## Core Files

### app.py
**Purpose**: Main application file containing the Streamlit UI

**Key Components**:
- Page configuration
- Session state management
- Login/Registration pages
- Dashboard
- Contract creation forms
- Contract viewing and management
- AI analysis interface
- Settings page

**Functions**:
- `login_page()`: User authentication interface
- `main_app()`: Main application after login
- `show_dashboard()`: Dashboard with statistics
- `create_contract()`: Contract creation interface
- `manual_contract_form()`: Manual entry form
- `ai_contract_form()`: AI generation form
- `view_contracts()`: Contract list and management
- `ai_analysis()`: AI analysis interface
- `settings()`: User settings and preferences

### contract_generator.py
**Purpose**: Generate professional car contracts

**Key Components**:
- OpenAI API integration
- Template-based generation (fallback)
- Contract type handling (Sale/Rental/Lease)

**Class**: `ContractGenerator`

**Methods**:
- `__init__()`: Initialize with API key
- `generate_contract()`: Main generation method
- `_generate_with_ai()`: AI-powered generation
- `_generate_template()`: Template-based generation

**Features**:
- Automatic fallback to templates
- Professional formatting
- Legal clause inclusion
- Customization based on contract type

### contract_analyzer.py
**Purpose**: Analyze contracts for risks and issues

**Key Components**:
- OpenAI API integration
- Rule-based analysis (fallback)
- Risk scoring system

**Class**: `ContractAnalyzer`

**Methods**:
- `__init__()`: Initialize with API key
- `analyze_contract()`: Main analysis method
- `_analyze_with_ai()`: AI-powered analysis
- `_analyze_template()`: Rule-based analysis

**Analysis Output**:
- Risk score (0-100)
- Concerns and red flags
- Improvement suggestions
- Missing clauses

### database.py
**Purpose**: Handle all database operations

**Key Components**:
- JSON file-based storage
- User management
- Contract CRUD operations
- Password hashing

**Class**: `Database`

**Methods**:
- `__init__()`: Initialize database
- `_load_data()`: Load from JSON file
- `_save_data()`: Save to JSON file
- `_hash_password()`: Hash passwords
- `create_user()`: Create new user
- `verify_user()`: Verify credentials
- `change_password()`: Update password
- `save_contract()`: Save new contract
- `get_user_contracts()`: Get user's contracts
- `get_contract_by_id()`: Get specific contract
- `update_contract_status()`: Update status
- `delete_contract()`: Delete contract

**Data Structure**:
```json
{
  "users": {
    "username": {
      "password": "hashed_password",
      "created_at": "timestamp"
    }
  },
  "contracts": [
    {
      "contract_id": "CNT-00001",
      "type": "sale",
      "status": "active",
      "customer_name": "John Doe",
      ...
    }
  ]
}
```

### test_app.py
**Purpose**: Test suite for verifying installation and functionality

**Test Functions**:
- `test_imports()`: Verify package installation
- `test_modules()`: Test custom modules
- `test_database()`: Test database operations
- `test_contract_generator()`: Test contract generation
- `test_contract_analyzer()`: Test contract analysis

**Usage**:
```bash
python test_app.py
```

## Configuration Files

### requirements.txt
Lists all Python dependencies:
- streamlit: Web framework
- openai: AI integration
- python-dotenv: Environment variables
- pandas: Data manipulation
- plotly: Data visualization

### .env.example
Template for environment variables:
```
OPENAI_API_KEY=your-openai-api-key-here
```

### .env
Actual environment variables (not in version control):
```
OPENAI_API_KEY=sk-actual-key-here
```

### .gitignore
Specifies files to ignore in version control:
- Python cache files
- Environment files
- Database files
- IDE files
- OS files

## Documentation Files

### README.md
- Project overview
- Quick start guide
- Features list
- Installation instructions
- Usage examples
- Troubleshooting

### SETUP_GUIDE.md
- Detailed setup instructions
- Platform-specific guides
- First-time usage
- Configuration options
- Troubleshooting
- Testing checklist

### FEATURES_DOCUMENTATION.md
- Complete feature list
- Detailed descriptions
- Usage examples
- Best practices
- Future enhancements

### PROJECT_STRUCTURE.md
- This file
- Project organization
- File descriptions
- Architecture overview

### CONTRIBUTING.md
- Contribution guidelines
- Code style
- Pull request process
- Issue reporting

### LICENSE
- MIT License
- Usage terms
- Copyright information

## Data Flow

### User Registration/Login
```
User Input → app.py → database.py → database.json
```

### Contract Creation (Manual)
```
User Input → app.py → database.py → database.json
```

### Contract Creation (AI)
```
User Input → app.py → contract_generator.py → OpenAI API
                                            ↓
                                    Generated Contract
                                            ↓
                                      database.py → database.json
```

### Contract Analysis
```
Contract Text → app.py → contract_analyzer.py → OpenAI API
                                               ↓
                                         Analysis Results
                                               ↓
                                          Display to User
```

### Contract Management
```
User Action → app.py → database.py → database.json
                                    ↓
                              Updated Data
                                    ↓
                              Refresh UI
```

## Architecture

### Frontend (Streamlit)
- User interface
- Form handling
- Data display
- Navigation
- Session management

### Backend (Python)
- Business logic
- Data processing
- API integration
- Database operations

### Storage (JSON)
- User data
- Contract data
- Persistent storage
- Easy backup

### External Services
- OpenAI API (optional)
- AI generation
- AI analysis

## Security

### Password Security
- SHA-256 hashing
- No plain text storage
- Secure verification

### Data Security
- User-specific access
- Session-based auth
- Input validation

### API Security
- Environment variables
- No hardcoded keys
- Secure transmission

## Performance

### Optimization
- Efficient data loading
- Lazy loading
- Caching where appropriate
- Minimal API calls

### Scalability
- JSON database (suitable for small-medium scale)
- Can be upgraded to SQL database
- Modular architecture
- Easy to extend

## Future Architecture

### Planned Improvements
- PostgreSQL/MySQL database
- RESTful API layer
- Microservices architecture
- Docker containerization
- Cloud deployment
- Load balancing
- Caching layer (Redis)
- Message queue (RabbitMQ)

### Potential Integrations
- Payment gateways
- Email services
- SMS notifications
- Cloud storage
- CRM systems
- Analytics platforms

## Development Workflow

### Local Development
1. Clone repository
2. Install dependencies
3. Configure environment
4. Run tests
5. Start application
6. Make changes
7. Test changes
8. Commit and push

### Testing
1. Run test suite
2. Manual testing
3. Check all features
4. Verify AI integration
5. Test edge cases

### Deployment
1. Update dependencies
2. Run tests
3. Build application
4. Deploy to server
5. Configure production settings
6. Monitor performance

## Maintenance

### Regular Tasks
- Update dependencies
- Backup database
- Monitor API usage
- Check error logs
- Review security

### Updates
- Bug fixes
- Feature additions
- Performance improvements
- Security patches
- Documentation updates

---

**Last Updated**: 2026-03-04
**Version**: 1.0.0
