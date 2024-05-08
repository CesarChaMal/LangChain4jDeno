package com.ai.langchain4j;

import java.util.Scanner;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.ollama.OllamaChatModel;

import static java.lang.System.*;

public class HelloWorld {
    // Ollama serve locally on port 11434
    private static final String LOCALHOST = "http://localhost:11434";

    public static void main(String[] args) {
        Scanner scanner = new Scanner(in);
        var model = connectModel("llama2");
        while (true) {
            out.print("""
                    Type 'exit' to quit the program.
                    Enter your prompt:\s""");
            String userPrompt = scanner.nextLine();
            if (userPrompt.equals("exit")) {
                break;
            }
            String response = model.generate(userPrompt);
            out.printf("Response: %s%n", response);
        }
    }

    private static ChatLanguageModel connectModel(String modelName) {
        return OllamaChatModel.builder()
                .baseUrl(LOCALHOST)
                .modelName(modelName)
                .build();
    }
}