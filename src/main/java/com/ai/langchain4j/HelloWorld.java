package com.ai.langchain4j;

import java.time.Duration;
import java.util.Scanner;
import java.util.function.Supplier;
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
            try {
                String response = withRetry(() -> model.generate(userPrompt), 3, 2000);
                out.printf("Response: %s%n", response);
            } catch (Exception e) {
                out.println("Failed to get a response after several attempts: " + e.getMessage());
            }
        }
    }

    private static ChatLanguageModel connectModel(String modelName) {
        return OllamaChatModel.builder()
                .baseUrl(LOCALHOST)
                .modelName(modelName)
                .timeout(Duration.ofHours(1))
                .build();
    }

    private static <T> T withRetry(Supplier<T> action, int maxAttempts, long waitTimeInMillis) {
        int attempts = 0;
        while (attempts < maxAttempts) {
            try {
                return action.get();
            } catch (Exception e) {
                attempts++;
                if (attempts >= maxAttempts) {
                    throw e;
                }
                try {
                    Thread.sleep(waitTimeInMillis);
                } catch (InterruptedException interruptedException) {
                    Thread.currentThread().interrupt();
                    throw new RuntimeException(interruptedException);
                }
                waitTimeInMillis *= 2; // Exponential backoff
            }
        }
        throw new RuntimeException("Failed after " + maxAttempts + " attempts");
    }
}