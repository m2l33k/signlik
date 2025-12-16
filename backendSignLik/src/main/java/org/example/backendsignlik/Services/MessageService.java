package org.example.backendsignlik.Services;


import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.mapper.MessageMapper;
import org.example.backendsignlik.model.Message;
import org.example.backendsignlik.repository.MessageRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.example.backendsignlik.service.ModalityConversionService;
import org.example.backendsignlik.service.NotificationService;
import org.example.backendsignlik.service.BlockedUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class MessageService {

    @Autowired
    private MessageRepository messageRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private MessageMapper messageMapper;
    
    @Autowired
    private ModalityConversionService conversionService;
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private BlockedUserService blockedUserService;

    @Transactional
    public Message sendMessage(Message message, String senderEmail, String receiverEmail){
        Optional<UserEntity> senderOpt = userRepository.findByEmail(senderEmail);
        Optional<UserEntity> receiverOpt = userRepository.findByEmail(receiverEmail);
        
        if(senderOpt.isEmpty() || receiverOpt.isEmpty()){
            throw new IllegalArgumentException("Sender or receiver not found");
        }
        
        // Check if users are blocked
        if(blockedUserService.isBlocked(senderEmail, receiverEmail)) {
            throw new IllegalArgumentException("Cannot send message: User is blocked");
        }
        
        MessageEntity entity = messageMapper.toEntity(message, senderOpt.get(), receiverOpt.get());
        entity.setTimestamp(LocalDateTime.now());
        entity.setIsRead(false);
        
        // Set attachment URL if provided
        if(message.getAttachmentUrl() != null) {
            entity.setAttachmentUrl(message.getAttachmentUrl());
        }
        
        // Set parent message ID for threading
        if(message.getParentMessageId() != null) {
            entity.setParentMessageId(message.getParentMessageId());
        }
        
        // Set conversion status based on message type
        if("VOICE".equalsIgnoreCase(message.getType()) || "SIGN".equalsIgnoreCase(message.getType())) {
            entity.setConversionStatus("PENDING");
        } else {
            entity.setConversionStatus("COMPLETED");
        }
        
        MessageEntity saved = messageRepository.save(entity);
        
        // Trigger background conversion job for VOICE/SIGN messages
        if("VOICE".equalsIgnoreCase(message.getType()) && entity.getAttachmentUrl() != null) {
            conversionService.processVoiceMessage(saved.getId(), entity.getAttachmentUrl());
        } else if("SIGN".equalsIgnoreCase(message.getType()) && entity.getAttachmentUrl() != null) {
            conversionService.processSignMessage(saved.getId(), entity.getAttachmentUrl());
        }
        
        // Create notification for receiver
        try {
            notificationService.createNotification(
                receiverEmail,
                "MESSAGE",
                senderOpt.get().getUsername() + " sent you a " + message.getType().toLowerCase() + " message",
                saved.getId()
            );
        } catch (Exception e) {
            // Log but don't fail message sending if notification fails
            System.err.println("Failed to create notification: " + e.getMessage());
        }
        
        return messageMapper.toModel(saved);
    }

    public List<Message> getAllMessages(){
        return messageRepository.findAll().stream()
                .map(messageMapper::toModel)
                .collect(Collectors.toList());
    }

    public List<Message> getMessagesByUser(String userEmail){
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()){
            return List.of();
        }
        return messageRepository.findBySenderOrReceiver(userOpt.get(), userOpt.get()).stream()
                .map(messageMapper::toModel)
                .collect(Collectors.toList());
    }

    public List<Message> getConversation(String user1Email, String user2Email){
        Optional<UserEntity> user1Opt = userRepository.findByEmail(user1Email);
        Optional<UserEntity> user2Opt = userRepository.findByEmail(user2Email);
        
        if(user1Opt.isEmpty() || user2Opt.isEmpty()){
            return List.of();
        }
        
        return messageRepository.findConversation(user1Opt.get(), user2Opt.get()).stream()
                .map(messageMapper::toModel)
                .collect(Collectors.toList());
    }

    public List<Message> getMessagesByType(String type){
        return messageRepository.findByTypeIgnoreCase(type).stream()
                .map(messageMapper::toModel)
                .collect(Collectors.toList());
    }

    @Transactional
    public boolean deleteMessage(Long id){
        if(messageRepository.existsById(id)){
            messageRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public Optional<Message> getMessageById(Long id){
        return messageRepository.findById(id)
                .map(messageMapper::toModel);
    }

    public List<Message> getMessagesPaginated(int page, int size){
        Pageable pageable = PageRequest.of(page, size);
        Page<MessageEntity> pageResult = messageRepository.findAll(pageable);
        return pageResult.getContent().stream()
                .map(messageMapper::toModel)
                .collect(Collectors.toList());
    }

    public long getTotalMessageCount(){
        return messageRepository.count();
    }
    
    @Transactional
    public void markMessageAsRead(Long messageId, String userEmail){
        Optional<MessageEntity> messageOpt = messageRepository.findById(messageId);
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        
        if(messageOpt.isPresent() && userOpt.isPresent()){
            MessageEntity message = messageOpt.get();
            // Only mark as read if the user is the receiver
            if(message.getReceiver().getEmail().equals(userEmail) && !message.getIsRead()){
                message.setIsRead(true);
                message.setReadAt(LocalDateTime.now());
                messageRepository.save(message);
            }
        }
    }
    
    public List<Message> getUnreadMessages(String userEmail){
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()){
            return List.of();
        }
        return messageRepository.findByReceiverAndIsReadFalse(userOpt.get()).stream()
                .map(messageMapper::toModel)
                .collect(Collectors.toList());
    }
    
    public Long getUnreadMessageCount(String userEmail){
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()){
            return 0L;
        }
        return messageRepository.countUnreadMessages(userOpt.get());
    }
    
    public List<Message> searchMessages(String query, String userEmail){
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()){
            return List.of();
        }
        
        // Search in messages where user is sender or receiver
        List<MessageEntity> userMessages = messageRepository.findBySenderOrReceiver(userOpt.get(), userOpt.get());
        
        String lowerQuery = query.toLowerCase();
        return userMessages.stream()
                .filter(m -> m.getContent() != null && m.getContent().toLowerCase().contains(lowerQuery) ||
                           m.getTranscript() != null && m.getTranscript().toLowerCase().contains(lowerQuery))
                .map(messageMapper::toModel)
                .collect(Collectors.toList());
    }
    
    public List<Message> getReplies(Long parentMessageId){
        Optional<MessageEntity> parentOpt = messageRepository.findById(parentMessageId);
        if(parentOpt.isEmpty()){
            return List.of();
        }
        
        List<MessageEntity> replies = messageRepository.findAll().stream()
                .filter(m -> parentMessageId.equals(m.getParentMessageId()))
                .collect(Collectors.toList());
        
        return replies.stream()
                .map(messageMapper::toModel)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public Message pinMessage(Long messageId, String userEmail){
        Optional<MessageEntity> messageOpt = messageRepository.findById(messageId);
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        
        if(messageOpt.isEmpty() || userOpt.isEmpty()){
            throw new IllegalArgumentException("Message or user not found");
        }
        
        MessageEntity message = messageOpt.get();
        
        // Only sender or receiver can pin
        if(!message.getSender().getEmail().equals(userEmail) && 
           !message.getReceiver().getEmail().equals(userEmail)) {
            throw new IllegalArgumentException("Only sender or receiver can pin messages");
        }
        
        message.setIsPinned(true);
        MessageEntity saved = messageRepository.save(message);
        return messageMapper.toModel(saved);
    }
    
    @Transactional
    public Message unpinMessage(Long messageId, String userEmail){
        Optional<MessageEntity> messageOpt = messageRepository.findById(messageId);
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        
        if(messageOpt.isEmpty() || userOpt.isEmpty()){
            throw new IllegalArgumentException("Message or user not found");
        }
        
        MessageEntity message = messageOpt.get();
        
        // Only sender or receiver can unpin
        if(!message.getSender().getEmail().equals(userEmail) && 
           !message.getReceiver().getEmail().equals(userEmail)) {
            throw new IllegalArgumentException("Only sender or receiver can unpin messages");
        }
        
        message.setIsPinned(false);
        message.setPinnedAt(null);
        MessageEntity saved = messageRepository.save(message);
        return messageMapper.toModel(saved);
    }
    
    public List<Message> getPinnedMessages(String userEmail){
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()){
            return List.of();
        }
        
        List<MessageEntity> userMessages = messageRepository.findBySenderOrReceiver(userOpt.get(), userOpt.get());
        
        return userMessages.stream()
                .filter(MessageEntity::getIsPinned)
                .map(messageMapper::toModel)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public Message forwardMessage(Long originalMessageId, String fromEmail, String toEmail) {
        // Get the original message
        Optional<MessageEntity> originalMessageOpt = messageRepository.findById(originalMessageId);
        if(originalMessageOpt.isEmpty()) {
            throw new IllegalArgumentException("Original message not found");
        }
        
        MessageEntity originalMessage = originalMessageOpt.get();
        
        // Verify the user forwarding has access to the message
        Optional<UserEntity> fromUserOpt = userRepository.findByEmail(fromEmail);
        if(fromUserOpt.isEmpty()) {
            throw new IllegalArgumentException("Forwarding user not found");
        }
        
        // Check if user has access to the original message (must be sender or receiver)
        if(!originalMessage.getSender().getEmail().equals(fromEmail) && 
           !originalMessage.getReceiver().getEmail().equals(fromEmail)) {
            throw new IllegalArgumentException("You don't have permission to forward this message");
        }
        
        // Get the receiver
        Optional<UserEntity> toUserOpt = userRepository.findByEmail(toEmail);
        if(toUserOpt.isEmpty()) {
            throw new IllegalArgumentException("Receiver not found");
        }
        
        // Check if users are blocked
        if(blockedUserService.isBlocked(fromEmail, toEmail)) {
            throw new IllegalArgumentException("Cannot forward message: User is blocked");
        }
        
        // Create a new message entity with forwarded content
        MessageEntity forwardedMessage = new MessageEntity();
        forwardedMessage.setContent(originalMessage.getContent());
        forwardedMessage.setType(originalMessage.getType());
        forwardedMessage.setSender(fromUserOpt.get());
        forwardedMessage.setReceiver(toUserOpt.get());
        forwardedMessage.setTimestamp(LocalDateTime.now());
        forwardedMessage.setIsRead(false);
        forwardedMessage.setIsForwarded(true);
        forwardedMessage.setOriginalMessageId(originalMessageId);
        forwardedMessage.setForwardedFromEmail(fromEmail);
        
        // Copy attachment if exists
        if(originalMessage.getAttachmentUrl() != null) {
            forwardedMessage.setAttachmentUrl(originalMessage.getAttachmentUrl());
        }
        
        // Copy transcript if exists
        if(originalMessage.getTranscript() != null) {
            forwardedMessage.setTranscript(originalMessage.getTranscript());
        }
        
        // Set conversion status
        forwardedMessage.setConversionStatus(originalMessage.getConversionStatus());
        
        MessageEntity saved = messageRepository.save(forwardedMessage);
        
        // Create notification for receiver
        try {
            notificationService.createNotification(
                toEmail,
                "MESSAGE",
                fromUserOpt.get().getUsername() + " forwarded you a message",
                saved.getId()
            );
        } catch (Exception e) {
            System.err.println("Failed to create notification: " + e.getMessage());
        }
        
        return messageMapper.toModel(saved);
    }
}
