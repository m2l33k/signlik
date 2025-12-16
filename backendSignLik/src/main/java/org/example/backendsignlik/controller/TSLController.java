package org.example.backendsignlik.controller;

import org.example.backendsignlik.service.SignToTextService;
import org.example.backendsignlik.service.TSLModelService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * TSL (Tunisian Sign Language) Model Controller
 * Provides endpoints for gesture recognition
 */
@RestController
@RequestMapping("/api/tsl")
@CrossOrigin(origins = "*")
public class TSLController {

    private static final Logger logger = LoggerFactory.getLogger(TSLController.class);
    
    @Autowired
    private SignToTextService signToTextService;
    
    @Autowired(required = false)
    private TSLModelService tslModelService;
    
    /**
     * Predict gesture from hand landmarks
     * POST /api/tsl/predict
     * 
     * Request body:
     * {
     *   "landmarks": [x1, y1, x2, y2, ..., x21, y21]  // 42 floats
     * }
     * 
     * Response:
     * {
     *   "label": "hello",
     *   "confidence": 0.95,
     *   "index": 0
     * }
     */
    @PostMapping("/predict")
    public ResponseEntity<Map<String, Object>> predictGesture(@RequestBody Map<String, Object> request) {
        try {
            @SuppressWarnings("unchecked")
            List<Number> landmarksList = (List<Number>) request.get("landmarks");
            
            if (landmarksList == null || landmarksList.size() != 42) {
                Map<String, Object> error = new HashMap<>();
                error.put("error", "Invalid landmarks. Expected 42 floats (21 points × 2 coordinates)");
                error.put("received", landmarksList != null ? landmarksList.size() : 0);
                return ResponseEntity.badRequest().body(error);
            }
            
            // Convert to float array
            float[] landmarks = new float[42];
            for (int i = 0; i < 42; i++) {
                landmarks[i] = landmarksList.get(i).floatValue();
            }
            
            // Predict
            String label = signToTextService.predictFromLandmarks(landmarks);
            
            // Get full prediction result if available
            Map<String, Object> response = new HashMap<>();
            if (tslModelService != null && tslModelService.isReady()) {
                TSLModelService.PredictionResult result = tslModelService.predict(landmarks);
                response.put("label", result.getLabel());
                response.put("confidence", result.getConfidence());
                response.put("index", result.getIndex());
            } else {
                response.put("label", label);
                response.put("confidence", 1.0f);
                response.put("index", -1);
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error predicting gesture", e);
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }
    
    /**
     * Get all available TSL gesture classes
     * GET /api/tsl/classes
     */
    @GetMapping("/classes")
    public ResponseEntity<Map<String, Object>> getClasses() {
        try {
            Map<String, Object> response = new HashMap<>();
            
            if (tslModelService != null && tslModelService.isReady()) {
                List<String> classes = tslModelService.getClasses();
                response.put("classes", classes);
                response.put("count", classes.size());
                response.put("status", "ready");
            } else {
                response.put("classes", List.of());
                response.put("count", 0);
                response.put("status", "not_ready");
                response.put("message", "TSL Model Service is not initialized");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error getting classes", e);
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }
    
    /**
     * Check model status
     * GET /api/tsl/status
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getStatus() {
        Map<String, Object> response = new HashMap<>();
        
        if (tslModelService != null && tslModelService.isReady()) {
            response.put("status", "ready");
            response.put("message", "TSL Model is loaded and ready");
            response.put("classes_count", tslModelService.getClasses().size());
        } else {
            response.put("status", "not_ready");
            response.put("message", "TSL Model Service is not initialized");
        }
        
        return ResponseEntity.ok(response);
    }
}

