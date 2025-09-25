@echo off
sdk use java 21.fx-zulu

echo Checking Ollama setup...
where ollama >nul 2>nul
if %errorlevel% neq 0 (
    echo Ollama not found. Please install Ollama first.
    pause
    exit /b 1
)

echo Available models:
ollama list
echo.
echo Recommended models:
echo 1. gemma2:2b (1.6GB) - Ultra-fast for laptops
echo 2. qwen2.5:0.5b (0.4GB) - Smallest
echo 3. tinyllama:1.1b (0.6GB) - Basic fast
echo 4. llama3.2:1b (1.3GB) - Balanced
echo 5. llama2 (3.8GB) - Classic
echo 6. phi3.5:3.8b (2.2GB) - Quality
echo 7. Use existing model
echo.
set /p model_choice="Choose option (1-7): "

if "%model_choice%"=="1" (
    set MODEL_NAME=gemma2:2b
    ollama list | findstr "gemma2:2b" >nul
    if %errorlevel% neq 0 (
        echo Pulling gemma2:2b...
        ollama pull gemma2:2b
    )
) else if "%model_choice%"=="2" (
    set MODEL_NAME=qwen2.5:0.5b
    ollama list | findstr "qwen2.5:0.5b" >nul
    if %errorlevel% neq 0 (
        echo Pulling qwen2.5:0.5b...
        ollama pull qwen2.5:0.5b
    )
) else if "%model_choice%"=="3" (
    set MODEL_NAME=tinyllama:1.1b
    ollama list | findstr "tinyllama:1.1b" >nul
    if %errorlevel% neq 0 (
        echo Pulling tinyllama:1.1b...
        ollama pull tinyllama:1.1b
    )
) else if "%model_choice%"=="4" (
    set MODEL_NAME=llama3.2:1b
    ollama list | findstr "llama3.2:1b" >nul
    if %errorlevel% neq 0 (
        echo Pulling llama3.2:1b...
        ollama pull llama3.2:1b
    )
) else if "%model_choice%"=="5" (
    set MODEL_NAME=llama2
    ollama list | findstr "llama2" >nul
    if %errorlevel% neq 0 (
        echo Pulling llama2...
        ollama pull llama2
    )
) else if "%model_choice%"=="6" (
    set MODEL_NAME=phi3.5:3.8b
    ollama list | findstr "phi3.5:3.8b" >nul
    if %errorlevel% neq 0 (
        echo Pulling phi3.5:3.8b...
        ollama pull phi3.5:3.8b
    )
) else if "%model_choice%"=="7" (
    set /p MODEL_NAME="Enter model name from the list above: "
) else (
    echo Invalid choice. Using gemma2:2b as default.
    set MODEL_NAME=gemma2:2b
    ollama list | findstr "gemma2:2b" >nul
    if %errorlevel% neq 0 (
        ollama pull gemma2:2b
    )
)

echo Selected model: %MODEL_NAME%
echo OLLAMA_MODEL=%MODEL_NAME% > .env

echo Checking if Ollama is running...
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% neq 0 (
    echo Starting Ollama...
    start /B ollama serve
    timeout /t 5 /nobreak >nul
) else (
    echo Ollama is already running.
)

:menu
echo.
echo LangChain4j Demo - Main Menu:
echo 1. HelloWorld - Basic chat with retry mechanism
echo 2. ServiceExample - Exercise coach with memory (remembers last 10 messages)
echo 3. ResponseWithStreaming - Real-time streaming responses
echo 4. Clean ^& Build Project
echo 5. Compile Only
echo 6. Test Project
echo 7. Remove Models
echo 8. Exit
echo.
set /p choice="Enter your choice (1-8): "

if "%choice%"=="1" (
    if not exist "target\langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar" (
        echo Building project...
        mvn -Pcomplete clean install
        if %errorlevel% neq 0 (
            echo Build failed. Please check the errors above.
            goto menu
        )
    ) else (
        echo Using existing build...
    )
    for /f "tokens=2 delims==" %%i in ('findstr OLLAMA_MODEL .env') do set OLLAMA_MODEL=%%i
    java -cp target\langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar com.ai.langchain4j.HelloWorld
    if %errorlevel% neq 0 echo Java execution failed.
    goto menu
)
if "%choice%"=="2" (
    if not exist "target\langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar" (
        echo Building project...
        mvn -Pcomplete clean install
        if %errorlevel% neq 0 (
            echo Build failed. Please check the errors above.
            goto menu
        )
    ) else (
        echo Using existing build...
    )
    for /f "tokens=2 delims==" %%i in ('findstr OLLAMA_MODEL .env') do set OLLAMA_MODEL=%%i
    java -cp target\langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar com.ai.langchain4j.ServiceExample
    if %errorlevel% neq 0 echo Java execution failed.
    goto menu
)
if "%choice%"=="3" (
    if not exist "target\langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar" (
        echo Building project...
        mvn -Pcomplete clean install
        if %errorlevel% neq 0 (
            echo Build failed. Please check the errors above.
            goto menu
        )
    ) else (
        echo Using existing build...
    )
    for /f "tokens=2 delims==" %%i in ('findstr OLLAMA_MODEL .env') do set OLLAMA_MODEL=%%i
    java -cp target\langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar com.ai.langchain4j.ResponseWithStreaming
    if %errorlevel% neq 0 echo Java execution failed.
    goto menu
)
if "%choice%"=="4" (
    echo Cleaning and building project...
    mvn -Pcomplete clean install
    if %errorlevel% neq 0 echo Build failed. Please check the errors above.
    goto menu
)
if "%choice%"=="5" (
    echo Compiling project...
    mvn compile
    if %errorlevel% neq 0 echo Compilation failed. Please check the errors above.
    goto menu
)
if "%choice%"=="6" (
    echo Running tests...
    mvn test
    if %errorlevel% neq 0 echo Tests failed. Please check the errors above.
    goto menu
)
if "%choice%"=="7" (
    echo Available models:
    ollama list
    echo.
    set /p remove_model="Enter model name to remove (or 'all' to remove all): "
    if "%remove_model%"=="all" (
        echo Removing all models...
        for /f "skip=1 tokens=1" %%i in ('ollama list') do ollama rm %%i
    ) else (
        echo Removing %remove_model%...
        ollama rm "%remove_model%"
    )
    goto menu
)
if "%choice%"=="8" exit

echo Invalid choice. Please try again.
goto menu