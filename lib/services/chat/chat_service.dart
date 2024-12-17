import 'package:aichatapp/services/chat/chat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveMessage(ChatMessageModel message, String userId) async {
    try {
      await _supabase.from('chat_history').insert({
        'user_id': userId,
        'session_id': message.sessionId,
        'role': message.role,
        'message': message.message,
        'message_time': message.messageTime.toIso8601String(),
        'title': message.title
      });
    } catch (e) {
      throw Exception('Failed to save message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatSession(String userId) async {
    try {
      final response = await _supabase
          .from('chat_history')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('message_time', ascending: false);

      final Map<String, Map<String, dynamic>> uniqueSession = {};
      for (var msg in response) {
        String sessionId = msg['session_id'];
        if (!uniqueSession.containsKey(sessionId)) {
          uniqueSession[sessionId] = {
            'session_id': sessionId,
            'title': msg['title'],
            'message_time': msg['message_time']
          };
        }
      }
      return uniqueSession.values.toList();
    } catch (e) {
      throw Exception('Failed to get chat session: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory(String userId) async {
    try {
      final response = await _supabase
          .from('chat_history')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('message_time', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get chat history: $e');
    }
  }
  
  // TODO: Fix this. Cannot update deleted_at data.
  Future<void> deleteSession(String userId, String sessionId) async {
    try {
      final updatedData = {'deleted_at': DateTime.now().toIso8601String()};
      final result = await _supabase
          .from('chat_history')
          .update(updatedData)
          .eq('user_id', userId)
          .eq('session_id', sessionId)
          .select();

      print('Delete operation completed. Result : $result');
    } catch (e) {
      print('Error details: $e');
      throw Exception('Failed to delete session: $e');
    }
  }
}
