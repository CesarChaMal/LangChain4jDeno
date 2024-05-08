package com.ai.langchain4j;

import java.util.concurrent.CompletableFuture;

public interface UserStreamCommunication {

    CompletableFuture<Void> ask(String prompt);

}