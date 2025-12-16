package org.example.backendsignlik.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "messages")
public class MessageEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;
    
    @Column(nullable = false)
    private String type; // TEXT, VOICE, SIGN
    
    @Column(nullable = false)
    private LocalDateTime timestamp;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "sender_id", nullable = false)
    private UserEntity sender;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "receiver_id", nullable = false)
    private UserEntity receiver;
    
    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;
    
    @Column(name = "read_at")
    private LocalDateTime readAt;
    
    @Column(name = "attachment_url", length = 1000)
    private String attachmentUrl;
    
    @Column(name = "transcript")
    private String transcript;
    
    @Column(name = "conversion_status")
    private String conversionStatus; // PENDING, PROCESSING, COMPLETED, FAILED
    
    @Column(name = "parent_message_id")
    private Long parentMessageId; // For message threading/replies
    
    @Column(name = "is_pinned", nullable = false)
    private Boolean isPinned = false;
    
    @Column(name = "pinned_at")
    private LocalDateTime pinnedAt;
    
    @Column(name = "is_forwarded", nullable = false)
    private Boolean isForwarded = false;
    
    @Column(name = "original_message_id")
    private Long originalMessageId; // ID of the original message if this is a forwarded message
    
    @Column(name = "forwarded_from_email")
    private String forwardedFromEmail; // Email of user who forwarded the message

    // Constructors
    public MessageEntity() {
        this.timestamp = LocalDateTime.now();
        this.isRead = false;
        this.isForwarded = false;
    }

    public MessageEntity(String content, String type, UserEntity sender, UserEntity receiver) {
        this.content = content;
        this.type = type;
        this.sender = sender;
        this.receiver = receiver;
        this.timestamp = LocalDateTime.now();
        this.isRead = false;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public UserEntity getSender() {
        return sender;
    }

    public void setSender(UserEntity sender) {
        this.sender = sender;
    }

    public UserEntity getReceiver() {
        return receiver;
    }

    public void setReceiver(UserEntity receiver) {
        this.receiver = receiver;
    }

    public Boolean getIsRead() {
        return isRead;
    }

    public void setIsRead(Boolean isRead) {
        this.isRead = isRead;
    }

    public LocalDateTime getReadAt() {
        return readAt;
    }

    public void setReadAt(LocalDateTime readAt) {
        this.readAt = readAt;
    }

    public String getAttachmentUrl() {
        return attachmentUrl;
    }

    public void setAttachmentUrl(String attachmentUrl) {
        this.attachmentUrl = attachmentUrl;
    }

    public String getTranscript() {
        return transcript;
    }

    public void setTranscript(String transcript) {
        this.transcript = transcript;
    }

    public String getConversionStatus() {
        return conversionStatus;
    }

    public void setConversionStatus(String conversionStatus) {
        this.conversionStatus = conversionStatus;
    }

    public Long getParentMessageId() {
        return parentMessageId;
    }

    public void setParentMessageId(Long parentMessageId) {
        this.parentMessageId = parentMessageId;
    }

    public Boolean getIsPinned() {
        return isPinned;
    }

    public void setIsPinned(Boolean isPinned) {
        this.isPinned = isPinned;
        if(isPinned && this.pinnedAt == null) {
            this.pinnedAt = LocalDateTime.now();
        }
    }

    public LocalDateTime getPinnedAt() {
        return pinnedAt;
    }

    public void setPinnedAt(LocalDateTime pinnedAt) {
        this.pinnedAt = pinnedAt;
    }

    public Boolean getIsForwarded() {
        return isForwarded;
    }

    public void setIsForwarded(Boolean isForwarded) {
        this.isForwarded = isForwarded;
    }

    public Long getOriginalMessageId() {
        return originalMessageId;
    }

    public void setOriginalMessageId(Long originalMessageId) {
        this.originalMessageId = originalMessageId;
    }

    public String getForwardedFromEmail() {
        return forwardedFromEmail;
    }

    public void setForwardedFromEmail(String forwardedFromEmail) {
        this.forwardedFromEmail = forwardedFromEmail;
    }
}

