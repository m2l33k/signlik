package org.example.backendsignlik.service;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;

/**
 * TSL (Tunisian Sign Language) Model Service
 * Handles TFLite model inference for gesture recognition
 */
@Service
public class TSLModelService {

    private static final Logger logger = LoggerFactory.getLogger(TSLModelService.class);
    
    @Value("${tsl.model.path:classpath:models/tsl_gesture_model.tflite}")
    private String modelPath;
    
    @Value("${tsl.classes.path:classpath:models/tsl_gesture_classes.json}")
    private String classesPath;
    
    @Value("${tsl.python.script:classpath:python/infer_tsl.py}")
    private String pythonScriptPath;
    
    @Value("${tsl.python.command:python3}")
    private String pythonCommand;
    
    private final ResourceLoader resourceLoader;
    private final Gson gson = new Gson();
    private List<String> classes = new ArrayList<>();
    private Path tempModelPath;
    private Path tempClassesPath;
    private Path tempScriptPath;
    
    public TSLModelService(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }
    
    @PostConstruct
    public void init() {
        try {
            // Load classes
            loadClasses();
            
            // Extract resources to temp files for Python script access
            extractResourcesToTemp();
            
            logger.info("TSL Model Service initialized successfully");
            logger.info("Loaded {} TSL gesture classes", classes.size());
        } catch (Exception e) {
            logger.error("Failed to initialize TSL Model Service", e);
        }
    }
    
    private void loadClasses() throws IOException {
        Resource resource = resourceLoader.getResource(classesPath);
        try (InputStream is = resource.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
            
            String[] classArray = gson.fromJson(reader, String[].class);
            classes = List.of(classArray);
            logger.info("Loaded TSL classes: {}", classes);
        }
    }
    
    private void extractResourcesToTemp() throws IOException {
        // Extract model
        Resource modelResource = resourceLoader.getResource(modelPath);
        tempModelPath = Files.createTempFile("tsl_model_", ".tflite");
        try (InputStream is = modelResource.getInputStream()) {
            Files.copy(is, tempModelPath, StandardCopyOption.REPLACE_EXISTING);
        }
        tempModelPath.toFile().deleteOnExit();
        
        // Extract classes
        Resource classesResource = resourceLoader.getResource(classesPath);
        tempClassesPath = Files.createTempFile("tsl_classes_", ".json");
        try (InputStream is = classesResource.getInputStream()) {
            Files.copy(is, tempClassesPath, StandardCopyOption.REPLACE_EXISTING);
        }
        tempClassesPath.toFile().deleteOnExit();
        
        // Extract Python script
        Resource scriptResource = resourceLoader.getResource(pythonScriptPath);
        tempScriptPath = Files.createTempFile("infer_tsl_", ".py");
        try (InputStream is = scriptResource.getInputStream()) {
            Files.copy(is, tempScriptPath, StandardCopyOption.REPLACE_EXISTING);
        }
        tempScriptPath.toFile().deleteOnExit();
        
        // Make script executable
        tempScriptPath.toFile().setExecutable(true);
        
        logger.info("Extracted resources to temp files:");
        logger.info("  Model: {}", tempModelPath);
        logger.info("  Classes: {}", tempClassesPath);
        logger.info("  Script: {}", tempScriptPath);
    }
    
    /**
     * Predict gesture from hand landmarks
     * @param landmarks Array of 42 floats (21 points × 2 coordinates)
     * @return Prediction result with label, confidence, and index
     */
    public PredictionResult predict(float[] landmarks) {
        if (landmarks == null || landmarks.length != 42) {
            throw new IllegalArgumentException("Landmarks must be an array of exactly 42 floats");
        }
        
        try {
            // Convert landmarks to JSON
            String landmarksJson = gson.toJson(landmarks);
            
            // Build command
            ProcessBuilder processBuilder = new ProcessBuilder(
                pythonCommand,
                tempScriptPath.toString(),
                tempModelPath.toString(),
                tempClassesPath.toString(),
                landmarksJson
            );
            
            processBuilder.redirectErrorStream(true);
            
            // Execute Python script
            Process process = processBuilder.start();
            
            // Read output
            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line);
                }
            }
            
            // Wait for process
            int exitCode = process.waitFor();
            
            if (exitCode != 0) {
                logger.error("Python script failed with exit code: {}", exitCode);
                logger.error("Output: {}", output.toString());
                throw new RuntimeException("Model inference failed: " + output.toString());
            }
            
            // Parse result
            JsonObject result = gson.fromJson(output.toString(), JsonObject.class);
            
            return new PredictionResult(
                result.get("index").getAsInt(),
                result.get("label").getAsString(),
                result.get("confidence").getAsFloat()
            );
            
        } catch (Exception e) {
            logger.error("Error during prediction", e);
            throw new RuntimeException("Failed to predict gesture: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get all available TSL gesture classes
     */
    public List<String> getClasses() {
        return new ArrayList<>(classes);
    }
    
    /**
     * Check if model is loaded and ready
     */
    public boolean isReady() {
        return !classes.isEmpty() && 
               tempModelPath != null && 
               tempClassesPath != null && 
               tempScriptPath != null;
    }
    
    /**
     * Prediction result
     */
    public static class PredictionResult {
        private final int index;
        private final String label;
        private final float confidence;
        
        public PredictionResult(int index, String label, float confidence) {
            this.index = index;
            this.label = label;
            this.confidence = confidence;
        }
        
        public int getIndex() {
            return index;
        }
        
        public String getLabel() {
            return label;
        }
        
        public float getConfidence() {
            return confidence;
        }
        
        @Override
        public String toString() {
            return String.format("PredictionResult{index=%d, label='%s', confidence=%.4f}", 
                index, label, confidence);
        }
    }
}

