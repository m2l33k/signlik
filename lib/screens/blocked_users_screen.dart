import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/blocked_user.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  bool _isLoading = true;
  List<BlockedUser> _blockedUsers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await Provider.of<ApiService>(context, listen: false).getBlockedUsers();
      if (mounted) {
        setState(() {
          _blockedUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unblock(String email) async {
    try {
      await Provider.of<ApiService>(context, listen: false).unblockUser(email);
      _loadBlockedUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User unblocked')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.purple.shade600],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _blockedUsers.isEmpty
                  ? const Center(child: Text('No blocked users'))
                  : ListView.builder(
                      itemCount: _blockedUsers.length,
                      itemBuilder: (context, index) {
                        final blocked = _blockedUsers[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text(blocked.blockedUser.initials)),
                          title: Text(blocked.blockedUser.name),
                          subtitle: Text('Blocked on: ${blocked.blockedAt.toString().split(' ')[0]}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.lock_open, color: Colors.red),
                            onPressed: () => _unblock(blocked.blockedUser.email),
                          ),
                        );
                      },
                    ),
    );
  }
}
