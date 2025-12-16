package org.example.backendsignlik.websocket;

import org.example.backendsignlik.Services.MessageService;
import org.example.backendsignlik.Services.UserService;
import org.example.backendsignlik.model.Message;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
public class WebSocketController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    
    @Autowired
    private MessageService messageService;
    
    @Autowired
    private UserService userService;

    @MessageMapping("/chat.send")
    @SendTo("/topic/public")
    public Message sendMessage(@Payload Message message) {
        try {
            String senderEmail = message.getSender() != null ? message.getSender().getEmail() : null;
            String receiverEmail = message.getReceiver() != null ? message.getReceiver().getEmail() : null;
            
            if(senderEmail != null && receiverEmail != null){
                // Save message to database
                Message savedMessage = messageService.sendMessage(message, senderEmail, receiverEmail);
                
                // Send to specific user's private queue
                messagingTemplate.convertAndSendToUser(
                    receiverEmail, 
                    "/queue/messages", 
                    savedMessage
                );
                
                return savedMessage;
            }
            return message;
        } catch (Exception e) {
            return message;
        }
    }

    @MessageMapping("/chat.typing")
    public void typing(@Payload String userEmail) {
        messagingTemplate.convertAndSend("/topic/typing", userEmail + " is typing...");
    }

    @MessageMapping("/typing")
    public void handleTyping(@Payload java.util.Map<String, String> typingData) {
        String userId = typingData.get("userId");
        String receiverId = typingData.get("receiverId");
        String isTyping = typingData.get("isTyping");
        
        // Send typing indicator to the receiver
        messagingTemplate.convertAndSend("/topic/typing/" + receiverId, java.util.Map.of(
            "userId", userId,
            "isTyping", isTyping
        ));
    }

    @MessageMapping("/stop-typing")
    public void handleStopTyping(@Payload java.util.Map<String, String> typingData) {
        String userId = typingData.get("userId");
        String receiverId = typingData.get("receiverId");
        
        // Send stop typing indicator to the receiver
        messagingTemplate.convertAndSend("/topic/typing/" + receiverId, java.util.Map.of(
            "userId", userId,
            "isTyping", "false"
        ));
    }

    @MessageMapping("/user.online")
    public void userOnline(@Payload String userEmail) {
        userService.setUserOnline(userEmail, true);
        messagingTemplate.convertAndSend("/topic/online", userEmail);
    }

    @MessageMapping("/user.offline")
    public void userOffline(@Payload String userEmail) {
        userService.setUserOnline(userEmail, false);
        messagingTemplate.convertAndSend("/topic/offline", userEmail);
    }
}

