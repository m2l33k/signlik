package org.example.backendsignlik.websocket;

import org.example.backendsignlik.service.MessageService;
import org.example.backendsignlik.Services.UserService;
import org.example.backendsignlik.model.Message;
import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.mapper.MessageMapper;
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

    @Autowired
    private MessageMapper messageMapper;

    @MessageMapping("/chat.send")
    @SendTo("/topic/public")
    public Message sendMessage(@Payload Message message) {
        try {
            String senderEmail = message.getSender() != null ? message.getSender().getEmail() : null;
            String receiverEmail = message.getReceiver() != null ? message.getReceiver().getEmail() : null;
            
            if(senderEmail != null && receiverEmail != null){
                // Save message to database
                MessageEntity savedEntity = messageService.sendMessage(
                    senderEmail, 
                    receiverEmail, 
                    message.getContent(), 
                    message.getType()
                );
                
                Message savedMessage = messageMapper.toModel(savedEntity);
                
                // Send to specific user's topic
                String encodedReceiver = receiverEmail.replace("@", "_at_").replace(".", "_dot_");
                messagingTemplate.convertAndSend(
                    "/topic/messages/" + encodedReceiver,
                    savedMessage
                );
                
                return savedMessage;
            }
            return message;
        } catch (Exception e) {
            e.printStackTrace();
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

    // Video Call Signaling Handlers
    @MessageMapping("/call.offer")
    public void handleCallOffer(@Payload java.util.Map<String, Object> callData) {
        String callerEmail = (String) callData.get("callerEmail");
        String receiverEmail = (String) callData.get("receiverEmail");
        Object offer = callData.get("offer");
        
        // Forward the call offer to the receiver using topic pattern
        String encodedReceiver = receiverEmail.replace("@", "_at_").replace(".", "_dot_");
        messagingTemplate.convertAndSend(
            "/topic/call/offer/" + encodedReceiver,
            java.util.Map.of(
                "callerEmail", callerEmail,
                "offer", offer
            )
        );
    }

    @MessageMapping("/call.answer")
    public void handleCallAnswer(@Payload java.util.Map<String, Object> callData) {
        String callerEmail = (String) callData.get("callerEmail");
        String receiverEmail = (String) callData.get("receiverEmail");
        Object answer = callData.get("answer");
        
        // Forward the call answer to the caller using topic pattern
        String encodedCaller = callerEmail.replace("@", "_at_").replace(".", "_dot_");
        messagingTemplate.convertAndSend(
            "/topic/call/answer/" + encodedCaller,
            java.util.Map.of(
                "receiverEmail", receiverEmail,
                "answer", answer
            )
        );
    }

    @MessageMapping("/call.ice-candidate")
    public void handleIceCandidate(@Payload java.util.Map<String, Object> candidateData) {
        String senderEmail = (String) candidateData.get("senderEmail");
        String receiverEmail = (String) candidateData.get("receiverEmail");
        Object candidate = candidateData.get("candidate");
        
        // Forward ICE candidate to the other peer using topic pattern
        String encodedReceiver = receiverEmail.replace("@", "_at_").replace(".", "_dot_");
        messagingTemplate.convertAndSend(
            "/topic/call/ice/" + encodedReceiver,
            java.util.Map.of(
                "senderEmail", senderEmail,
                "candidate", candidate
            )
        );
    }

    @MessageMapping("/call.end")
    public void handleCallEnd(@Payload java.util.Map<String, String> callData) {
        String callerEmail = callData.get("callerEmail");
        String receiverEmail = callData.get("receiverEmail");
        String endedBy = callData.get("endedBy");
        
        // Notify both parties that the call has ended using topic pattern
        if (receiverEmail != null) {
            String encodedReceiver = receiverEmail.replace("@", "_at_").replace(".", "_dot_");
            messagingTemplate.convertAndSend(
                "/topic/call/end/" + encodedReceiver,
                java.util.Map.of(
                    "endedBy", endedBy != null ? endedBy : callerEmail
                )
            );
        }
        if (callerEmail != null && !callerEmail.equals(endedBy)) {
            String encodedCaller = callerEmail.replace("@", "_at_").replace(".", "_dot_");
            messagingTemplate.convertAndSend(
                "/topic/call/end/" + encodedCaller,
                java.util.Map.of(
                    "endedBy", endedBy != null ? endedBy : receiverEmail
                )
            );
        }
    }

    @MessageMapping("/call.reject")
    public void handleCallReject(@Payload java.util.Map<String, String> callData) {
        String callerEmail = callData.get("callerEmail");
        String receiverEmail = callData.get("receiverEmail");
        
        // Notify the caller that the call was rejected using topic pattern
        if (callerEmail != null) {
            String encodedCaller = callerEmail.replace("@", "_at_").replace(".", "_dot_");
            messagingTemplate.convertAndSend(
                "/topic/call/reject/" + encodedCaller,
                java.util.Map.of(
                    "receiverEmail", receiverEmail
                )
            );
        }
    }
}

