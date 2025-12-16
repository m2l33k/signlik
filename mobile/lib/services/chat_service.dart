import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';
import '../models/conversation.dart';

class ChatService extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;
  String? _currentConversationId;
  
  final List<Message> _messages = [];
  final List<Conversation> _conversations = [];
  
  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  final StreamController<Conversation> _conversationController = StreamController<Conversation>.broadcast();

  // Getters
  bool get isConnected => _isConnected;
  List<Message> get messages => List.unmodifiable(_messages);
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  Stream<Message> get messageStream => _messageController.stream;
  Stream<Conversation> get conversationStream => _conversationController.stream;

  /// Connect to chat server
  Future<void> connect(String serverUrl, String userId) async {
    try {
      _currentUserId = userId;
      
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        _socket!.emit('join', {'userId': userId});
        debugPrint('Connected to chat server');
        notifyListeners();
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        debugPrint('Disconnected from chat server');
        notifyListeners();
      });

      _socket!.on('message', (data) {
        final message = Message.fromJson(data);
        _addMessage(message);
      });

      _socket!.on('conversation_update', (data) {
        final conversation = Conversation.fromJson(data);
        _updateConversation(conversation);
      });

      _socket!.on('error', (error) {
        debugPrint('Chat error: $error');
      });

    } catch (e) {
      debugPrint('Error connecting to chat: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Disconnect from server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
    notifyListeners();
  }

  /// Join a conversation
  void joinConversation(String conversationId) {
    _currentConversationId = conversationId;
    _messages.clear();
    _socket?.emit('join_conversation', {'conversationId': conversationId});
    notifyListeners();
  }

  /// Send a text message
  Future<void> sendMessage(String text, {String? gestureSign, double? gestureConfidence}) async {
    if (!_isConnected || _currentConversationId == null) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId!,
      senderName: 'You',
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
      type: gestureSign != null ? MessageType.gesture : MessageType.text,
      gestureSign: gestureSign,
      gestureConfidence: gestureConfidence,
    );

    _addMessage(message);

    _socket!.emit('send_message', {
      'conversationId': _currentConversationId,
      'message': message.toJson(),
    });
  }

  /// Add message to local list
  void _addMessage(Message message) {
    _messages.add(message);
    _messageController.add(message);
    notifyListeners();
  }

  /// Update conversation
  void _updateConversation(Conversation conversation) {
    final index = _conversations.indexWhere((c) => c.id == conversation.id);
    if (index >= 0) {
      _conversations[index] = conversation;
    } else {
      _conversations.add(conversation);
    }
    _conversationController.add(conversation);
    notifyListeners();
  }

  /// Load conversation history
  Future<void> loadConversationHistory(String conversationId) async {
    // TODO: Implement API call to load history
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    _messageController.close();
    _conversationController.close();
    super.dispose();
  }
}

