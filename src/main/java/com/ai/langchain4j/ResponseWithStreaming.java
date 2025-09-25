package com.ai.langchain4j;

import java.time.Duration;
import java.util.Scanner;
import java.util.concurrent.CompletableFuture;
import java.util.function.Supplier;

import dev.langchain4j.data.message.AiMessage;
import dev.langchain4j.model.StreamingResponseHandler;
import dev.langchain4j.model.chat.StreamingChatLanguageModel;
import dev.langchain4j.model.ollama.OllamaStreamingChatModel;
import dev.langchain4j.model.output.Response;

import static java.lang.System.*;

public class ResponseWithStreaming {
    // Ollama serve locally on port 11434
    private static final String OLLAMA_HOST = "http://localhost:11434";

    public static void main(String[] args) {
        Scanner scanner = new Scanner(in);
        String modelName = System.getenv("OLLAMA_MODEL");
        if (modelName == null) modelName = "llama3.2:1b";
        var model = connectModel(modelName);
        out.println("Using model: " + modelName);
        while (true) {
            out.print("""
                    Type 'exit' to quit the program.
                    Enter your prompt:\s""");
            String userPrompt = scanner.nextLine();
            if (userPrompt.equals("exit")) {
                break;
            }
            // Change to streaming model
            try {
                withRetry(() -> modelResponse(model, userPrompt), 3, 2000);
            } catch (Exception e) {
                out.println("Failed to get a response after several attempts: " + e.getMessage());
            }
        }
    }

    private static void modelResponse(StreamingChatLanguageModel model, String userPrompt) {
        CompletableFuture<Response<AiMessage>> futureResponse = new CompletableFuture<>();
        model.generate(userPrompt, new StreamingResponseHandler<>() {
            @Override
            public void onNext(String token) {
                out.print(token);
            }

            @Override
            public void onComplete(Response<AiMessage> response) {
                futureResponse.complete(response);
            }

            @Override
            public void onError(Throwable error) {
                futureResponse.completeExceptionally(error);
            }
        });
        futureResponse.join();
    }

    private static StreamingChatLanguageModel connectModel(String modelName) {
        return OllamaStreamingChatModel.builder()
                .baseUrl(OLLAMA_HOST)
                .modelName(modelName)
                .timeout(Duration.ofHours(1))
                .build();
    }

    private static void withRetry(Runnable action, int maxAttempts, long waitTimeInMillis) {
        int attempts = 0;
        while (attempts < maxAttempts) {
            try {
                action.run();
                return;
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
