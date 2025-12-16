package org.example.backendsignlik.dto;

import java.time.LocalDateTime;

public class SignResponse {
    
    private Long id;
    private String name;
    private String description;
    private String videoUrl;
    private String signedVideoUrl; // Temporary signed URL
    private String thumbnailUrl;
    private String signedThumbnailUrl; // Temporary signed URL
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String category;
    private String difficultyLevel;
    private Boolean isApproved;
    private Long viewCount;
    private Long fileSize;
    private Double durationSeconds;
    private String contentType;
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getVideoUrl() {
        return videoUrl;
    }
    
    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }
    
    public String getSignedVideoUrl() {
        return signedVideoUrl;
    }
    
    public void setSignedVideoUrl(String signedVideoUrl) {
        this.signedVideoUrl = signedVideoUrl;
    }
    
    public String getThumbnailUrl() {
        return thumbnailUrl;
    }
    
    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }
    
    public String getSignedThumbnailUrl() {
        return signedThumbnailUrl;
    }
    
    public void setSignedThumbnailUrl(String signedThumbnailUrl) {
        this.signedThumbnailUrl = signedThumbnailUrl;
    }
    
    public String getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public String getDifficultyLevel() {
        return difficultyLevel;
    }
    
    public void setDifficultyLevel(String difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }
    
    public Boolean getIsApproved() {
        return isApproved;
    }
    
    public void setIsApproved(Boolean isApproved) {
        this.isApproved = isApproved;
    }
    
    public Long getViewCount() {
        return viewCount;
    }
    
    public void setViewCount(Long viewCount) {
        this.viewCount = viewCount;
    }
    
    public Long getFileSize() {
        return fileSize;
    }
    
    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }
    
    public Double getDurationSeconds() {
        return durationSeconds;
    }
    
    public void setDurationSeconds(Double durationSeconds) {
        this.durationSeconds = durationSeconds;
    }
    
    public String getContentType() {
        return contentType;
    }
    
    public void setContentType(String contentType) {
        this.contentType = contentType;
    }
}

