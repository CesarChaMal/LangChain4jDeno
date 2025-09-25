#!/bin/bash

# Initialize SDKMAN for different environments
# shellcheck disable=SC1091
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

sdk use java 21.fx-zulu

# Check and setup Ollama
echo "Checking Ollama setup..."
if ! command -v ollama &> /dev/null; then
    echo "Ollama not found. Please install Ollama first."
    exit 1
fi

# Show available models and let user choose
echo "Available models:"
ollama list
echo
echo "Recommended models:"
echo "1. gemma2:2b (1.6GB) - Ultra-fast for laptops"
echo "2. qwen2.5:0.5b (0.4GB) - Smallest"
echo "3. tinyllama:1.1b (0.6GB) - Basic fast"
echo "4. llama3.2:1b (1.3GB) - Balanced"
echo "5. llama2 (3.8GB) - Classic"
echo "6. phi3.5:3.8b (2.2GB) - Quality"
echo "7. Use existing model"
echo
read -p "Choose option (1-7): " model_choice

case $model_choice in
    1) 
        MODEL_NAME="gemma2:2b"
        if ! ollama list | grep -q "$MODEL_NAME"; then
            echo "Pulling $MODEL_NAME..."
            ollama pull $MODEL_NAME
        fi
        ;;
    2) 
        MODEL_NAME="qwen2.5:0.5b"
        if ! ollama list | grep -q "$MODEL_NAME"; then
            echo "Pulling $MODEL_NAME..."
            ollama pull $MODEL_NAME
        fi
        ;;
    3) 
        MODEL_NAME="tinyllama:1.1b"
        if ! ollama list | grep -q "$MODEL_NAME"; then
            echo "Pulling $MODEL_NAME..."
            ollama pull $MODEL_NAME
        fi
        ;;
    4) 
        MODEL_NAME="llama3.2:1b"
        if ! ollama list | grep -q "$MODEL_NAME"; then
            echo "Pulling $MODEL_NAME..."
            ollama pull $MODEL_NAME
        fi
        ;;
    5) 
        MODEL_NAME="llama2"
        if ! ollama list | grep -q "$MODEL_NAME"; then
            echo "Pulling $MODEL_NAME..."
            ollama pull $MODEL_NAME
        fi
        ;;
    6) 
        MODEL_NAME="phi3.5:3.8b"
        if ! ollama list | grep -q "$MODEL_NAME"; then
            echo "Pulling $MODEL_NAME..."
            ollama pull $MODEL_NAME
        fi
        ;;
    7) 
        echo "Enter model name from the list above:"
        read -p "Model name: " MODEL_NAME
        ;;
    *) 
        echo "Invalid choice. Using gemma2:2b as default."
        MODEL_NAME="gemma2:2b"
        if ! ollama list | grep -q "$MODEL_NAME"; then
            ollama pull $MODEL_NAME
        fi
        ;;
esac

echo "Selected model: $MODEL_NAME"
echo "OLLAMA_MODEL=$MODEL_NAME" > .env

# Check if Ollama is running by testing the API
echo "Checking if Ollama is running..."
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "Starting Ollama..."
    ollama serve > /dev/null 2>&1 &
    sleep 5
else
    echo "Ollama is already running."
fi

while true; do
    echo
    echo "LangChain4j Demo - Main Menu:"
    echo "1. HelloWorld - Basic Chat"
    echo "2. ServiceExample - Chat with Memory"
    echo "3. ResponseWithStreaming - Real-time Streaming"
    echo "4. Clean & Build Project"
    echo "5. Compile Only"
    echo "6. Test Project"
    echo "7. Remove Models"
    echo "8. Exit"
    echo
    read -p "Enter your choice (1-8): " choice
    
    case $choice in
        1) 
            if [ ! -f "target/langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar" ]; then
                echo "Building project..."
                if ! mvn -Pcomplete clean install; then
                    echo "Build failed. Please check the errors above."
                    continue
                fi
            else
                echo "Using existing build..."
            fi
            export OLLAMA_MODEL=$(grep OLLAMA_MODEL .env | cut -d '=' -f2)
            if ! java -cp target/langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar com.ai.langchain4j.HelloWorld; then
                echo "Java execution failed."
            fi
            ;;
        2) 
            if [ ! -f "target/langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar" ]; then
                echo "Building project..."
                if ! mvn -Pcomplete clean install; then
                    echo "Build failed. Please check the errors above."
                    continue
                fi
            else
                echo "Using existing build..."
            fi
            export OLLAMA_MODEL=$(grep OLLAMA_MODEL .env | cut -d '=' -f2)
            if ! java -cp target/langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar com.ai.langchain4j.ServiceExample; then
                echo "Java execution failed."
            fi
            ;;
        3) 
            if [ ! -f "target/langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar" ]; then
                echo "Building project..."
                if ! mvn -Pcomplete clean install; then
                    echo "Build failed. Please check the errors above."
                    continue
                fi
            else
                echo "Using existing build..."
            fi
            export OLLAMA_MODEL=$(grep OLLAMA_MODEL .env | cut -d '=' -f2)
            if ! java -cp target/langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar com.ai.langchain4j.ResponseWithStreaming; then
                echo "Java execution failed."
            fi
            ;;
        4) 
            echo "Cleaning and building project..."
            if ! mvn -Pcomplete clean install; then
                echo "Build failed. Please check the errors above."
            fi
            ;;
        5) 
            echo "Compiling project..."
            if ! mvn compile; then
                echo "Compilation failed. Please check the errors above."
            fi
            ;;
        6) 
            echo "Running tests..."
            if ! mvn test; then
                echo "Tests failed. Please check the errors above."
            fi
            ;;
        7) 
            echo "Available models:"
            ollama list
            echo
            read -p "Enter model name to remove (or 'all' to remove all): " remove_model
            if [ "$remove_model" = "all" ]; then
                echo "Removing all models..."
                ollama list | grep -v "NAME" | awk '{print $1}' | xargs -I {} ollama rm {}
            else
                echo "Removing $remove_model..."
                ollama rm "$remove_model"
            fi
            ;;
        8) exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done