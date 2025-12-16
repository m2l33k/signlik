package org.example.backendsignlik.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_preferences")
public class UserPreferencesEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private UserEntity user;
    
    @Column(name = "language", length = 10)
    private String language = "en"; // Default language
    
    @Column(name = "theme", length = 20)
    private String theme = "light"; // light, dark
    
    @Column(name = "notifications_enabled")
    private Boolean notificationsEnabled = true;
    
    @Column(name = "email_notifications")
    private Boolean emailNotifications = true;
    
    @Column(name = "push_notifications")
    private Boolean pushNotifications = true;
    
    @Column(name = "auto_play_media")
    private Boolean autoPlayMedia = false;
    
    @Column(name = "show_online_status")
    private Boolean showOnlineStatus = true;
    
    @Column(name = "allow_friend_requests")
    private Boolean allowFriendRequests = true;
    
    @Column(name = "message_sound_enabled")
    private Boolean messageSoundEnabled = true;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Constructors
    public UserPreferencesEntity() {
        this.updatedAt = LocalDateTime.now();
    }

    public UserPreferencesEntity(UserEntity user) {
        this.user = user;
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public UserEntity getUser() {
        return user;
    }

    public void setUser(UserEntity user) {
        this.user = user;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
        this.updatedAt = LocalDateTime.now();
    }

    public String getTheme() {
        return theme;
    }

    public void setTheme(String theme) {
        this.theme = theme;
        this.updatedAt = LocalDateTime.now();
    }

    public Boolean getNotificationsEnabled() {
        return notificationsEnabled;
    }

    public void setNotificationsEnabled(Boolean notificationsEnabled) {
        this.notificationsEnabled = notificationsEnabled;
        this.updatedAt = LocalDateTime.now();
    }

    public Boolean getEmailNotifications() {
        return emailNotifications;
    }

    public void setEmailNotifications(Boolean emailNotifications) {
        this.emailNotifications = emailNotifications;
        this.updatedAt = LocalDateTime.now();
    }

    public Boolean getPushNotifications() {
        return pushNotifications;
    }

    public void setPushNotifications(Boolean pushNotifications) {
        this.pushNotifications = pushNotifications;
        this.updatedAt = LocalDateTime.now();
    }

    public Boolean getAutoPlayMedia() {
        return autoPlayMedia;
    }

    public void setAutoPlayMedia(Boolean autoPlayMedia) {
        this.autoPlayMedia = autoPlayMedia;
        this.updatedAt = LocalDateTime.now();
    }

    public Boolean getShowOnlineStatus() {
        return showOnlineStatus;
    }

    public void setShowOnlineStatus(Boolean showOnlineStatus) {
        this.showOnlineStatus = showOnlineStatus;
        this.updatedAt = LocalDateTime.now();
    }

    public Boolean getAllowFriendRequests() {
        return allowFriendRequests;
    }

    public void setAllowFriendRequests(Boolean allowFriendRequests) {
        this.allowFriendRequests = allowFriendRequests;
        this.updatedAt = LocalDateTime.now();
    }

    public Boolean getMessageSoundEnabled() {
        return messageSoundEnabled;
    }

    public void setMessageSoundEnabled(Boolean messageSoundEnabled) {
        this.messageSoundEnabled = messageSoundEnabled;
        this.updatedAt = LocalDateTime.now();
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}

