import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class GenerativeAiService {
  static const String _usageCountKey = 'gen_ai_usage_count';
  static const String _usageDateKey = 'gen_ai_usage_date';
  static const String _customApiKeyKey = 'gen_ai_custom_api_key';
  static const int dailyLimit = 10;

  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final customKey = prefs.getString(_customApiKeyKey);
    if (customKey != null && customKey.trim().isNotEmpty) {
      return customKey.trim();
    }
    
    // Fallback to remote config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final remoteKey = remoteConfig.getString('gemini_api_key');
    if (remoteKey.isNotEmpty) {
      return remoteKey;
    }
    
    return null;
  }

  Future<bool> checkUsage() async {
    // Limit removed for now
    return true;
  }

  Future<void> incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString(_customApiKeyKey) ?? '').trim().isNotEmpty) {
      return;
    }

    final today = DateTime.now().toIso8601String().split('T').first;
    final lastDate = prefs.getString(_usageDateKey);
    
    if (lastDate != today) {
      await prefs.setString(_usageDateKey, today);
      await prefs.setInt(_usageCountKey, 1);
    } else {
      final count = prefs.getInt(_usageCountKey) ?? 0;
      await prefs.setInt(_usageCountKey, count + 1);
    }
  }

  Future<void> setCustomApiKey(String? key) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == null || key.trim().isEmpty) {
      await prefs.remove(_customApiKeyKey);
    } else {
      await prefs.setString(_customApiKeyKey, key.trim());
    }
  }

  Future<List<Map<String, String>>> generateTracklist(String prompt, {int count = 20}) async {
    final apiKey = await _getApiKey();
    if (apiKey == null) {
      throw Exception('API Key not configured. Please add a custom Gemini key in settings.');
    }

    if (!await checkUsage()) {
      throw Exception('Daily generation limit reached ($dailyLimit). Add your own API key to generate more!');
    }

    final systemInstruction = '''You are a music expert recommending songs for a playlist.
The user will give you a prompt. Return exactly $count highly relevant songs.
You must respond with a JSON array of objects. 
Each object must have exactly two keys: "title" (string) and "artist" (string).
Example Schema: [{"title": "Song Name", "artist": "Artist Name"}]''';

    // Primary: gemini-2.0-flash-lite (v1) - Maximum stability "Safe Mode"
    String modelName = 'gemini-2.0-flash-lite';
    String apiVersion = 'v1';
    
    try {
      final result = await _generateWithModel(modelName, apiKey, prompt, systemInstruction, apiVersion);
      await incrementUsage(); // Only increment on success
      return result;
    } catch (e) {
      log('Gemini Safe Mode failed: $e. Trying fallback...', name: 'GenerativeAiService');
      // Fallback: Use v1beta but STILL without responseMimeType to be safe
      final result = await _generateWithModel('gemini-flash-latest', apiKey, prompt, systemInstruction, 'v1beta');
      await incrementUsage(); // Only increment on success
      return result;
    }
  }

  Future<List<Map<String, String>>> _generateWithModel(
    String modelName,
    String apiKey,
    String prompt,
    String systemInstruction,
    String apiVersion,
  ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/$apiVersion/models/$modelName:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': "$systemInstruction\n\nReturn EXACTLY a JSON array of objects. No intro text. No conversational filler.\nUser prompt: $prompt"}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        }
      }),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      final message = errorBody['error']?['message'] ?? 'Unknown error';
      
      if (response.statusCode == 429) {
        throw Exception(
          'Gemini is taking a short break! ☕\n\n'
          'The free quota was reached. Please wait ~60 seconds or add your own API key using the key icon at the top.'
        );
      }
      
      throw Exception('AI API Error (${response.statusCode}): $message');
    }

    final data = jsonDecode(response.body);
    String? text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    
    if (text == null || text.trim().isEmpty) {
      throw Exception('Empty response from AI.');
    }

    text = text.trim();

    try {
      // In JSON mode, the response should be direct JSON, but we'll still handle potential markdown wrapping just in case
      final jsonString = text.startsWith('```') 
          ? RegExp(r'\[.*\]', dotAll: true).firstMatch(text)?.group(0) ?? text
          : text;

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final result = <Map<String, String>>[];
      for (var item in jsonList) {
        if (item is Map && item.containsKey('title') && item.containsKey('artist')) {
          result.add({
            'title': item['title'].toString(),
            'artist': item['artist'].toString(),
          });
        }
      }
      
      if (result.isEmpty) {
        throw Exception('No songs found in AI response.');
      }
      
      return result;
    } catch (e) {
      log('JSON Decode Fallback for: $text', name: 'GenerativeAiService');
      // If direct decode fails, try regex extraction as a last resort
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(text);
      if (jsonMatch != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(jsonMatch.group(0)!);
          final result = <Map<String, String>>[];
          for (var item in jsonList) {
            if (item is Map && item.containsKey('title') && item.containsKey('artist')) {
              result.add({
                'title': item['title'].toString(),
                'artist': item['artist'].toString(),
              });
            }
          }
          return result;
        } catch (_) {}
      }
      throw Exception('Failed to decode AI response. Please try a different prompt.');
    }
  }
}
