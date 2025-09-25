package com.ai.langchain4j;

import java.util.Scanner;

public class ServiceExample {

    // Ollama serve locally on port 11434
    private static final String OLLAMA_HOST = "http://localhost:11434";

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        String modelName = System.getenv("OLLAMA_MODEL");
        if (modelName == null) modelName = "llama3.2:1b";
        ChatService chatService = new ChatService(OLLAMA_HOST, modelName);
        System.out.println("Using model: " + modelName);
        while (true) {
            System.out.print("""
                    Type 'exit' to quit the program.
                    Enter your prompt:\s""");
            String userPrompt = scanner.nextLine();
            if (userPrompt.equals("exit")) {
                break;
            }
            // Change to streaming model
            chatService.ask(userPrompt)
                    .join();
        }
    }
}