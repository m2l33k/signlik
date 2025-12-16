# Chat Module

Real-time chat functionality using WebSockets (Socket.io) for the TSL Chat application.

## Features

- Real-time messaging via WebSocket
- Conversation management
- Message persistence
- Gesture metadata support
- Typing indicators
- Read receipts

## WebSocket Events

### Client → Server

- `join` - Join chat system
- `join_conversation` - Join a specific conversation
- `send_message` - Send a message
- `typing` - Send typing indicator

### Server → Client

- `connected` - Connection confirmed
- `joined` - Successfully joined
- `message` - New message received
- `conversation_history` - Conversation messages
- `typing` - User is typing
- `error` - Error occurred

## Usage

### Connect from Flutter

```dart
final socket = IO.io(
  'http://your-backend-url',
  IO.OptionBuilder()
    .setTransports(['websocket'])
    .enableAutoConnect()
    .setAuth({'token': jwtToken})
    .build(),
);
```

### Send Message

```dart
socket.emit('send_message', {
  'conversationId': 'conversation-id',
  'message': {
    'text': 'Hello',
    'gestureSign': 'hello',
    'gestureConfidence': 0.95,
  },
});
```

## Authentication

All WebSocket connections require JWT authentication via:
- `auth.token` in handshake
- Or `Authorization: Bearer <token>` header

