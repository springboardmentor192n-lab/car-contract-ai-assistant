# To launch both the backend and frontend:

# Ensure you are in the root directory of the project (E:\autofinance_guardian) before running these commands.

# 1. Launch the Backend (FastAPI)
# This assumes Python dependencies are already installed within the virtual environment.
Write-Host "Launching backend (FastAPI)..."
Start-Process -FilePath ".\backend\venv\Scripts\uvicorn.exe" -ArgumentList "backend.main:app --host 0.0.0.0 --port 8000 --reload" -NoNewWindow

# 2. Launch the Frontend (Flutter)
# This assumes Flutter dependencies are already installed.
Write-Host "Launching frontend (Flutter)..."
cd frontend/guardian_app
Start-Process -FilePath "flutter" -ArgumentList "run -d chrome" -NoNewWindow
cd .. # Go back to the root directory

Write-Host "Both backend and frontend should now be launching in the background."
Write-Host "The FastAPI backend will be accessible at http://0.0.0.0:8000"
Write-Host "The Flutter frontend will open in a new Chrome window."