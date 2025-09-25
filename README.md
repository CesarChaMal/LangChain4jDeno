# LangChain4j Demo

A Java demonstration project showcasing various LangChain4j integrations with local Ollama models for AI chat interactions.

## Overview

This project demonstrates different approaches to interact with AI language models using the LangChain4j framework, including:
- Basic chat interactions
- Streaming responses
- Service-oriented architecture with memory
- Retry mechanisms with exponential backoff

## Prerequisites

- Java 21 (configured with Zulu distribution)
- Maven 3.x
- [Ollama](https://ollama.ai/) running locally on port 11434
- Llama3.2:1b model installed in Ollama

## Setup

1. Install and start Ollama:
   ```bash
   # Install Ollama and pull the llama3.2:1b model
   ollama pull llama3.2:1b
   ollama serve
   ```

## Usage

Run the interactive menu (automatically builds project if needed):

```bash
# Windows
run.bat

# Unix/Linux/macOS/Git Bash/WSL
chmod +x run
./run
```

The menu provides options for:
1. **HelloWorld** - Basic chat with retry mechanism
2. **ServiceExample** - Exercise coach with memory (remembers last 10 messages)
3. **ResponseWithStreaming** - Real-time streaming responses
4. **Clean & Build Project** - Full clean and build
5. **Compile Only** - Compile source code
6. **Test Project** - Run unit tests
7. **Remove Models** - Remove specific models or all models

## Features

- **Multiple AI Providers**: Supports Ollama, OpenAI, HuggingFace, and Vertex AI
- **Streaming Support**: Real-time token streaming for better user experience
- **Memory Management**: Conversation context retention
- **Retry Logic**: Exponential backoff for robust error handling
- **Exercise Coach**: Specialized system prompt for fitness advice
- **Document Processing**: Apache Tika integration for document parsing
- **Embeddings**: Support for text embeddings and similarity search

## Architecture

- `HelloWorld.java` - Basic chat implementation
- `ServiceExample.java` - Service-oriented chat with memory
- `ResponseWithStreaming.java` - Streaming response handler
- `ChatService.java` - Main service class with memory management
- `ModelCommunication.java` - Interface for AI model interactions
- `UserStreamCommunication.java` - Interface for user interactions

## Dependencies

- LangChain4j 0.30.0 (Core, Ollama, OpenAI, HuggingFace, Vertex AI)
- Testcontainers for integration testing
- TinyLog for logging
- MapDB for data persistence
- JUnit for testing

## Configuration

The application connects to Ollama at `http://localhost:11434` by default. Modify the `LOCALHOST` or `OLLAMA_HOST` constants in the respective classes to change the endpoint.

## License

This is a demonstration project for educational purposes.