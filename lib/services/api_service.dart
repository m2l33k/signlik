import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:signlik_frontend/models/chat_message.dart';
import 'package:signlik_frontend/models/reaction.dart';
import 'package:signlik_frontend/models/user_preferences.dart';
import 'package:signlik_frontend/models/group.dart';
import 'package:signlik_frontend/models/sign.dart';
import 'package:signlik_frontend/models/notification_item.dart';
import 'package:signlik_frontend/models/activity_log.dart';
import 'package:signlik_frontend/models/blocked_user.dart';
import 'package:signlik_frontend/models/friendship.dart';
import 'package:signlik_frontend/models/user.dart';

class ApiService {
  // Change this to your deployed backend URL
  // Use 10.0.2.2 for Android emulator to access localhost of the host machine
  // Use localhost for Web
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081/api';
    }
    return 'http://10.0.2.2:8081/api';
  }

  static String get pythonBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    return 'http://10.0.2.2:8000/api';
  }
  
  String? _token;

  /// Get stored authentication token
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  /// Clear authentication token and user data
  Future<void> clearUserData() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
  }

  /// Make authenticated HTTP request
  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    bool usePythonBackend = false,
  }) async {
    final baseUrlToUse = usePythonBackend ? pythonBaseUrl : baseUrl;
    final url = Uri.parse('$baseUrlToUse$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PATCH':
        response = await http.patch(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    return response;
  }

  // ===========================================================================
  // Auth Endpoints
  // ===========================================================================

  Future<Map<String, dynamic>> register(String email, String password, {String? name}) async {
    try {
      final response = await _request(
        'POST',
        '/auth/register',
        body: {
          'email': email,
          'password': password,
          'username': name ?? email.split('@')[0],
          'role': 'HEARING',
        },
        requiresAuth: false,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _request(
        'POST',
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
          await saveUserEmail(email);
        }
        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile(String email) async {
    final response = await _request('GET', '/users/profile/$email');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>> updateProfile(String email, Map<String, dynamic> data) async {
    final response = await _request('PUT', '/users/profile/$email', body: data);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  // ===========================================================================
  // Sign Endpoints
  // ===========================================================================

  Future<List<Sign>> getAllSigns({bool includeUnapproved = false}) async {
    // Note: Checking both Python and Spring backends based on original file logic
    // Using Python backend as per original implementation for search/list
    final response = await _request('GET', '/signs?includeUnapproved=$includeUnapproved', usePythonBackend: true);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Sign.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load signs: ${response.body}');
    }
  }

  Future<List<Sign>> searchSigns(String query) async {
    final response = await _request('GET', '/signs/search?query=$query', usePythonBackend: true);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Sign.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<List<Sign>> getSignsByCategory(String category) async {
    final response = await _request('GET', '/signs/category/$category', usePythonBackend: true);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Sign.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  // ===========================================================================
  // Gesture History & Translation Endpoints
  // ===========================================================================

  Future<List<dynamic>> getGestureHistory() async {
    final response = await _request('GET', '/gestures/history');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get gesture history: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> saveGestureHistory(
    String gesture,
    double confidence, {
    List<double>? landmarks,
  }) async {
    final response = await _request(
      'POST',
      '/gestures/history',
      body: {
        'gesture': gesture,
        'confidence': confidence,
        if (landmarks != null) 'landmarks': landmarks,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to save gesture history: ${response.body}');
    }
  }

  // ===========================================================================
  // Friendship Endpoints
  // ===========================================================================

  Future<List<User>> getFriends() async {
    final response = await _request('GET', '/friends');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get friends: ${response.body}');
    }
  }

  Future<List<Friendship>> getPendingRequests() async {
    final response = await _request('GET', '/friends/pending');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Friendship.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get pending requests: ${response.body}');
    }
  }

  Future<List<Friendship>> getSentRequests() async {
    final response = await _request('GET', '/friends/sent');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Friendship.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get sent requests: ${response.body}');
    }
  }

  Future<void> sendFriendRequest(String toEmail) async {
    final response = await _request(
      'POST',
      '/friends/request?toEmail=$toEmail',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send friend request: ${response.body}');
    }
  }

  Future<void> acceptFriendRequest(int friendshipId) async {
    final response = await _request(
      'PUT',
      '/friends/accept/$friendshipId',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to accept friend request: ${response.body}');
    }
  }

  Future<void> rejectFriendRequest(int friendshipId) async {
    final response = await _request(
      'DELETE',
      '/friends/reject/$friendshipId',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reject friend request: ${response.body}');
    }
  }

  Future<void> removeFriend(String friendEmail) async {
    final response = await _request(
      'DELETE',
      '/friends/remove?friendEmail=$friendEmail',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove friend: ${response.body}');
    }
  }

  // ===========================================================================
  // Blocked User Endpoints
  // ===========================================================================

  Future<List<BlockedUser>> getBlockedUsers() async {
    final response = await _request('GET', '/blocked');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BlockedUser.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get blocked users: ${response.body}');
    }
  }

  Future<void> blockUser(String blockedUserEmail, {String? reason}) async {
    String url = '/blocked/block?blockedUserEmail=$blockedUserEmail';
    if (reason != null) {
      url += '&reason=$reason';
    }
    final response = await _request('POST', url);
    if (response.statusCode != 200) {
      throw Exception('Failed to block user: ${response.body}');
    }
  }

  Future<void> unblockUser(String blockedUserEmail) async {
    final response = await _request(
      'POST',
      '/blocked/unblock?blockedUserEmail=$blockedUserEmail',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unblock user: ${response.body}');
    }
  }

  Future<bool> checkBlocked(String otherUserEmail) async {
    final response = await _request(
      'GET',
      '/blocked/check?otherUserEmail=$otherUserEmail',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isBlocked'] ?? false;
    } else {
      throw Exception('Failed to check blocked status: ${response.body}');
    }
  }

  // ===========================================================================
  // Activity Log Endpoints
  // ===========================================================================

  Future<List<ActivityLog>> getUserActivity() async {
    final response = await _request('GET', '/activity');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ActivityLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get user activity: ${response.body}');
    }
  }

  Future<List<ActivityLog>> getActivitySince(DateTime since) async {
    final response = await _request(
      'GET', 
      '/activity/since?since=${since.toIso8601String()}'
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ActivityLog.fromJson(json)).toList();
    }
    throw Exception('Failed to get activity since: ${response.body}');
  }

  // ===========================================================================
  // Notification Endpoints
  // ===========================================================================

  Future<List<NotificationItem>> getNotifications() async {
    final response = await _request('GET', '/notifications');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get notifications: ${response.body}');
    }
  }

  Future<List<NotificationItem>> getUnreadNotifications() async {
    final response = await _request('GET', '/notifications/unread');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get unread notifications: ${response.body}');
    }
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await _request('GET', '/notifications/unread-count');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Failed to get notification count: ${response.body}');
    }
  }

  Future<void> markNotificationRead(int id) async {
    final response = await _request('PUT', '/notifications/$id/read');
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read: ${response.body}');
    }
  }

  Future<void> markAllNotificationsRead() async {
    final response = await _request('PUT', '/notifications/read-all');
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read: ${response.body}');
    }
  }

  Future<void> deleteNotification(int id) async {
    final response = await _request('DELETE', '/notifications/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification: ${response.body}');
    }
  }

  // ===========================================================================
  // Chat & Reaction Endpoints
  // ===========================================================================

  Future<List<ChatMessage>> getConversation(String withEmail) async {
    final response = await _request('GET', '/messages/conversation?withEmail=$withEmail');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    }
    throw Exception('Failed to load conversation: ${response.body}');
  }

  Future<ChatMessage> sendMessage(String toEmail, String content, {String type = 'TEXT'}) async {
    final response = await _request(
      'POST',
      '/messages/send?toEmail=$toEmail&content=$content&type=$type',
    );
    if (response.statusCode == 200) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to send message: ${response.body}');
  }

  Future<void> markMessagesAsRead(String withEmail) async {
    await _request('PUT', '/messages/read?withEmail=$withEmail');
  }

  Future<void> addReaction(int messageId, String reaction) async {
    final response = await _request(
      'POST',
      '/reactions/message/$messageId?reaction=$reaction',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add reaction: ${response.body}');
    }
  }

  Future<void> removeReaction(int messageId) async {
    final response = await _request(
      'DELETE',
      '/reactions/message/$messageId',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove reaction: ${response.body}');
    }
  }

  Future<List<Reaction>> getMessageReactions(int messageId) async {
    final response = await _request('GET', '/reactions/message/$messageId');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reaction.fromJson(json)).toList();
    }
    throw Exception('Failed to get message reactions: ${response.body}');
  }

  Future<int> getUnreadMessageCount() async {
    final response = await _request('GET', '/messages/unread-count');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    }
    throw Exception('Failed to get unread message count: ${response.body}');
  }

  // ===========================================================================
  // User Preferences Endpoints
  // ===========================================================================

  Future<UserPreferences> getPreferences() async {
    final response = await _request('GET', '/preferences');
    if (response.statusCode == 200) {
      return UserPreferences.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load preferences: ${response.body}');
  }

  Future<UserPreferences> updatePreferences(UserPreferences prefs) async {
    final response = await _request('PUT', '/preferences', body: prefs.toJson());
    if (response.statusCode == 200) {
      return UserPreferences.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update preferences: ${response.body}');
  }

  // ===========================================================================
  // Group Endpoints
  // ===========================================================================

  Future<List<Group>> getMyGroups() async {
    final response = await _request('GET', '/groups/my-groups');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Group.fromJson(json)).toList();
    }
    throw Exception('Failed to load groups: ${response.body}');
  }

  Future<Group> createGroup(String name, String description) async {
    final response = await _request('POST', '/groups/create?name=$name&description=$description');
    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create group: ${response.body}');
  }

  Future<void> addGroupMember(int groupId, String userEmail, {String role = 'MEMBER'}) async {
    final response = await _request(
      'POST', 
      '/groups/$groupId/members?userEmail=$userEmail&role=$role'
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add member: ${response.body}');
    }
  }

  Future<void> removeGroupMember(int groupId, String userEmail) async {
    final response = await _request(
      'DELETE', 
      '/groups/$groupId/members?userEmail=$userEmail'
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove member: ${response.body}');
    }
  }

  Future<List<User>> getGroupMembers(int groupId) async {
    final response = await _request('GET', '/groups/$groupId/members');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Failed to load group members: ${response.body}');
  }

  Future<List<ChatMessage>> getGroupMessages(int groupId) async {
    final response = await _request('GET', '/groups/$groupId/messages');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    }
    throw Exception('Failed to load group messages: ${response.body}');
  }

  Future<ChatMessage> sendGroupMessage(int groupId, String content, {String type = 'TEXT'}) async {
    final response = await _request(
      'POST',
      '/groups/$groupId/messages?content=$content&type=$type',
    );
    if (response.statusCode == 200) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to send group message: ${response.body}');
  }

  // ===========================================================================
  // File Endpoints
  // ===========================================================================

  Future<Map<String, dynamic>> uploadFile(File file, {String folder = 'general'}) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/files/upload');
    
    final request = http.MultipartRequest('POST', url);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.fields['folder'] = folder;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload file: ${response.body}');
    }
  }
}
