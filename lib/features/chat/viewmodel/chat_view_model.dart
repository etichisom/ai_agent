import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:hack_the_future_starter/const.dart';
import 'package:hack_the_future_starter/features/chat/models/chat_message.dart';
import 'package:hack_the_future_starter/features/chat/services/genui_service.dart';
import 'package:hive_ce/hive.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({GenUiService? service}) : _service = service ?? GenUiService();

  final GenUiService _service;

  late final Catalog _catalog;
  late final GenUiManager _manager;
  late final GenUiConversation _conversation;

  GenUiHost get host => _conversation.host;

  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  String? _lastUserMessage;

  final List<ChatMessageModel> _messages = [];

  final List<ChatMessageModel> _messagesHistory = [];

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  List<ChatMessageModel> get messagesHistory => List.unmodifiable(_messagesHistory);

  final List<String> _runLog = [];
  List<String> get runLog => List.unmodifiable(_runLog);

  void init() {
    _catalog = _service.createCatalog();
    _manager = GenUiManager(catalog: _catalog);
    _loadHistory();
    final generator = _service.createContentGenerator(catalog: _catalog);
    _conversation = GenUiConversation(
      genUiManager: _manager,
      contentGenerator: generator,
      onSurfaceAdded: (s) {
        _messages.add(ChatMessageModel(surfaceId: s.surfaceId));
        notifyListeners();
        _log("Surface added: ${s.surfaceId}");
      },
      onTextResponse: (text) {
        _messages.add(ChatMessageModel(text: text));
        notifyListeners();
        _log("Text response: $text");
      },
      onError: (err) {
        _log("Error occurred: ${err.error}");
        _useMockResponse(_lastUserMessage ?? "");
       // _messages.add(ChatMessageModel(text: err.error.toString(), isError: true));
        notifyListeners();
      },
    )..isProcessing.addListener((){
      _isProcessing = _conversation.isProcessing.value;
      notifyListeners();
    });
  }


  void _log(String msg) {
    final logMessage = "[${DateTime.now().toIso8601String()}] $msg";
    _runLog.add("[${DateTime.now().toIso8601String()}] $msg");
    debugPrint(logMessage);
    notifyListeners();
  }

  Future<void> send(String text) async {
    try{
      if (text.trim().isEmpty) return;
      _messages.clear();
      final message = ChatMessageModel(text: text, isUser: true);
      _lastUserMessage = text;
      _messages.add(message);
      _saveHistory(message);
      notifyListeners();
      await _conversation.sendRequest(UserMessage([TextPart(text)]));
    }catch(e){
      _log("Send failed: $e — using fallback");
      _useMockResponse(text);
    }
  }

  void disposeConversation() {
    _conversation.dispose();
    _isProcessing = false;
    notifyListeners();
    init();
    debugPrint('🛑 Agent processing aborted.');
  }


  Future<void> _saveHistory(ChatMessageModel message) async {
    final chatBox = Hive.box<String>(kChatStorageKey);
    chatBox.put(message.id, jsonEncode(message.toJson()));
    _loadHistory();
  }

  Future<void> clearHistory() async {
    final chatBox = Hive.box<String>(kChatStorageKey);
    chatBox.clear();
    _messagesHistory.clear();
    notifyListeners();
  }

  Future<void> deleteById(String id) async {
    final chatBox = Hive.box<String>(kChatStorageKey);
    chatBox.delete(id);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final chatBox = Hive.box<String>(kChatStorageKey);
      final List decoded = chatBox.values.toList() ;
      _messagesHistory.clear();
      _messagesHistory.addAll(decoded.map((e) => ChatMessageModel.fromJson(jsonDecode(e))));
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Failed to load history: $e');
    }
  }



  void _useMockResponse(String text) {
    final mockResponses = {
      "temperature": "🌡️ Average ocean temperature: 15.4°C (mock data)",
      "salinity": "🧂 Average salinity: 35 PSU (mock data)",
      "waves": "🌊 Wave height: 2.1m (mock data)",
      "depth": "📏 Average ocean depth: 3,688 meters (mock data)",
      "currents": "🌊 Ocean currents moving eastward at ~1.5 knots (mock data)",
    };

    // Try to find a match for the user's text
    final response = mockResponses.entries.firstWhere(
          (e) => text.toLowerCase().contains(e.key),
      orElse: () => const MapEntry("default", ""),
    );

    // 🧩 If no match found, show a generic fallback response
    final fallbackMessage = response.value.isEmpty
        ? '''
🌊 **Mock Ocean Data (Offline Mode)**
Since live data isn't available right now, here’s a placeholder response:

- Average Sea Temperature: **16.2°C**
- Average Salinity: **34.8 PSU**
- Wave Height: **2.3m**
- Current Speed: **1.2 knots**
- Note: This is **mock data** used while the AI service is offline.
'''
        : response.value;

    // Add it as a message
    _messages.add(ChatMessageModel(text: fallbackMessage));
    _log("⚠️ Mock response used for '${response.key.isEmpty ? "default" : response.key}'");
    notifyListeners();
  }


}
