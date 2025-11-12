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

  ValueListenable<bool> get isProcessing => _conversation.isProcessing;

  final List<ChatMessageModel> _messages = [];

  final List<ChatMessageModel> _messagesHistory = [];

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  List<ChatMessageModel> get messagesHistory => List.unmodifiable(_messagesHistory);

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
      },
      onTextResponse: (text) {
        _messages.add(ChatMessageModel(text: text));
        notifyListeners();
      },
      onError: (err) {
        _messages.add(ChatMessageModel(text: err.error.toString(), isError: true));
        notifyListeners();
      },
    );
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    final message = ChatMessageModel(text: text, isUser: true);
    _messages.add(message);
    _saveHistory(message);
    notifyListeners();
    await _conversation.sendRequest(UserMessage([TextPart(text)]));
  }

  void disposeConversation() {
    _conversation.dispose();
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
}
