package org.example.backendsignlik.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Sign Language to Text conversion service
 * Integrates with TSL (Tunisian Sign Language) model for gesture recognition
 */
@Service
public class SignToTextService {

    private static final Logger logger = LoggerFactory.getLogger(SignToTextService.class);
    
    @Autowired(required = false)
    private TSLModelService tslModelService;
    
    /**
     * Convert sign language video to text
     * Note: Currently supports direct landmark input via predictFromLandmarks()
     * Video processing will be added in future updates
     * 
     * @param videoFileUrl URL to the sign language video file
     * @return Transcribed text from the sign language video
     */
    public String convertToText(String videoFileUrl) {
        if (tslModelService == null || !tslModelService.isReady()) {
            logger.warn("TSL Model Service not available, returning placeholder");
            return "[Sign-to-Text: Model not available. Video: " + videoFileUrl + "]";
        }
        
        // TODO: Future implementation for video processing
        // 1. Download video from URL
        // 2. Extract frames
        // 3. Extract hand landmarks using MediaPipe
        // 4. Run through TSL model
        // 5. Return transcript
        
        // For now, return a placeholder indicating video processing is not yet implemented
        logger.info("Video processing not yet implemented, returning placeholder for: {}", videoFileUrl);
        return "[Sign-to-Text: Video processing coming soon. Video: " + videoFileUrl + "]";
    }
    
    /**
     * Convert hand landmarks directly to text (for real-time gesture recognition)
     * This is the primary method used by the Flutter app
     * 
     * @param landmarks Array of 42 floats (21 hand landmarks × 2 coordinates)
     * @return Predicted TSL gesture text
     */
    public String predictFromLandmarks(float[] landmarks) {
        if (tslModelService == null || !tslModelService.isReady()) {
            logger.warn("TSL Model Service not available");
            throw new IllegalStateException("TSL Model Service is not initialized");
        }
        
        try {
            TSLModelService.PredictionResult result = tslModelService.predict(landmarks);
            
            // Only return prediction if confidence is above threshold
            float confidenceThreshold = 0.5f;
            if (result.getConfidence() < confidenceThreshold) {
                logger.debug("Low confidence prediction: {} (threshold: {})", 
                    result.getConfidence(), confidenceThreshold);
                return ""; // Return empty string for low confidence
            }
            
            logger.debug("Predicted gesture: {} with confidence: {}", 
                result.getLabel(), result.getConfidence());
            
            return result.getLabel();
            
        } catch (Exception e) {
            logger.error("Error predicting gesture from landmarks", e);
            throw new RuntimeException("Failed to predict gesture: " + e.getMessage(), e);
        }
    }
}

