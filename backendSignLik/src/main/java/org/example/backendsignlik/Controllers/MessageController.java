package org.example.backendsignlik.Controllers;


import org.example.backendsignlik.dto.MessagePageResponse;
import org.example.backendsignlik.model.Message;
import org.example.backendsignlik.Services.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    @Autowired private MessageService messageService;

    @PostMapping("/send")
    public ResponseEntity<?> sendMessage(@RequestBody Message message){
        try {
            String senderEmail = message.getSender() != null ? message.getSender().getEmail() : null;
            String receiverEmail = message.getReceiver() != null ? message.getReceiver().getEmail() : null;
            
            if(senderEmail == null || receiverEmail == null){
                return ResponseEntity.status(400).body("Sender and receiver emails are required");
            }
            
            return ResponseEntity.ok(messageService.sendMessage(message, senderEmail, receiverEmail));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(404).body(e.getMessage());
        }
    }

    @GetMapping("/all")
    public ResponseEntity<List<Message>> getAllMessages(){
        return ResponseEntity.ok(messageService.getAllMessages());
    }

    @GetMapping("/user/{email}")
    public ResponseEntity<List<Message>> getMessagesByUser(@PathVariable String email){
        return ResponseEntity.ok(messageService.getMessagesByUser(email));
    }

    @GetMapping("/conversation")
    public ResponseEntity<List<Message>> getConversation(
            @RequestParam String user1,
            @RequestParam String user2){
        return ResponseEntity.ok(messageService.getConversation(user1, user2));
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<List<Message>> getMessagesByType(@PathVariable String type){
        return ResponseEntity.ok(messageService.getMessagesByType(type));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMessage(@PathVariable Long id){
        if(messageService.deleteMessage(id)){
            return ResponseEntity.ok("Message deleted successfully");
        }
        return ResponseEntity.status(404).body("Message not found");
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getMessageById(@PathVariable Long id){
        return messageService.getMessageById(id)
                .map(message -> ResponseEntity.<Message>ok(message))
                .orElse(ResponseEntity.status(404).<Message>body(null));
    }
    
    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long id, @RequestParam String userEmail){
        messageService.markMessageAsRead(id, userEmail);
        return ResponseEntity.ok("Message marked as read");
    }
    
    @GetMapping("/unread/{email}")
    public ResponseEntity<List<Message>> getUnreadMessages(@PathVariable String email){
        return ResponseEntity.ok(messageService.getUnreadMessages(email));
    }
    
    @GetMapping("/unread-count/{email}")
    public ResponseEntity<Long> getUnreadMessageCount(@PathVariable String email){
        return ResponseEntity.ok(messageService.getUnreadMessageCount(email));
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Message>> searchMessages(
            @RequestParam String query,
            @RequestParam String userEmail){
        return ResponseEntity.ok(messageService.searchMessages(query, userEmail));
    }
    
    @GetMapping("/replies/{parentMessageId}")
    public ResponseEntity<List<Message>> getReplies(@PathVariable Long parentMessageId){
        return ResponseEntity.ok(messageService.getReplies(parentMessageId));
    }
    
    @PutMapping("/{messageId}/pin")
    public ResponseEntity<Message> pinMessage(
            @PathVariable Long messageId,
            @RequestParam String userEmail){
        try {
            return ResponseEntity.ok(messageService.pinMessage(messageId, userEmail));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(null);
        }
    }
    
    @PutMapping("/{messageId}/unpin")
    public ResponseEntity<Message> unpinMessage(
            @PathVariable Long messageId,
            @RequestParam String userEmail){
        try {
            return ResponseEntity.ok(messageService.unpinMessage(messageId, userEmail));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(null);
        }
    }
    
    @GetMapping("/pinned/{userEmail}")
    public ResponseEntity<List<Message>> getPinnedMessages(@PathVariable String userEmail){
        return ResponseEntity.ok(messageService.getPinnedMessages(userEmail));
    }

    @PostMapping("/forward")
    public ResponseEntity<?> forwardMessage(
            @RequestParam Long originalMessageId,
            @RequestParam String fromEmail,
            @RequestParam String toEmail){
        try {
            Message forwardedMessage = messageService.forwardMessage(originalMessageId, fromEmail, toEmail);
            return ResponseEntity.ok(forwardedMessage);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error forwarding message: " + e.getMessage());
        }
    }

    @GetMapping("/paginated")
    public ResponseEntity<MessagePageResponse> getMessagesPaginated(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size){

        List<Message> messages = messageService.getMessagesPaginated(page, size);
        long totalMessages = messageService.getTotalMessageCount();
        int totalPages = (int) Math.ceil((double) totalMessages / size);

        MessagePageResponse response = new MessagePageResponse();
        response.setMessages(messages);
        response.setCurrentPage(page);
        response.setTotalPages(totalPages);
        response.setTotalMessages(totalMessages);
        response.setPageSize(size);

        return ResponseEntity.ok(response);
    }
}
