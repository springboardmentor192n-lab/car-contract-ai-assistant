To run both the frontend (Flutter Web) and backend (FastAPI) components of your application, follow these steps:

### Running the Backend (FastAPI)

1.  **Open a Terminal/Command Prompt**
    Open a new terminal or command prompt window.

2.  **Navigate to the Backend Directory**
    Change your current directory to the `backend` folder of your project:
    ```bash
    cd E:\autofinance_guardian\backend
    ```

3.  **Create and Activate a Python Virtual Environment (Recommended)**
    It's best practice to use a virtual environment to manage your Python dependencies.
    ```bash
    python -m venv venv
    ```
    Activate the virtual environment:
    *   **Windows (PowerShell):**
        ```bash
        .\venv\Scripts\Activate.ps1
        ```
    *   **Windows (Command Prompt):**
        ```bash
        .\venv\Scripts\activate.bat
        ```
    *   **macOS/Linux:**
        ```bash
        source venv/bin/activate
        ```

4.  **Install Backend Dependencies**
    Install all required Python packages using `pip`:
    ```bash
    pip install -r requirements.txt
    ```

5.  **Run the FastAPI Application**
    Start the FastAPI server. The application typically runs on `http://localhost:8000`.
    ```bash
    uvicorn main:app --reload
    ```
    *   `main:app` refers to the `app` object inside `main.py`.
    *   `--reload` enables auto-reloading of the server when code changes are detected.

    You should see output indicating that the server is running, for example:
    ```
    INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
    INFO:     Started reloader process [xxxxx]
    INFO:     Started server process [xxxxx]
    INFO:     Waiting for application startup.
    INFO:     Application startup complete.
    ```
    Keep this terminal window open and running.

    **Note on CORS:** For your Flutter Web frontend to communicate with the FastAPI backend running on `localhost:8000`, the FastAPI application must be configured to allow Cross-Origin Resource Sharing (CORS) from your Flutter development server's origin (usually `http://localhost:XXXX` where `XXXX` is a port like `5000`, `8080`, etc.). The provided backend is assumed to already handle this.

### Running the Frontend (Flutter Web)

1.  **Open a New Terminal/Command Prompt**
    Open a *second* terminal or command prompt window.

2.  **Navigate to the Frontend Directory**
    Change your current directory to the `frontend/guardian_app` folder:
    ```bash
    cd E:\autofinance_guardian\frontend\guardian_app
    ```

3.  **Get Flutter Dependencies**
    Ensure all Flutter package dependencies are downloaded:
    ```bash
    flutter pub get
    ```

4.  **Run the Flutter Web Application**
    Start the Flutter application in web mode (e.g., in Chrome).
    ```bash
    flutter run -d chrome
    ```
    This command will build the Flutter web application and launch it in a new Chrome browser window. The development server usually runs on a different port than the backend (e.g., `http://localhost:5000`).

    You should see output similar to:
    ```
    Launching lib/main.dart on Chrome in debug mode...
    ...
    lib/main.dart is being served at http://localhost:XXXX
    ```

### Interaction

*   With both the backend and frontend running, your Flutter Web application in the browser will now be able to make API calls to `http://localhost:8000` and establish WebSocket connections.
*   Check the browser's developer console for any network errors (CORS, connection refused) if the frontend isn't displaying data correctly.
*   You can stop the applications by pressing `Ctrl+C` in their respective terminal windows.