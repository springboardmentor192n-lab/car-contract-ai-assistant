# Complete Setup Guide - Car Contract AI Assistant

## Quick Start (5 Minutes)

### Step 1: Install Python
- Download Python 3.8+ from https://www.python.org/downloads/
- During installation, check "Add Python to PATH"
- Verify installation:
```bash
python --version
```

### Step 2: Install Dependencies
Open terminal/command prompt in project folder:
```bash
pip install -r requirements.txt
```

### Step 3: Get OpenAI API Key (Optional but Recommended)
1. Go to https://platform.openai.com/
2. Sign up or log in
3. Navigate to API Keys
4. Create new secret key
5. Copy the key (starts with 'sk-')

### Step 4: Configure Environment
```bash
# Windows
copy .env.example .env

# Mac/Linux
cp .env.example .env
```

Edit `.env` file:
```
OPENAI_API_KEY=sk-your-actual-api-key-here
```

### Step 5: Run the Application
```bash
streamlit run app.py
```

The app will open automatically in your browser at `http://localhost:8501`

## Detailed Setup Instructions

### For Windows Users

1. **Install Python**
   - Download from python.org
   - Run installer
   - Check "Add Python to PATH"
   - Click "Install Now"

2. **Open Command Prompt**
   - Press `Win + R`
   - Type `cmd` and press Enter
   - Navigate to project folder:
   ```bash
   cd path\to\car-contract-ai-assistant
   ```

3. **Create Virtual Environment (Recommended)**
   ```bash
   python -m venv venv
   venv\Scripts\activate
   ```

4. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

5. **Run Application**
   ```bash
   streamlit run app.py
   ```

### For Mac/Linux Users

1. **Install Python**
   ```bash
   # Mac (using Homebrew)
   brew install python3
   
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install python3 python3-pip
   ```

2. **Open Terminal**
   - Navigate to project folder:
   ```bash
   cd path/to/car-contract-ai-assistant
   ```

3. **Create Virtual Environment (Recommended)**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

4. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

5. **Run Application**
   ```bash
   streamlit run app.py
   ```

## First Time Usage

### 1. Register Account
- Open the application
- Enter a username and password
- Click "Register"
- You'll be automatically logged in

### 2. Create Your First Contract

**Option A: AI Generation (Recommended)**
1. Click "Create Contract" in sidebar
2. Select "AI Generation" tab
3. Fill in basic details:
   - Contract type (Sale/Rental/Lease)
   - Customer name and contact
   - Vehicle details (make, model, year, VIN)
   - Price
4. Click "Generate Contract with AI"
5. Review the generated contract
6. Click "Save This Contract"

**Option B: Manual Entry**
1. Click "Create Contract" in sidebar
2. Select "Manual Entry" tab
3. Fill in all fields
4. Write or paste contract text
5. Click "Create Contract"

### 3. View and Manage Contracts
1. Click "View Contracts" in sidebar
2. Use filters to find contracts
3. Click on a contract to expand
4. Available actions:
   - Analyze with AI
   - Update status
   - Delete contract

### 4. Analyze Contracts
1. Click "AI Analysis" in sidebar
2. Paste any contract text
3. Click "Analyze Contract"
4. View risk score and recommendations

## Configuration Options

### OpenAI API Key

**With API Key (Recommended):**
- Full AI features enabled
- Professional contract generation
- Detailed contract analysis
- Smart suggestions

**Without API Key:**
- Template-based contract generation
- Rule-based contract analysis
- Basic functionality works
- No AI costs

### Database

The application uses `database.json` for storage:
- Automatically created on first run
- Stores user accounts (hashed passwords)
- Stores all contracts
- Can be backed up by copying the file

## Troubleshooting

### Issue: "streamlit: command not found"

**Solution:**
```bash
# Reinstall streamlit
pip install streamlit --upgrade

# Or use python -m
python -m streamlit run app.py
```

### Issue: "ModuleNotFoundError: No module named 'openai'"

**Solution:**
```bash
pip install -r requirements.txt
```

### Issue: OpenAI API errors

**Solutions:**
1. Check API key is correct in `.env`
2. Verify you have credits: https://platform.openai.com/account/usage
3. Check internet connection
4. App will work without API key (template mode)

### Issue: Port 8501 already in use

**Solution:**
```bash
# Use different port
streamlit run app.py --server.port 8502
```

### Issue: Database errors

**Solution:**
```bash
# Delete database file and restart
# Windows
del database.json

# Mac/Linux
rm database.json
```

### Issue: Application is slow

**Solutions:**
1. Check internet connection (for AI features)
2. Reduce contract text length
3. Close other applications
4. Restart the application

## Testing the Application

### Manual Test Checklist

- [ ] Register new user
- [ ] Login with credentials
- [ ] View dashboard statistics
- [ ] Create contract manually
- [ ] Generate contract with AI
- [ ] View contracts list
- [ ] Filter contracts by type
- [ ] Filter contracts by status
- [ ] Search contracts by customer name
- [ ] View contract details
- [ ] Analyze contract with AI
- [ ] Update contract status
- [ ] Delete a contract
- [ ] Export contracts to JSON
- [ ] Change password
- [ ] Logout

### Sample Test Data

**Customer Information:**
- Name: John Doe
- Email: john.doe@example.com
- Phone: (555) 123-4567
- License: DL123456789

**Vehicle Information:**
- Make: Toyota
- Model: Camry
- Year: 2024
- VIN: 1HGBH41JXMN109186

**Terms:**
- Price: $25,000
- Type: Sale

## Performance Tips

1. **Use AI Generation Wisely**
   - AI calls cost money
   - Generate once, edit if needed
   - Save generated contracts

2. **Regular Backups**
   - Copy `database.json` regularly
   - Export contracts to JSON
   - Keep backups in safe location

3. **Optimize Filters**
   - Use filters to reduce displayed contracts
   - Search by customer name for quick access

## Security Best Practices

1. **Protect Your API Key**
   - Never share your OpenAI API key
   - Don't commit `.env` to version control
   - Rotate keys periodically

2. **Strong Passwords**
   - Use unique passwords
   - Mix letters, numbers, symbols
   - Change passwords regularly

3. **Data Protection**
   - Backup `database.json` regularly
   - Don't share database file
   - Keep sensitive data secure

## Next Steps

After successful setup:

1. **Customize Templates**
   - Edit `contract_generator.py`
   - Modify contract templates
   - Add your company information

2. **Enhance Features**
   - Add more contract types
   - Customize analysis rules
   - Add export formats (PDF, Word)

3. **Deploy Online**
   - Use Streamlit Cloud (free)
   - Deploy to Heroku
   - Use AWS/Azure

## Getting Help

If you encounter issues:

1. Check this guide
2. Review README.md
3. Check error messages carefully
4. Search for similar issues online
5. Contact support

## Useful Commands

```bash
# Install dependencies
pip install -r requirements.txt

# Run application
streamlit run app.py

# Run on different port
streamlit run app.py --server.port 8502

# Update streamlit
pip install streamlit --upgrade

# Check Python version
python --version

# Check installed packages
pip list

# Create requirements file
pip freeze > requirements.txt
```

## System Requirements

- **OS**: Windows 10+, macOS 10.14+, Linux
- **Python**: 3.8 or higher
- **RAM**: 2GB minimum, 4GB recommended
- **Disk Space**: 500MB
- **Internet**: Required for AI features

## Support

For additional help:
- Email: support@example.com
- Documentation: README.md
- Issues: GitHub Issues page

---

**Congratulations!** You're now ready to use the Car Contract AI Assistant. Start by creating your first contract!
