import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/user_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserPreferences? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await Provider.of<ApiService>(context, listen: false).getPreferences();
      setState(() {
        _prefs = prefs;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _updatePreference(UserPreferences newPrefs) async {
    // Optimistic update
    setState(() => _prefs = newPrefs);
    
    try {
      await Provider.of<ApiService>(context, listen: false).updatePreferences(newPrefs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
      // Revert could be implemented here if needed
    }
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final file = File(image.path);
      final api = Provider.of<ApiService>(context, listen: false);
      
      // Upload file
      await api.uploadFile(file, folder: 'avatars');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
      }
      
      // Trigger a profile reload if possible, or assume backend handles it
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prefs == null
              ? const Center(child: Text('Could not load settings'))
              : ListView(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 50),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                                onPressed: _updateProfilePicture,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSectionHeader('Account'),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Activity Log'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.pushNamed(context, '/activity'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.block),
                      title: const Text('Blocked Users'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.pushNamed(context, '/blocked'),
                    ),
                    _buildSectionHeader('Appearance'),
                    ListTile(
                      title: const Text('Theme'),
                      trailing: DropdownButton<String>(
                        value: _prefs!.theme,
                        onChanged: (val) {
                          if (val != null) {
                            _updatePreference(UserPreferences(
                              id: _prefs!.id,
                              theme: val,
                              language: _prefs!.language,
                              notificationsEnabled: _prefs!.notificationsEnabled,
                              emailNotifications: _prefs!.emailNotifications,
                              pushNotifications: _prefs!.pushNotifications,
                              autoPlayMedia: _prefs!.autoPlayMedia,
                              showOnlineStatus: _prefs!.showOnlineStatus,
                              allowFriendRequests: _prefs!.allowFriendRequests,
                              messageSoundEnabled: _prefs!.messageSoundEnabled,
                            ));
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'light', child: Text('Light')),
                          DropdownMenuItem(value: 'dark', child: Text('Dark')),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text('Language'),
                      trailing: DropdownButton<String>(
                        value: _prefs!.language,
                        onChanged: (val) {
                          if (val != null) {
                            _updatePreference(UserPreferences(
                              id: _prefs!.id,
                              theme: _prefs!.theme,
                              language: val,
                              notificationsEnabled: _prefs!.notificationsEnabled,
                              emailNotifications: _prefs!.emailNotifications,
                              pushNotifications: _prefs!.pushNotifications,
                              autoPlayMedia: _prefs!.autoPlayMedia,
                              showOnlineStatus: _prefs!.showOnlineStatus,
                              allowFriendRequests: _prefs!.allowFriendRequests,
                              messageSoundEnabled: _prefs!.messageSoundEnabled,
                            ));
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'fr', child: Text('French')),
                          DropdownMenuItem(value: 'es', child: Text('Spanish')),
                        ],
                      ),
                    ),
                    const Divider(),
                    _buildSectionHeader('Notifications'),
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      value: _prefs!.notificationsEnabled,
                      onChanged: (val) => _updatePreference(UserPreferences(
                        id: _prefs!.id,
                        theme: _prefs!.theme,
                        language: _prefs!.language,
                        notificationsEnabled: val,
                        emailNotifications: _prefs!.emailNotifications,
                        pushNotifications: _prefs!.pushNotifications,
                        autoPlayMedia: _prefs!.autoPlayMedia,
                        showOnlineStatus: _prefs!.showOnlineStatus,
                        allowFriendRequests: _prefs!.allowFriendRequests,
                        messageSoundEnabled: _prefs!.messageSoundEnabled,
                      )),
                    ),
                    if (_prefs!.notificationsEnabled) ...[
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        value: _prefs!.emailNotifications,
                        onChanged: (val) => _updatePreference(UserPreferences(
                          id: _prefs!.id,
                          theme: _prefs!.theme,
                          language: _prefs!.language,
                          notificationsEnabled: _prefs!.notificationsEnabled,
                          emailNotifications: val,
                          pushNotifications: _prefs!.pushNotifications,
                          autoPlayMedia: _prefs!.autoPlayMedia,
                          showOnlineStatus: _prefs!.showOnlineStatus,
                          allowFriendRequests: _prefs!.allowFriendRequests,
                          messageSoundEnabled: _prefs!.messageSoundEnabled,
                        )),
                      ),
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        value: _prefs!.pushNotifications,
                        onChanged: (val) => _updatePreference(UserPreferences(
                          id: _prefs!.id,
                          theme: _prefs!.theme,
                          language: _prefs!.language,
                          notificationsEnabled: _prefs!.notificationsEnabled,
                          emailNotifications: _prefs!.emailNotifications,
                          pushNotifications: val,
                          autoPlayMedia: _prefs!.autoPlayMedia,
                          showOnlineStatus: _prefs!.showOnlineStatus,
                          allowFriendRequests: _prefs!.allowFriendRequests,
                          messageSoundEnabled: _prefs!.messageSoundEnabled,
                        )),
                      ),
                      SwitchListTile(
                        title: const Text('Message Sound'),
                        value: _prefs!.messageSoundEnabled,
                        onChanged: (val) => _updatePreference(UserPreferences(
                          id: _prefs!.id,
                          theme: _prefs!.theme,
                          language: _prefs!.language,
                          notificationsEnabled: _prefs!.notificationsEnabled,
                          emailNotifications: _prefs!.emailNotifications,
                          pushNotifications: _prefs!.pushNotifications,
                          autoPlayMedia: _prefs!.autoPlayMedia,
                          showOnlineStatus: _prefs!.showOnlineStatus,
                          allowFriendRequests: _prefs!.allowFriendRequests,
                          messageSoundEnabled: val,
                        )),
                      ),
                    ],
                    const Divider(),
                    _buildSectionHeader('Privacy & Media'),
                    SwitchListTile(
                      title: const Text('Show Online Status'),
                      value: _prefs!.showOnlineStatus,
                      onChanged: (val) => _updatePreference(UserPreferences(
                        id: _prefs!.id,
                        theme: _prefs!.theme,
                        language: _prefs!.language,
                        notificationsEnabled: _prefs!.notificationsEnabled,
                        emailNotifications: _prefs!.emailNotifications,
                        pushNotifications: _prefs!.pushNotifications,
                        autoPlayMedia: _prefs!.autoPlayMedia,
                        showOnlineStatus: val,
                        allowFriendRequests: _prefs!.allowFriendRequests,
                        messageSoundEnabled: _prefs!.messageSoundEnabled,
                      )),
                    ),
                    SwitchListTile(
                      title: const Text('Allow Friend Requests'),
                      value: _prefs!.allowFriendRequests,
                      onChanged: (val) => _updatePreference(UserPreferences(
                        id: _prefs!.id,
                        theme: _prefs!.theme,
                        language: _prefs!.language,
                        notificationsEnabled: _prefs!.notificationsEnabled,
                        emailNotifications: _prefs!.emailNotifications,
                        pushNotifications: _prefs!.pushNotifications,
                        autoPlayMedia: _prefs!.autoPlayMedia,
                        showOnlineStatus: _prefs!.showOnlineStatus,
                        allowFriendRequests: val,
                        messageSoundEnabled: _prefs!.messageSoundEnabled,
                      )),
                    ),
                    SwitchListTile(
                      title: const Text('Auto-play Media'),
                      value: _prefs!.autoPlayMedia,
                      onChanged: (val) => _updatePreference(UserPreferences(
                        id: _prefs!.id,
                        theme: _prefs!.theme,
                        language: _prefs!.language,
                        notificationsEnabled: _prefs!.notificationsEnabled,
                        emailNotifications: _prefs!.emailNotifications,
                        pushNotifications: _prefs!.pushNotifications,
                        autoPlayMedia: val,
                        showOnlineStatus: _prefs!.showOnlineStatus,
                        allowFriendRequests: _prefs!.allowFriendRequests,
                        messageSoundEnabled: _prefs!.messageSoundEnabled,
                      )),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
