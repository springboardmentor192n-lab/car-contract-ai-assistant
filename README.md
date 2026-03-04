# Car Contract AI Assistant 🚗

An intelligent car contract management system powered by AI that helps automate contract generation, analysis, and management for car sales, rentals, and leases.

## Features

- 🤖 **AI-Powered Contract Generation**: Automatically generate professional contracts using OpenAI GPT
- 📊 **Contract Analysis**: Analyze contracts for risks, concerns, and missing clauses
- 📝 **Contract Management**: Create, view, update, and delete contracts
- 👥 **User Authentication**: Secure login and registration system
- 📈 **Dashboard Analytics**: View statistics and recent contracts
- 🔍 **Advanced Filtering**: Filter contracts by type, status, and search by customer name
- 💾 **Data Export**: Export all contracts to JSON format

## Tech Stack

- **Frontend**: Streamlit
- **AI**: OpenAI GPT-3.5-turbo
- **Database**: JSON file-based storage
- **Language**: Python 3.8+

## Installation

### Prerequisites

- Python 3.8 or higher
- OpenAI API key (optional, but recommended for AI features)

### Setup Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd car-contract-ai-assistant
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Configure environment variables**
```bash
copy .env.example .env
```

Edit `.env` file and add your OpenAI API key:
```
OPENAI_API_KEY=sk-your-api-key-here
```

4. **Run the application**
```bash
streamlit run app.py
```

5. **Access the application**
Open your browser and go to: `http://localhost:8501`

## Usage

### First Time Setup

1. **Register**: Create a new account with username and password
2. **Login**: Use your credentials to access the dashboard

### Creating Contracts

#### Manual Entry
1. Navigate to "Create Contract"
2. Select "Manual Entry" tab
3. Fill in all required fields:
   - Contract details (type, status, dates)
   - Customer information
   - Vehicle details
   - Terms and pricing
   - Contract content
4. Click "Create Contract"

#### AI Generation
1. Navigate to "Create Contract"
2. Select "AI Generation" tab
3. Fill in basic information
4. Click "Generate Contract with AI"
5. Review the generated contract
6. Save the contract

### Viewing Contracts

1. Navigate to "View Contracts"
2. Use filters to find specific contracts:
   - Filter by type (Sale/Rental/Lease)
   - Filter by status (Draft/Pending/Active/Completed)
   - Search by customer name
3. Click on a contract to expand and view details
4. Perform actions:
   - Analyze with AI
   - Update status
   - Delete contract

### AI Analysis

1. Navigate to "AI Analysis"
2. Paste any contract text
3. Click "Analyze Contract"
4. View:
   - Risk score (0-100)
   - Concerns and red flags
   - Suggestions for improvement
   - Missing clauses

### Dashboard

View quick statistics:
- Total contracts
- Active contracts
- Draft contracts
- Completed contracts
- Recent contracts list

## Project Structure

```
car-contract-ai-assistant/
│
├── app.py                      # Main Streamlit application
├── contract_generator.py       # AI contract generation logic
├── contract_analyzer.py        # AI contract analysis logic
├── database.py                 # Database operations
├── requirements.txt            # Python dependencies
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore file
├── README.md                  # This file
│
├── database.json              # Auto-generated database file
└── .env                       # Your environment variables (create this)
```

## Features in Detail

### Contract Types

1. **Sale Contracts**: For vehicle purchases
2. **Rental Agreements**: For short-term vehicle rentals
3. **Lease Agreements**: For long-term vehicle leases

### Contract Status

- **Draft**: Initial state, editable
- **Pending**: Awaiting approval
- **Active**: Currently in effect
- **Completed**: Fulfilled contract
- **Cancelled**: Terminated contract

### AI Capabilities

#### Contract Generation
- Generates professional, legally-sound contracts
- Includes all standard clauses
- Customized based on contract type
- Formatted and ready to use

#### Contract Analysis
- Risk assessment (0-100 score)
- Identifies concerns and red flags
- Provides improvement suggestions
- Detects missing clauses
- Legal compliance checking

## Security Features

- Password hashing using SHA-256
- User authentication system
- Session management
- User-specific data access

## Data Storage

The application uses a JSON file (`database.json`) for data storage:
- User credentials (hashed passwords)
- Contract information
- Timestamps and metadata

## Troubleshooting

### OpenAI API Issues

If AI features are not working:
1. Check if your API key is correct in `.env`
2. Verify you have credits in your OpenAI account
3. Check internet connection
4. The app will fall back to template-based generation if AI fails

### Application Won't Start

```bash
# Reinstall dependencies
pip install -r requirements.txt --upgrade

# Check Python version
python --version  # Should be 3.8+

# Run with verbose output
streamlit run app.py --logger.level=debug
```

### Database Issues

If you encounter database errors:
1. Delete `database.json` file
2. Restart the application
3. Register a new account

## Future Enhancements

- [ ] PDF export functionality
- [ ] Email notifications
- [ ] Digital signatures
- [ ] Multi-language support
- [ ] Advanced analytics and reporting
- [ ] Integration with external APIs
- [ ] Mobile responsive design improvements
- [ ] Batch contract processing

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the documentation
3. Open an issue on GitHub

## Acknowledgments

- OpenAI for GPT API
- Streamlit for the amazing framework
- All contributors and users

## Author

Created as part of the Springboard Mentor Program

## Version

Current Version: 1.0.0

---

**Note**: This application is for educational purposes. Always consult with legal professionals for actual contract creation and review.
