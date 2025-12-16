import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/chat_message.dart';
import '../models/user.dart';

class ChatScreen extends StatefulWidget {
  final User friend;

  const ChatScreen({super.key, required this.friend});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  Timer? _timer;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    // Poll for new messages every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _loadMessages(refresh: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final email = await Provider.of<ApiService>(context, listen: false).getUserEmail();
    if (!mounted) return;
    setState(() {
      _currentUserEmail = email;
    });
  }

  Future<void> _loadMessages({bool refresh = false}) async {
    if (!refresh) setState(() => _isLoading = true);
    
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final messages = await api.getConversation(widget.friend.email);
      
      if (!mounted) return;

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      // Mark as read
      await api.markMessagesAsRead(widget.friend.email);
      if (!mounted) return;
          
      // Scroll to bottom if not refreshing (or if new message arrived - logic can be improved)
      if (!refresh && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Don't show error on poll to avoid annoyance
        if (!refresh) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final file = File(image.path);
      final api = Provider.of<ApiService>(context, listen: false);
      
      // 1. Upload file
      final uploadResult = await api.uploadFile(file, folder: 'chat_images');
      final imageUrl = uploadResult['url']; // Assuming backend returns 'url'

      // 2. Send message with image URL
      final newMessage = await api.sendMessage(
        widget.friend.email, 
        imageUrl, 
        type: 'IMAGE'
      );
      
      if (!mounted) return;

      setState(() {
        _messages.add(newMessage);
        _isLoading = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text;
    _messageController.clear();

    try {
      final newMessage = await Provider.of<ApiService>(context, listen: false)
          .sendMessage(widget.friend.email, content);
      
      if (!mounted) return;

      setState(() {
        _messages.add(newMessage);
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.friend.profilePictureUrl != null 
                  ? NetworkImage(widget.friend.profilePictureUrl!) 
                  : null,
              child: widget.friend.profilePictureUrl == null 
                  ? Text(widget.friend.initials) 
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.friend.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('No messages yet. Say hi!'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.sender.email == _currentUserEmail;
                          return GestureDetector(
                            onLongPress: () => _showReactionPicker(message),
                            child: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.blue : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.content,
                                          style: TextStyle(
                                            color: isMe ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatTime(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isMe ? Colors.white70 : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (message.reactions.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Wrap(
                                        spacing: 4,
                                        children: message.reactions.map((r) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Text(r.reaction, style: const TextStyle(fontSize: 12)),
                                        )).toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickAndSendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showReactionPicker(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['👍', '❤️', '😂', '😮', '😢', '😡'].map((emoji) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _addReaction(message, emoji);
                },
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _addReaction(ChatMessage message, String reaction) async {
    if (message.id == null) return;
    try {
      await Provider.of<ApiService>(context, listen: false)
          .addReaction(message.id!, reaction); // Assuming message.id is unique across all messages
      // Ideally we should refresh the message list or update locally
      if (!mounted) return;
      _loadMessages(refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add reaction: $e')));
      }
    }
  }
}
