package org.example.backendsignlik.controller;

import jakarta.validation.Valid;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import org.example.backendsignlik.dto.ErrorResponse;
import org.example.backendsignlik.dto.SignRequest;
import org.example.backendsignlik.dto.SignResponse;
import org.example.backendsignlik.service.SignService;
import org.example.backendsignlik.Security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/signs")
public class SignController {
    
    @Autowired
    private SignService signService;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    /**
     * Add a new sign (POST /api/signs/add)
     * Requires: Specialist role, video/image file, sign name
     */
    @PostMapping("/add")
    public ResponseEntity<?> addSign(
            @RequestHeader("Authorization") String authHeader,
            @RequestParam("file") MultipartFile file,
            @RequestParam("name") String name,
            @RequestParam(value = "description", required = false) String description,
            @RequestParam(value = "category", required = false) String category,
            @RequestParam(value = "difficultyLevel", required = false) String difficultyLevel) {
        
        try {
            // Extract user email from JWT
            String token = authHeader.substring(7); // Remove "Bearer "
            String userEmail = jwtUtil.extractEmail(token);
            
            // Create sign request
            SignRequest signRequest = new SignRequest();
            signRequest.setName(name);
            signRequest.setDescription(description);
            signRequest.setCategory(category);
            signRequest.setDifficultyLevel(difficultyLevel);
            
            // Add sign
            SignResponse response = signService.addSign(userEmail, signRequest, file);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (ExpiredJwtException e) {
            ErrorResponse error = new ErrorResponse("AUTH_ERROR", "JWT token has expired. Please login again.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (JwtException e) {
            ErrorResponse error = new ErrorResponse("AUTH_ERROR", "Invalid JWT token. Please login again.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (IllegalArgumentException e) {
            ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error adding sign: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Get all signs (GET /api/signs)
     */
    @GetMapping
    public ResponseEntity<?> getAllSigns(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "includeUnapproved", defaultValue = "false") boolean includeUnapproved) {
        
        try {
            String userEmail = null;
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                try {
                    String token = authHeader.substring(7);
                    userEmail = jwtUtil.extractEmail(token);
                } catch (Exception e) {
                    // Invalid token, continue as anonymous
                }
            }
            
            if (userEmail == null) {
                userEmail = "anonymous";
            }
            
            List<SignResponse> signs = signService.getAllSigns(userEmail, includeUnapproved);
            return ResponseEntity.ok(signs);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error retrieving signs: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Get sign by ID (GET /api/signs/{id})
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getSignById(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        
        try {
            String userEmail = "anonymous";
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                try {
                    String token = authHeader.substring(7);
                    userEmail = jwtUtil.extractEmail(token);
                } catch (Exception e) {
                    // Invalid token, continue as anonymous
                }
            }
            
            SignResponse sign = signService.getSignById(id, userEmail);
            return ResponseEntity.ok(sign);
        } catch (IllegalArgumentException e) {
            ErrorResponse error = new ErrorResponse("NOT_FOUND", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error retrieving sign: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Search signs (GET /api/signs/search?query=...)
     */
    @GetMapping("/search")
    public ResponseEntity<?> searchSigns(@RequestParam("query") String query) {
        try {
            List<SignResponse> signs = signService.searchSigns(query);
            return ResponseEntity.ok(signs);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error searching signs: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Get signs by category (GET /api/signs/category/{category})
     */
    @GetMapping("/category/{category}")
    public ResponseEntity<?> getSignsByCategory(@PathVariable String category) {
        try {
            List<SignResponse> signs = signService.getSignsByCategory(category);
            return ResponseEntity.ok(signs);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error retrieving signs: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Get signs by specialist (GET /api/signs/specialist/{email})
     */
    @GetMapping("/specialist/{email}")
    public ResponseEntity<?> getSignsBySpecialist(@PathVariable String email) {
        try {
            List<SignResponse> signs = signService.getSignsBySpecialist(email);
            return ResponseEntity.ok(signs);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error retrieving signs: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Get popular signs (GET /api/signs/popular?limit=10)
     */
    @GetMapping("/popular")
    public ResponseEntity<?> getPopularSigns(@RequestParam(value = "limit", defaultValue = "10") int limit) {
        try {
            List<SignResponse> signs = signService.getPopularSigns(limit);
            return ResponseEntity.ok(signs);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error retrieving popular signs: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Get recent signs (GET /api/signs/recent?limit=10)
     */
    @GetMapping("/recent")
    public ResponseEntity<?> getRecentSigns(@RequestParam(value = "limit", defaultValue = "10") int limit) {
        try {
            List<SignResponse> signs = signService.getRecentSigns(limit);
            return ResponseEntity.ok(signs);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error retrieving recent signs: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Update sign (PUT /api/signs/{id})
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateSign(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody SignRequest signRequest) {
        
        try {
            String token = authHeader.substring(7);
            String userEmail = jwtUtil.extractEmail(token);
            
            SignResponse response = signService.updateSign(id, userEmail, signRequest);
            return ResponseEntity.ok(response);
        } catch (ExpiredJwtException e) {
            ErrorResponse error = new ErrorResponse("AUTH_ERROR", "JWT token has expired. Please login again.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (JwtException e) {
            ErrorResponse error = new ErrorResponse("AUTH_ERROR", "Invalid JWT token. Please login again.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (IllegalArgumentException e) {
            ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error updating sign: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Delete sign (DELETE /api/signs/{id})
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSign(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader) {
        
        try {
            String token = authHeader.substring(7);
            String userEmail = jwtUtil.extractEmail(token);
            
            signService.deleteSign(id, userEmail);
            return ResponseEntity.ok("Sign deleted successfully");
        } catch (ExpiredJwtException e) {
            ErrorResponse error = new ErrorResponse("AUTH_ERROR", "JWT token has expired. Please login again.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (JwtException e) {
            ErrorResponse error = new ErrorResponse("AUTH_ERROR", "Invalid JWT token. Please login again.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (IllegalArgumentException e) {
            ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error deleting sign: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
    
    /**
     * Approve sign (PUT /api/signs/{id}/approve)
     */
    @PutMapping("/{id}/approve")
    public ResponseEntity<?> approveSign(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                ErrorResponse error = new ErrorResponse("AUTH_ERROR", "Authorization header is required");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(error);
            }
            
            String token = authHeader.substring(7);
            String userEmail = jwtUtil.extractEmail(token);
            
            SignResponse response = signService.approveSign(id, userEmail);
            return ResponseEntity.ok(response);
        } catch (ExpiredJwtException e) {
            ErrorResponse error = new ErrorResponse("AUTH_ERROR", "JWT token has expired. Please login again.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (JwtException e) {
            ErrorResponse error = new ErrorResponse("AUTH_ERROR", "Invalid JWT token. Please login again.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (IllegalArgumentException e) {
            ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        } catch (Exception e) {
            ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Error approving sign: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(error);
        }
    }
}

