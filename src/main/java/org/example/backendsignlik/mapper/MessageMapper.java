package org.example.backendsignlik.mapper;

import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.model.Message;
import org.example.backendsignlik.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class MessageMapper {
    
    @Autowired
    private UserMapper userMapper;
    
    public MessageEntity toEntity(Message message, UserEntity sender, UserEntity receiver) {
        if (message == null) return null;
        MessageEntity entity = new MessageEntity();
        entity.setContent(message.getContent());
        entity.setType(message.getType());
        entity.setSender(sender);
        entity.setReceiver(receiver);
        entity.setTimestamp(message.getTimestamp() != null ? message.getTimestamp() : java.time.LocalDateTime.now());
        entity.setAttachmentUrl(message.getAttachmentUrl());
        entity.setTranscript(message.getTranscript());
        entity.setConversionStatus(message.getConversionStatus());
        entity.setParentMessageId(message.getParentMessageId());
        entity.setIsPinned(message.getIsPinned() != null ? message.getIsPinned() : false);
        entity.setPinnedAt(message.getPinnedAt());
        entity.setIsForwarded(message.getIsForwarded() != null ? message.getIsForwarded() : false);
        entity.setOriginalMessageId(message.getOriginalMessageId());
        entity.setForwardedFromEmail(message.getForwardedFromEmail());
        return entity;
    }
    
    public Message toModel(MessageEntity entity) {
        if (entity == null) return null;
        Message message = new Message();
        message.setContent(entity.getContent());
        message.setType(entity.getType());
        message.setTimestamp(entity.getTimestamp());
        message.setSender(userMapper.toModel(entity.getSender()));
        message.setReceiver(userMapper.toModel(entity.getReceiver()));
        message.setAttachmentUrl(entity.getAttachmentUrl());
        message.setTranscript(entity.getTranscript());
        message.setConversionStatus(entity.getConversionStatus());
        message.setParentMessageId(entity.getParentMessageId());
        message.setIsPinned(entity.getIsPinned());
        message.setPinnedAt(entity.getPinnedAt());
        message.setIsForwarded(entity.getIsForwarded());
        message.setOriginalMessageId(entity.getOriginalMessageId());
        message.setForwardedFromEmail(entity.getForwardedFromEmail());
        return message;
    }
}

