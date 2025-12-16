import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signlik_frontend/services/api_service.dart';
import 'package:signlik_frontend/models/friendship.dart';
import 'package:signlik_frontend/models/user.dart';
import 'package:signlik_frontend/screens/chat_screen.dart';
import 'package:signlik_frontend/screens/groups_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<User> friends = [];
  List<Friendship> pendingRequests = [];
  List<Friendship> sentRequests = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final friendsData = await api.getFriends();
      final pendingData = await api.getPendingRequests();
      final sentData = await api.getSentRequests();
      
      setState(() {
        friends = friendsData;
        pendingRequests = pendingData;
        sentRequests = sentData;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _sendRequest(String email) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.sendFriendRequest(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent')));
        _searchController.clear();
        _fetchData(); // Refresh to show in sent
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _accept(int id) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.acceptFriendRequest(id);
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _reject(int id) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.rejectFriendRequest(id);
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _remove(String email) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.removeFriend(email);
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends & Groups'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'My Friends'),
            Tab(text: 'Groups'),
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add Friend'),
                  content: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Enter email'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          _sendRequest(_searchController.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(),
                const GroupsScreen(),
                _buildReceivedList(),
                _buildSentList(),
              ],
            ),
    );
  }

  Widget _buildFriendsList() {
    if (friends.isEmpty) return const Center(child: Text('No friends yet'));
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: friend.profilePictureUrl != null 
                ? NetworkImage(friend.profilePictureUrl!) 
                : null,
            child: friend.profilePictureUrl == null ? Text(friend.initials) : null,
          ),
          title: Text(friend.name),
          subtitle: Text(friend.email),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen(friend: friend)),
            );
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chat, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen(friend: friend)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_remove, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Remove Friend'),
                      content: Text('Are you sure you want to remove ${friend.name}?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _remove(friend.email);
                          },
                          child: const Text('Remove', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceivedList() {
    if (pendingRequests.isEmpty) return const Center(child: Text('No pending requests'));
    return ListView.builder(
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final req = pendingRequests[index];
        return ListTile(
          leading: CircleAvatar(child: Text(req.requester.initials)),
          title: Text(req.requester.name),
          subtitle: Text('Sent: ${req.createdAt.toString().split(' ')[0]}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _accept(req.id),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _reject(req.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSentList() {
    if (sentRequests.isEmpty) return const Center(child: Text('No sent requests'));
    return ListView.builder(
      itemCount: sentRequests.length,
      itemBuilder: (context, index) {
        final req = sentRequests[index];
        return ListTile(
          leading: CircleAvatar(child: Text(req.addressee.initials)),
          title: Text(req.addressee.name),
          subtitle: Text('Status: ${req.status}'),
        );
      },
    );
  }
}
