package org.example.backendsignlik.service;

import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.repository.MessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class ModalityConversionService {

    @Autowired
    private SpeechToTextService speechToTextService;
    
    @Autowired
    private TextToSpeechService textToSpeechService;
    
    @Autowired
    private SignToTextService signToTextService;
    
    @Autowired
    private MessageRepository messageRepository;

    /**
     * Process VOICE message: Convert to TEXT transcript
     */
    @Async("conversionExecutor")
    public CompletableFuture<Void> processVoiceMessage(Long messageId, String audioFileUrl) {
        return CompletableFuture.runAsync(() -> {
            try {
                // Update status to PROCESSING
                messageRepository.findById(messageId).ifPresent(message -> {
                    message.setConversionStatus("PROCESSING");
                    messageRepository.save(message);
                });
                
                // Convert voice to text
                String transcript = speechToTextService.convertToText(audioFileUrl);
                
                // Update message with transcript
                messageRepository.findById(messageId).ifPresent(message -> {
                    message.setTranscript(transcript);
                    message.setConversionStatus("COMPLETED");
                    messageRepository.save(message);
                });
            } catch (Exception e) {
                // Mark as failed on error
                messageRepository.findById(messageId).ifPresent(message -> {
                    message.setConversionStatus("FAILED");
                    messageRepository.save(message);
                });
                System.err.println("Error processing voice message: " + e.getMessage());
            }
        });
    }

    /**
     * Process SIGN message: Convert to TEXT (future ML integration)
     */
    @Async("conversionExecutor")
    public CompletableFuture<Void> processSignMessage(Long messageId, String videoFileUrl) {
        return CompletableFuture.runAsync(() -> {
            try {
                // Update status to PROCESSING
                messageRepository.findById(messageId).ifPresent(message -> {
                    message.setConversionStatus("PROCESSING");
                    messageRepository.save(message);
                });
                
                // Convert sign language video to text
                String transcript = signToTextService.convertToText(videoFileUrl);
                
                // Update message with transcript
                messageRepository.findById(messageId).ifPresent(message -> {
                    message.setTranscript(transcript);
                    message.setConversionStatus("COMPLETED");
                    messageRepository.save(message);
                });
            } catch (Exception e) {
                // Mark as failed on error
                messageRepository.findById(messageId).ifPresent(message -> {
                    message.setConversionStatus("FAILED");
                    messageRepository.save(message);
                });
                System.err.println("Error processing sign message: " + e.getMessage());
            }
        });
    }

    /**
     * Convert TEXT to VOICE (TTS)
     */
    @Async("conversionExecutor")
    public CompletableFuture<String> textToVoice(String text, String language) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                return textToSpeechService.convertToSpeech(text, language);
            } catch (Exception e) {
                System.err.println("Error converting text to voice: " + e.getMessage());
                return null;
            }
        });
    }
}

