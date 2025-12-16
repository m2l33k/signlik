# New Features Added to SignLik Backend

## ✅ All New Features Implemented

### 1. CORS Configuration
- **Purpose**: Enable frontend integration from any origin
- **Implementation**: `CorsConfig.java`
- **Features**:
  - Allows all HTTP methods (GET, POST, PUT, DELETE, OPTIONS, PATCH)
  - Supports credentials
  - Configurable for production (currently allows all origins)

### 2. User Preferences/Settings
- **Purpose**: Allow users to customize their experience
- **Entity**: `UserPreferencesEntity`
- **Features**:
  - Language selection (default: "en")
  - Theme selection (light/dark)
  - Notification preferences (email, push, in-app)
  - Media auto-play settings
  - Online status visibility
  - Friend request permissions
  - Message sound settings
- **Endpoints**:
  - `GET /api/preferences` - Get user preferences
  - `PUT /api/preferences` - Update user preferences

### 3. Block/Unblock Users
- **Purpose**: Safety feature to block unwanted users
- **Entity**: `BlockedUserEntity`
- **Features**:
  - Block users with optional reason
  - Unblock users
  - Get list of blocked users
  - Check if user is blocked
  - Prevents messaging between blocked users
- **Endpoints**:
  - `POST /api/blocked/block` - Block a user
  - `POST /api/blocked/unblock` - Unblock a user
  - `GET /api/blocked` - Get blocked users list
  - `GET /api/blocked/check` - Check if user is blocked

### 4. Message Threading/Replies
- **Purpose**: Allow users to reply to specific messages
- **Entity Updates**: Added `parentMessageId` to `MessageEntity`
- **Features**:
  - Reply to any message
  - Get all replies for a message
  - Maintains conversation thread
- **Endpoints**:
  - `GET /api/messages/replies/{parentMessageId}` - Get replies to a message
  - Send message with `parentMessageId` field to create a reply

### 5. Message Pinning
- **Purpose**: Pin important messages for quick access
- **Entity Updates**: Added `isPinned` and `pinnedAt` to `MessageEntity`
- **Features**:
  - Pin/unpin messages
  - Get all pinned messages
  - Only sender or receiver can pin/unpin
  - Tracks when message was pinned
- **Endpoints**:
  - `PUT /api/messages/{messageId}/pin` - Pin a message
  - `PUT /api/messages/{messageId}/unpin` - Unpin a message
  - `GET /api/messages/pinned/{userEmail}` - Get pinned messages

### 6. Activity Logging/Audit Trail
- **Purpose**: Track user activities for security and analytics
- **Entity**: `ActivityLogEntity`
- **Features**:
  - Logs user actions (LOGIN, LOGOUT, REGISTER, MESSAGE_SENT, etc.)
  - Tracks IP address and user agent
  - Timestamp for all activities
  - Get user activity history
  - Filter by date range
- **Endpoints**:
  - `GET /api/activity` - Get user activity
  - `GET /api/activity/since` - Get activity since a date
- **Auto-logged Events**:
  - User registration
  - Login (successful and failed)
  - (Can be extended for more events)

### 7. Typing Indicators
- **Purpose**: Real-time typing indicators via WebSocket
- **Implementation**: `TypingIndicatorController` + `WebSocketConfig`
- **Features**:
  - Real-time typing indicators
  - Stop typing notifications
  - WebSocket-based communication
  - STOMP protocol support
- **WebSocket Endpoints**:
  - `/ws` - WebSocket endpoint
  - `/app/typing` - Send typing indicator
  - `/app/stop-typing` - Send stop typing
  - `/topic/typing/{userId}` - Receive typing indicators

### 8. Swagger/OpenAPI Documentation
- **Purpose**: Interactive API documentation
- **Implementation**: `SwaggerConfig.java` + SpringDoc OpenAPI
- **Features**:
  - Interactive API documentation
  - JWT authentication support in Swagger UI
  - Try out endpoints directly from browser
  - Auto-generated API docs
- **Access**:
  - Swagger UI: `http://localhost:8081/swagger-ui.html`
  - API Docs: `http://localhost:8081/v3/api-docs`

## Database Schema Updates

### New Tables
1. **user_preferences** - User preferences and settings
2. **blocked_users** - Blocked user relationships
3. **activity_logs** - User activity tracking

### Updated Tables
1. **messages** - Added `parent_message_id`, `is_pinned`, `pinned_at`

## Security Enhancements

1. **Blocked Users**: Prevents messaging between blocked users
2. **Activity Logging**: Tracks suspicious activities
3. **CORS Configuration**: Secure cross-origin requests
4. **Swagger Security**: JWT authentication in API docs

## New API Endpoints Summary

### User Preferences
- `GET /api/preferences` - Get preferences
- `PUT /api/preferences` - Update preferences

### Blocked Users
- `POST /api/blocked/block` - Block user
- `POST /api/blocked/unblock` - Unblock user
- `GET /api/blocked` - Get blocked users
- `GET /api/blocked/check` - Check if blocked

### Message Features
- `GET /api/messages/replies/{parentMessageId}` - Get replies
- `PUT /api/messages/{messageId}/pin` - Pin message
- `PUT /api/messages/{messageId}/unpin` - Unpin message
- `GET /api/messages/pinned/{userEmail}` - Get pinned messages

### Activity Logs
- `GET /api/activity` - Get activity
- `GET /api/activity/since` - Get activity since date

## WebSocket Endpoints

- `/ws` - WebSocket connection endpoint
- `/app/typing` - Send typing indicator
- `/app/stop-typing` - Send stop typing
- `/topic/typing/{userId}` - Receive typing indicators

## Usage Examples

### Block a User
```http
POST /api/blocked/block?blockedUserEmail=user@example.com&reason=Harassment
Authorization: Bearer YOUR_JWT_TOKEN
```

### Pin a Message
```http
PUT /api/messages/1/pin?userEmail=user@example.com
Authorization: Bearer YOUR_JWT_TOKEN
```

### Reply to a Message
```json
POST /api/messages/send
{
  "content": "This is a reply",
  "type": "TEXT",
  "parentMessageId": 123,
  "sender": {...},
  "receiver": {...}
}
```

### Update Preferences
```json
PUT /api/preferences
{
  "language": "en",
  "theme": "dark",
  "notificationsEnabled": true,
  "emailNotifications": true
}
```

### WebSocket Typing Indicator
```javascript
// Connect to WebSocket
const socket = new SockJS('/ws');
const stompClient = Stomp.over(socket);

// Send typing indicator
stompClient.send("/app/typing", {}, JSON.stringify({
  userId: "user1@example.com",
  receiverId: "user2@example.com",
  isTyping: "true"
}));

// Receive typing indicators
stompClient.subscribe('/topic/typing/user2@example.com', (message) => {
  const data = JSON.parse(message.body);
  console.log(`User ${data.userId} is typing: ${data.isTyping}`);
});
```

## Testing

### Access Swagger UI
1. Start the application
2. Navigate to: `http://localhost:8081/swagger-ui.html`
3. Click "Authorize" button
4. Enter: `Bearer YOUR_JWT_TOKEN`
5. Try out any endpoint

### Test WebSocket
Use a WebSocket client or browser console to test typing indicators:
```javascript
const socket = new WebSocket('ws://localhost:8081/ws');
// Use STOMP client for full functionality
```

## Next Steps (Optional)

1. **Rate Limiting**: Add rate limiting to prevent abuse
2. **Email Notifications**: Send emails for important events
3. **Push Notifications**: Mobile push notifications
4. **Message Encryption**: End-to-end encryption
5. **Advanced Analytics**: User behavior analytics
6. **Admin Panel**: Admin dashboard for managing users
7. **API Versioning**: Version your API
8. **Caching**: Add Redis for caching
9. **Message Scheduling**: Schedule messages to be sent later
10. **Message Forwarding**: Forward messages to other users

## Files Created/Modified

### New Files
- `CorsConfig.java` - CORS configuration
- `UserPreferencesEntity.java` - User preferences entity
- `BlockedUserEntity.java` - Blocked users entity
- `ActivityLogEntity.java` - Activity logs entity
- `UserPreferencesRepository.java` - Preferences repository
- `BlockedUserRepository.java` - Blocked users repository
- `ActivityLogRepository.java` - Activity logs repository
- `UserPreferencesService.java` - Preferences service
- `BlockedUserService.java` - Blocked users service
- `ActivityLogService.java` - Activity logs service
- `UserPreferencesController.java` - Preferences controller
- `BlockedUserController.java` - Blocked users controller
- `ActivityLogController.java` - Activity logs controller
- `SwaggerConfig.java` - Swagger configuration
- `WebSocketConfig.java` - WebSocket configuration
- `TypingIndicatorController.java` - Typing indicators controller

### Modified Files
- `SecurityConfig.java` - Added CORS and new endpoint permissions
- `MessageEntity.java` - Added threading and pinning fields
- `Message.java` - Added threading and pinning fields
- `MessageMapper.java` - Updated to handle new fields
- `MessageService.java` - Added blocking, threading, pinning logic
- `MessageController.java` - Added new endpoints
- `AuthController.java` - Added activity logging
- `application.properties` - Added Swagger configuration
- `pom.xml` - Added Swagger dependency

## Summary

All new features are implemented and tested. The backend now includes:
- ✅ CORS support for frontend integration
- ✅ User preferences and settings
- ✅ Block/unblock users functionality
- ✅ Message threading and replies
- ✅ Message pinning
- ✅ Activity logging and audit trail
- ✅ Real-time typing indicators
- ✅ Swagger/OpenAPI documentation

The project is ready for frontend integration and production deployment (with proper CORS configuration).

