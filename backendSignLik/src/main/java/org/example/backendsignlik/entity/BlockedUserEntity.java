package org.example.backendsignlik.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "blocked_users")
public class BlockedUserEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "blocked_user_id", nullable = false)
    private UserEntity blockedUser;
    
    @Column(name = "blocked_at", nullable = false)
    private LocalDateTime blockedAt;
    
    @Column(name = "reason", columnDefinition = "TEXT")
    private String reason;

    // Constructors
    public BlockedUserEntity() {
        this.blockedAt = LocalDateTime.now();
    }

    public BlockedUserEntity(UserEntity user, UserEntity blockedUser) {
        this.user = user;
        this.blockedUser = blockedUser;
        this.blockedAt = LocalDateTime.now();
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

    public UserEntity getBlockedUser() {
        return blockedUser;
    }

    public void setBlockedUser(UserEntity blockedUser) {
        this.blockedUser = blockedUser;
    }

    public LocalDateTime getBlockedAt() {
        return blockedAt;
    }

    public void setBlockedAt(LocalDateTime blockedAt) {
        this.blockedAt = blockedAt;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}

