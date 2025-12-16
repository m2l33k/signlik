package org.example.backendsignlik.service;

import org.example.backendsignlik.dto.SignRequest;
import org.example.backendsignlik.dto.SignResponse;
import org.example.backendsignlik.entity.SignEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.model.Role;
import org.example.backendsignlik.repository.SignRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class SignService {
    
    @Autowired
    private SignRepository signRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private StorageService storageService;
    
    @Autowired
    private VirusScanService virusScanService;
    
    // Allowed video/image MIME types
    private static final List<String> ALLOWED_CONTENT_TYPES = List.of(
        "video/mp4", "video/webm", "video/quicktime", "video/x-msvideo",
        "image/jpeg", "image/png", "image/gif", "image/webp"
    );
    
    private static final long MAX_FILE_SIZE = 100 * 1024 * 1024; // 100MB
    
    /**
     * Add a new sign (video/image) by a specialist
     */
    public SignResponse addSign(String specialistEmail, SignRequest signRequest, MultipartFile videoFile) throws Exception {
        // Verify user exists and is a specialist
        UserEntity user = userRepository.findByEmail(specialistEmail)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        if (user.getRole() != Role.SPECIALIST) {
            throw new IllegalArgumentException("Only specialists can add signs");
        }
        
        // Check if sign name already exists
        if (signRepository.findByName(signRequest.getName()).isPresent()) {
            throw new IllegalArgumentException("A sign with this name already exists");
        }
        
        // Validate file
        validateFile(videoFile);
        
        // Virus scan
        if (!virusScanService.scanFile(videoFile)) {
            throw new IllegalArgumentException("File failed virus scan or validation");
        }
        
        // Upload video to storage
        String videoUrl = storageService.uploadFile(videoFile, "signs");
        
        // Create sign entity
        SignEntity signEntity = new SignEntity();
        signEntity.setName(signRequest.getName());
        signEntity.setDescription(signRequest.getDescription());
        signEntity.setVideoUrl(videoUrl);
        signEntity.setCreatedBy(specialistEmail);
        signEntity.setCategory(signRequest.getCategory());
        signEntity.setDifficultyLevel(signRequest.getDifficultyLevel());
        signEntity.setFileSize(videoFile.getSize());
        signEntity.setContentType(videoFile.getContentType());
        signEntity.setIsApproved(false); // Requires approval by default
        signEntity.setCreatedAt(LocalDateTime.now());
        
        // Save to database
        signEntity = signRepository.save(signEntity);
        
        // Convert to response
        return convertToResponse(signEntity);
    }
    
    /**
     * Get all signs (approved only for non-specialists)
     */
    public List<SignResponse> getAllSigns(String userEmail, boolean includeUnapproved) {
        List<SignEntity> signs;
        
        if (includeUnapproved) {
            // Check if user is specialist or admin
            Optional<UserEntity> user = userRepository.findByEmail(userEmail);
            if (user.isPresent() && user.get().getRole() == Role.SPECIALIST) {
                signs = signRepository.findAll();
            } else {
                signs = signRepository.findByIsApproved(true);
            }
        } else {
            signs = signRepository.findByIsApproved(true);
        }
        
        return signs.stream()
            .map(this::convertToResponse)
            .collect(Collectors.toList());
    }
    
    /**
     * Get sign by ID
     */
    public SignResponse getSignById(Long id, String userEmail) throws Exception {
        SignEntity sign = signRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Sign not found"));
        
        // Check if user can view unapproved signs
        Optional<UserEntity> user = userRepository.findByEmail(userEmail);
        boolean canViewUnapproved = user.isPresent() && user.get().getRole() == Role.SPECIALIST;
        
        if (!sign.getIsApproved() && !canViewUnapproved) {
            throw new IllegalArgumentException("Sign is not approved yet");
        }
        
        // Increment view count
        sign.setViewCount(sign.getViewCount() + 1);
        signRepository.save(sign);
        
        return convertToResponse(sign);
    }
    
    /**
     * Get signs by category
     */
    public List<SignResponse> getSignsByCategory(String category) {
        List<SignEntity> signs = signRepository.findByCategory(category);
        return signs.stream()
            .filter(s -> s.getIsApproved())
            .map(this::convertToResponse)
            .collect(Collectors.toList());
    }
    
    /**
     * Search signs by name or description
     */
    public List<SignResponse> searchSigns(String query) {
        List<SignEntity> signs = signRepository.searchSigns(query);
        return signs.stream()
            .filter(s -> s.getIsApproved())
            .map(this::convertToResponse)
            .collect(Collectors.toList());
    }
    
    /**
     * Get signs created by a specific specialist
     */
    public List<SignResponse> getSignsBySpecialist(String specialistEmail) {
        List<SignEntity> signs = signRepository.findByCreatedBy(specialistEmail);
        return signs.stream()
            .map(this::convertToResponse)
            .collect(Collectors.toList());
    }
    
    /**
     * Get popular signs (by view count)
     */
    public List<SignResponse> getPopularSigns(int limit) {
        List<SignEntity> signs = signRepository.findPopularSigns();
        return signs.stream()
            .limit(limit)
            .map(this::convertToResponse)
            .collect(Collectors.toList());
    }
    
    /**
     * Get recent signs
     */
    public List<SignResponse> getRecentSigns(int limit) {
        List<SignEntity> signs = signRepository.findRecentSigns();
        return signs.stream()
            .limit(limit)
            .map(this::convertToResponse)
            .collect(Collectors.toList());
    }
    
    /**
     * Update sign (only by creator or admin)
     */
    public SignResponse updateSign(Long id, String userEmail, SignRequest signRequest) throws Exception {
        SignEntity sign = signRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Sign not found"));
        
        // Check permissions
        UserEntity user = userRepository.findByEmail(userEmail)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        if (!sign.getCreatedBy().equals(userEmail) && user.getRole() != Role.SPECIALIST) {
            throw new IllegalArgumentException("You don't have permission to update this sign");
        }
        
        // Update fields
        if (signRequest.getName() != null && !signRequest.getName().isEmpty()) {
            // Check if new name conflicts with existing sign
            Optional<SignEntity> existing = signRepository.findByName(signRequest.getName());
            if (existing.isPresent() && !existing.get().getId().equals(id)) {
                throw new IllegalArgumentException("A sign with this name already exists");
            }
            sign.setName(signRequest.getName());
        }
        
        if (signRequest.getDescription() != null) {
            sign.setDescription(signRequest.getDescription());
        }
        
        if (signRequest.getCategory() != null) {
            sign.setCategory(signRequest.getCategory());
        }
        
        if (signRequest.getDifficultyLevel() != null) {
            sign.setDifficultyLevel(signRequest.getDifficultyLevel());
        }
        
        sign.setUpdatedAt(LocalDateTime.now());
        
        sign = signRepository.save(sign);
        return convertToResponse(sign);
    }
    
    /**
     * Delete sign (only by creator or admin)
     */
    public void deleteSign(Long id, String userEmail) throws Exception {
        SignEntity sign = signRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Sign not found"));
        
        // Check permissions
        UserEntity user = userRepository.findByEmail(userEmail)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        if (!sign.getCreatedBy().equals(userEmail) && user.getRole() != Role.SPECIALIST) {
            throw new IllegalArgumentException("You don't have permission to delete this sign");
        }
        
        // Delete file from storage
        try {
            storageService.deleteFile(sign.getVideoUrl());
            if (sign.getThumbnailUrl() != null) {
                storageService.deleteFile(sign.getThumbnailUrl());
            }
        } catch (Exception e) {
            // Log error but continue with database deletion
            System.err.println("Error deleting file from storage: " + e.getMessage());
        }
        
        // Delete from database
        signRepository.delete(sign);
    }
    
    /**
     * Approve sign (specialist only)
     */
    public SignResponse approveSign(Long id, String userEmail) throws Exception {
        UserEntity user = userRepository.findByEmail(userEmail)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        if (user.getRole() != Role.SPECIALIST) {
            throw new IllegalArgumentException("Only specialists can approve signs");
        }
        
        SignEntity sign = signRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Sign not found"));
        
        sign.setIsApproved(true);
        sign.setUpdatedAt(LocalDateTime.now());
        
        sign = signRepository.save(sign);
        return convertToResponse(sign);
    }
    
    /**
     * Validate uploaded file
     */
    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File is required");
        }
        
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("File size exceeds maximum allowed size (100MB)");
        }
        
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType)) {
            throw new IllegalArgumentException("Invalid file type. Allowed types: video (mp4, webm, mov, avi) or image (jpeg, png, gif, webp)");
        }
    }
    
    /**
     * Convert entity to response DTO
     */
    private SignResponse convertToResponse(SignEntity entity) {
        SignResponse response = new SignResponse();
        response.setId(entity.getId());
        response.setName(entity.getName());
        response.setDescription(entity.getDescription());
        response.setVideoUrl(entity.getVideoUrl());
        response.setThumbnailUrl(entity.getThumbnailUrl());
        response.setCreatedBy(entity.getCreatedBy());
        response.setCreatedAt(entity.getCreatedAt());
        response.setUpdatedAt(entity.getUpdatedAt());
        response.setCategory(entity.getCategory());
        response.setDifficultyLevel(entity.getDifficultyLevel());
        response.setIsApproved(entity.getIsApproved());
        response.setViewCount(entity.getViewCount());
        response.setFileSize(entity.getFileSize());
        response.setDurationSeconds(entity.getDurationSeconds());
        response.setContentType(entity.getContentType());
        
        // Generate signed URLs
        try {
            response.setSignedVideoUrl(storageService.getSignedUrl(entity.getVideoUrl()));
            if (entity.getThumbnailUrl() != null) {
                response.setSignedThumbnailUrl(storageService.getSignedUrl(entity.getThumbnailUrl()));
            }
        } catch (Exception e) {
            // Log error but don't fail
            System.err.println("Error generating signed URL: " + e.getMessage());
        }
        
        return response;
    }
}

