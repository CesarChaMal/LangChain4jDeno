# CLAUDE.md - AI Assistant Guide for LangChain4jDeno

## Project Overview

**Project Name**: LangChain4jDeno
**Type**: Java 21 Maven Project
**Purpose**: Demonstration of LangChain4j framework integrations with local Ollama AI models
**Group ID**: com.ai.langchain4j
**Artifact ID**: langchain4jdemo
**Version**: 0.1-SNAPSHOT

This is a learning/demonstration project showcasing various approaches to AI language model interactions using the LangChain4j framework, focusing on local Ollama deployments.

## Codebase Structure

```
LangChain4jDeno/
├── src/
│   └── main/
│       └── java/
│           └── com/ai/langchain4j/
│               ├── ChatService.java              # Service with memory management
│               ├── HelloWorld.java               # Basic chat example
│               ├── ModelCommunication.java       # Interface with system prompt
│               ├── ResponseWithStreaming.java    # Streaming response handler
│               ├── ServiceExample.java           # Service-oriented example
│               └── UserStreamCommunication.java  # User interaction interface
├── pom.xml                                       # Maven configuration
├── run.sh                                        # Unix/Linux launcher script
├── run.bat                                       # Windows launcher script
├── info.txt                                      # Build/run commands reference
├── .env                                          # Environment configuration
├── .gitignore                                    # Git ignore patterns
└── README.md                                     # User-facing documentation
```

### Source File Purposes

1. **HelloWorld.java** (`src/main/java/com/ai/langchain4j/HelloWorld.java`)
   - Entry point for basic chat interactions
   - Demonstrates retry logic with exponential backoff
   - Uses non-streaming ChatLanguageModel
   - Environment variable: `OLLAMA_MODEL` (default: llama3.2:1b)

2. **ServiceExample.java** (`src/main/java/com/ai/langchain4j/ServiceExample.java`)
   - Entry point for service-oriented chat with memory
   - Uses ChatService with conversation history
   - Demonstrates AiServices pattern

3. **ResponseWithStreaming.java** (`src/main/java/com/ai/langchain4j/ResponseWithStreaming.java`)
   - Entry point for streaming responses
   - Shows real-time token streaming implementation
   - Uses StreamingResponseHandler pattern

4. **ChatService.java** (`src/main/java/com/ai/langchain4j/ChatService.java`)
   - Core service class implementing both interfaces
   - Manages chat memory (10 message window)
   - Uses AiServices builder pattern
   - Implements async response handling with CompletableFuture

5. **ModelCommunication.java** (`src/main/java/com/ai/langchain4j/ModelCommunication.java`)
   - Interface defining model interaction contract
   - Contains `@SystemMessage` annotation with exercise coach prompt
   - Returns TokenStream for streaming responses

6. **UserStreamCommunication.java** (`src/main/java/com/ai/langchain4j/UserStreamCommunication.java`)
   - Interface for user interaction layer
   - Defines async `ask()` method returning CompletableFuture

## Architecture Patterns

### 1. Interface Segregation
- Separate interfaces for model communication and user interaction
- Clean separation of concerns between AI model and user layers

### 2. Service Builder Pattern
```java
AiServices.builder(ModelCommunication.class)
    .streamingChatLanguageModel(languageModel)
    .chatMemory(chatMemory)
    .build();
```

### 3. Retry Pattern with Exponential Backoff
```java
withRetry(() -> model.generate(userPrompt), 3, 2000);
// Attempts: 3, Initial wait: 2000ms, Backoff multiplier: 2x
```

### 4. Async/Streaming Pattern
- CompletableFuture for async operations
- TokenStream with callbacks: onNext, onComplete, onError
- StreamingResponseHandler for real-time responses

### 5. Memory Management
- MessageWindowChatMemory with configurable window (default: 10 messages)
- Maintains conversation context across interactions

## Development Workflows

### Building the Project

**Full Build with Dependencies**:
```bash
mvn -Pcomplete clean install
```
This uses the 'complete' profile which creates a jar-with-dependencies.

**Compile Only**:
```bash
mvn compile
```

**Run Tests**:
```bash
mvn test
```

### Running Applications

**Using Run Scripts** (Recommended):
```bash
# Unix/Linux/macOS/Git Bash/WSL
chmod +x run.sh
./run.sh

# Windows
run.bat
```

**Direct Java Execution**:
```bash
java -cp target/langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar com.ai.langchain4j.HelloWorld
java -cp target/langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar com.ai.langchain4j.ServiceExample
java -cp target/langchain4jdemo-0.1-SNAPSHOT-jar-with-dependencies.jar com.ai.langchain4j.ResponseWithStreaming
```

### Interactive Menu Options

The run scripts provide an interactive menu:
1. HelloWorld - Basic chat with retry
2. ServiceExample - Exercise coach with memory
3. ResponseWithStreaming - Real-time streaming
4. Clean & Build Project
5. Compile Only
6. Test Project
7. Remove Models

## Key Dependencies

### Core LangChain4j (v0.30.0)
- `langchain4j` - Core framework
- `langchain4j-ollama` - Ollama integration
- `langchain4j-open-ai` - OpenAI support
- `langchain4j-hugging-face` - HuggingFace integration
- `langchain4j-vertex-ai` - Google Vertex AI
- `langchain4j-embeddings` - Text embeddings
- `langchain4j-embeddings-all-minilm-l6-v2` - Specific embedding model
- `langchain4j-document-parser-apache-tika` - Document processing

### Testing
- `testcontainers` (v1.19.6) - Container-based testing
- `junit-jupiter-engine` (v5.10.0) - JUnit 5

### Utilities
- `tinylog-impl` (v2.6.2) - Logging
- `slf4j-tinylog` (v2.6.2) - SLF4J bridge
- `mapdb` (v3.0.9) - Data persistence

## Coding Conventions

### 1. Import Organization
```java
// Standard imports grouped
import java.time.Duration;
import java.util.Scanner;

// Framework imports
import dev.langchain4j.model.chat.ChatLanguageModel;

// Static imports last
import static java.lang.System.*;
```

### 2. Constants
- Use `private static final` for configuration
- UPPERCASE_WITH_UNDERSCORES naming
- Default Ollama endpoint: `http://localhost:11434`

### 3. Environment Variables
```java
String modelName = System.getenv("OLLAMA_MODEL");
if (modelName == null) modelName = "llama3.2:1b";
```

### 4. Timeout Configuration
- ChatLanguageModel: `Duration.ofHours(1)`
- StreamingChatLanguageModel: `Duration.ofHours(2)`
- Longer timeouts for streaming to handle large responses

### 5. Error Handling
- Always implement retry logic for model interactions
- Use exponential backoff (2x multiplier)
- Handle InterruptedException properly (restore interrupt flag)
- Provide user-friendly error messages

### 6. Text Blocks
Use text blocks for multi-line strings (Java 13+ feature):
```java
out.print("""
    Type 'exit' to quit the program.
    Enter your prompt:\s""");
```

### 7. Streaming Best Practices
```java
tokenStream.onNext(System.out::print)
    .onComplete(ignored -> {
        System.out.println();
        future.complete(null);
    })
    .onError(Throwable::printStackTrace)
    .start();
```

## Environment Configuration

### Required External Services
- **Ollama**: Must be running on `http://localhost:11434`
- Install: Follow instructions at https://ollama.ai/

### Environment Variables
- `OLLAMA_MODEL`: Override default model (default: llama3.2:1b)

### Recommended Models
1. `gemma2:2b` (1.6GB) - Ultra-fast for laptops
2. `qwen2.5:0.5b` (0.4GB) - Smallest
3. `tinyllama:1.1b` (0.6GB) - Basic fast
4. `llama3.2:1b` (1.3GB) - Balanced (default)
5. `llama2` (3.8GB) - Classic
6. `phi3.5:3.8b` (2.2GB) - Quality

### Java Version
- **Required**: Java 21
- **Distribution**: Zulu (configured via SDKMAN)
- Compiler target: Java 21 (`<release>21</release>`)

## Git Configuration

### Ignored Patterns
- Build outputs: `target/`, `*.class`, `out/`, `build/`
- IDE files: `.idea/`, `.vscode/`, `*.iml`
- Dependencies: `node_modules/`, `bower_components/`
- Custom: `multiplied.txt`, `*input*.txt`

### Branch Strategy
- Development branches use pattern: `claude/claude-md-*`
- Always push to designated feature branches
- Never push directly to main/master

## AI Assistant Guidelines

### When Making Changes

1. **Understand Context First**
   - This is a demonstration/learning project
   - Changes should maintain educational value
   - Keep examples simple and clear

2. **File Modification Priorities**
   - Prefer editing existing files over creating new ones
   - Maintain consistency with existing patterns
   - Don't create unnecessary documentation files

3. **Code Style**
   - Follow existing conventions (see Coding Conventions section)
   - Use Java 21 features appropriately
   - Keep code concise and readable
   - Add comments only when adding complexity

4. **Testing Changes**
   - Always build before committing: `mvn clean compile`
   - Test with Ollama running locally
   - Verify all three main classes still work
   - Check that retry logic handles failures gracefully

5. **Dependencies**
   - Be cautious about adding new dependencies
   - Stick to LangChain4j ecosystem when possible
   - Document any new dependencies in this file

6. **Configuration Changes**
   - Don't hardcode values that vary by environment
   - Use environment variables for external configuration
   - Maintain backward compatibility with existing configs

### Common Tasks

#### Adding a New Example Class
1. Create in `src/main/java/com/ai/langchain4j/`
2. Follow naming pattern: descriptive, PascalCase
3. Include main() method with Scanner for user input
4. Implement retry logic for robustness
5. Support OLLAMA_MODEL environment variable
6. Add to run script menu options
7. Document in README.md

#### Modifying AI Behavior
1. System prompts defined in `@SystemMessage` annotations
2. Memory window size: `MessageWindowChatMemory.withMaxMessages(N)`
3. Model parameters in builder: `.temperature()`, `.topP()`, etc.
4. Timeout configuration in model builders

#### Changing Model Provider
1. Update dependencies in pom.xml (e.g., from ollama to openai)
2. Change model builder class (e.g., `OllamaChatModel` → `OpenAiChatModel`)
3. Update base URL and authentication
4. Adjust timeout values as needed
5. Update documentation

#### Debugging Tips
1. Check Ollama is running: `curl http://localhost:11434`
2. List available models: `ollama list`
3. Test model directly: `ollama run llama3.2:1b`
4. Enable verbose logging if needed
5. Check timeout values for large models

### Anti-Patterns to Avoid

1. **Don't** add emoji unless explicitly requested
2. **Don't** create markdown documentation proactively
3. **Don't** use synchronous blocking calls without retry logic
4. **Don't** ignore exceptions - handle or propagate appropriately
5. **Don't** modify git configuration without user approval
6. **Don't** push to main branch
7. **Don't** add unnecessary abstraction layers
8. **Don't** use preview Java features (stick to Java 21 stable)

### Security Considerations

1. **No Secrets in Code**
   - Never commit API keys, tokens, or credentials
   - Use environment variables or external configuration
   - Check .gitignore includes `.env` files

2. **Input Validation**
   - User prompts pass directly to model (expected behavior)
   - Scanner reads from System.in (safe for demo)
   - Exit command handled explicitly

3. **Network Security**
   - Default: localhost only (http://localhost:11434)
   - If exposing externally, consider HTTPS
   - Validate URLs before connecting

## Project-Specific Notes

### Why "LangChain4jDeno"?
Despite the name, this is a Java project (not Deno/TypeScript). The name may be historical or refer to a related project family.

### Memory Management Strategy
- 10-message window balances context vs. memory usage
- Older messages automatically pruned
- Each service instance has independent memory
- No persistence between application runs (ephemeral)

### Streaming vs. Non-Streaming
- **Non-streaming** (HelloWorld): Simpler, blocks until complete, good for short responses
- **Streaming** (ResponseWithStreaming, ChatService): Better UX, handles long responses, more complex

### System Prompt Design
Current exercise coach prompt demonstrates:
- Role definition: "professional exercise coaching"
- Tone setting: "friendly, polite and concise"
- Output format specification: bullet points
- Constraints: no equipment, small space
- Domain expertise: office syndrome prevention

When modifying system prompts:
- Be specific about desired behavior
- Include output format requirements
- Set clear constraints/limitations
- Define persona and tone

## Build and Runtime Information

### Maven Profiles
- **default**: Standard compilation
- **complete**: Adds assembly plugin for jar-with-dependencies

### Compiler Configuration
```xml
<configuration>
    <release>21</release>
    <compilerArgs>
        <arg>-Xlint:unchecked</arg>
    </compilerArgs>
</configuration>
```
- Enables unchecked warnings for generic types
- Targets Java 21 language level

### Classpath Notes
- Runtime requires jar-with-dependencies (über-jar)
- Contains all LangChain4j dependencies
- No separate dependency installation needed post-build

## Troubleshooting Guide

### Common Issues

1. **"Connection refused" to Ollama**
   - Start Ollama: `ollama serve`
   - Verify: `curl http://localhost:11434`
   - Check firewall settings

2. **Model not found**
   - Pull model: `ollama pull llama3.2:1b`
   - List models: `ollama list`
   - Set correct OLLAMA_MODEL env var

3. **Timeout errors**
   - Increase timeout in model builder
   - Use smaller/faster model
   - Check system resources (RAM, CPU)

4. **Build failures**
   - Verify Java 21: `java -version`
   - Clear Maven cache: `mvn clean`
   - Check internet connection (downloads dependencies)

5. **OutOfMemoryError**
   - Increase JVM heap: `export MAVEN_OPTS="-Xmx2g"`
   - Use smaller model
   - Reduce memory window size

## Future Enhancement Suggestions

When extending this project, consider:

1. **Persistence**: Add conversation history storage (MapDB already available)
2. **Web Interface**: Add REST API or web UI
3. **Multi-Model**: Support switching models mid-conversation
4. **RAG**: Integrate document retrieval (Tika parser available)
5. **Evaluation**: Add response quality metrics
6. **Configuration**: Externalize to properties/YAML file
7. **Testing**: Add integration tests with Testcontainers
8. **Observability**: Enhanced logging and metrics
9. **Error Recovery**: More sophisticated retry strategies
10. **Prompt Templates**: Parameterized system prompts

## Version History

- **0.1-SNAPSHOT**: Initial demonstration implementation
  - Basic chat, streaming, and service examples
  - Ollama integration
  - Memory management
  - Retry logic with exponential backoff

---

**Last Updated**: 2025-11-14
**Java Version**: 21
**LangChain4j Version**: 0.30.0
**Maintained By**: AI Assistant

For questions or issues, refer to:
- LangChain4j Documentation: https://docs.langchain4j.dev/
- Ollama Documentation: https://ollama.ai/
- Project README: `/README.md`
