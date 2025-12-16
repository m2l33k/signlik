import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signlik_frontend/services/api_service.dart';
import 'package:signlik_frontend/models/chat_message.dart';
import 'package:signlik_frontend/models/group.dart';
import 'package:signlik_frontend/models/reaction.dart';
import 'package:signlik_frontend/screens/group_details_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final Group group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
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
    setState(() {
      _currentUserEmail = email;
    });
  }

  Future<void> _loadMessages({bool refresh = false}) async {
    if (!refresh) setState(() => _isLoading = true);
    
    try {
      final messages = await Provider.of<ApiService>(context, listen: false)
          .getGroupMessages(widget.group.id!);
      
      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      if (!refresh) {
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (!refresh) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text;
    _messageController.clear();

    try {
      final newMessage = await Provider.of<ApiService>(context, listen: false)
          .sendGroupMessage(widget.group.id!, content);
      
      setState(() {
        _messages.add(newMessage);
      });
      
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final file = File(image.path);
      final api = Provider.of<ApiService>(context, listen: false);
      
      // 1. Upload file
      final uploadResult = await api.uploadFile(file, folder: 'group_chat_images');
      final imageUrl = uploadResult['url']; // Assuming backend returns 'url'

      // 2. Send message with image URL
      final newMessage = await api.sendGroupMessage(
        widget.group.id!, 
        imageUrl, 
        type: 'IMAGE'
      );
      
      setState(() {
        _messages.add(newMessage);
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Wait for build
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _addReaction(int messageId, String reaction) async {
    try {
      await Provider.of<ApiService>(context, listen: false).addReaction(messageId, reaction);
      _loadMessages(refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _showReactionPicker(int messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['👍', '❤️', '😂', '😮', '😢', '😡'].map((emoji) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _addReaction(messageId, emoji);
                },
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailsScreen(group: widget.group),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderEmail == _currentUserEmail;
                          
                          return GestureDetector(
                            onLongPress: () => _showReactionPicker(message.id),
                            child: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe) ...[
                                      Text(
                                        message.senderName ?? message.senderEmail,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    if (message.type == 'IMAGE')
                                      const Icon(Icons.image, size: 50) // Placeholder
                                    else
                                      Text(
                                        message.content,
                                        style: TextStyle(color: isMe ? Colors.white : Colors.black),
                                      ),
                                    if (message.reactions.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        children: message.reactions.map((r) => Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(r.reaction, style: const TextStyle(fontSize: 12)),
                                        )).toList(),
                                      ),
                                    ],
                                  ],
                                ),
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
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
