import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav.dart';
import '../models/user.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool isLoading = true;
  String? error;
  final int _navIndex = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProfile());
  }

  Future<void> _fetchProfile() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final email = await api.getUserEmail();
      
      if (email == null) {
        setState(() {
          isLoading = false;
          error = "User email not found. Please login again.";
        });
        return;
      }

      final profileData = await api.getProfile(email);
      
      setState(() {
        if (profileData.isNotEmpty) {
             user = User.fromJson(profileData);
        } else {
             error = "Failed to load profile data.";
        }
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _showEditProfileDialog() {
    if (user == null) return;
    
    final nameController = TextEditingController(text: user!.name);
    final languageController = TextEditingController(text: user!.preferredLanguage);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Edit Profile"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: languageController,
                  decoration: const InputDecoration(labelText: "Preferred Language"),
                ),
                if (isSaving)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  setDialogState(() => isSaving = true);
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(ctx);
                  try {
                    final api = Provider.of<ApiService>(context, listen: false);
                    final updatedData = {
                      'username': nameController.text,
                      'preferredLanguage': languageController.text,
                      'email': user!.email,
                      'role': user!.role,
                      // Add other fields if necessary, or backend handles partial updates
                    };
                    
                    await api.updateProfile(user!.email, updatedData);
                    
                    if (mounted) {
                      navigator.pop();
                      _fetchProfile(); // Refresh
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Profile updated successfully"))
                      );
                    }
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text("Error updating profile: $e"))
                      );
                    }
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        }
      ),
    );
  }

  void _navTap(int idx) {
    if (idx == 0) Navigator.pushReplacementNamed(context, '/home');
    if (idx == 1) Navigator.pushReplacementNamed(context, '/translator');
    if (idx == 2) Navigator.pushReplacementNamed(context, '/learning');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (error != null) {
       return Scaffold(
         body: Center(child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Text(error!, style: const TextStyle(color: Colors.red)),
             const SizedBox(height: 20),
             ElevatedButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false), child: const Text("Go to Login"))
           ]
         ))
       );
    }

    if (user == null) {
       return const Scaffold(body: Center(child: Text("User not found")));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.purple.shade600])),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.blue.shade200,
                        child: Text(user!.initials,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user!.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text(user!.email,
                              style:
                                  const TextStyle(color: Color(0xFFBBDEFB))),
                        ],
                      )
                    ],
                  ),
                  IconButton(
                      onPressed: _showEditProfileDialog, icon: const Icon(Icons.edit, color: Colors.white))
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                        child: ListTile(
                      title: Text('Level ${user!.level}'),
                      subtitle: const Text('27/50'),
                      trailing: ElevatedButton(
                          onPressed: _showEditProfileDialog, child: const Text('Edit Profile')),
                    )),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  const Text('Total Translations',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text('${user!.translations}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  const Text('Minutes Used',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text('${user!.minutesUsed}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                        child: ListTile(
                      leading: const Icon(Icons.settings, color: Colors.grey),
                      title: const Text('Settings'),
                      subtitle: const Text('App preferences, notifications, theme'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      ),
                    )),
                    const SizedBox(height: 12),
                    
                    // Social Section
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Social', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.people, color: Colors.blue),
                            title: const Text('Friends'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.pushNamed(context, '/friends'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.block, color: Colors.red),
                            title: const Text('Blocked Users'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.pushNamed(context, '/blocked'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // History Section
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.history, color: Colors.purple),
                            title: const Text('Activity Log'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.pushNamed(context, '/activity'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.notifications_active, color: Colors.orange),
                            title: const Text('Notifications History'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.pushNamed(context, '/notifications'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        // Clear user data on logout
                        final api = Provider.of<ApiService>(context, listen: false);
                        await api.clearUserData();
                        if (context.mounted) {
                           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Log Out'),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            BottomNav(currentIndex: _navIndex, onTap: _navTap),
          ],
        ),
      ),
    );
  }
}
