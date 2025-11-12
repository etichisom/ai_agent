import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hack_the_future_starter/features/chat/view/empty_state.dart';
import 'package:hack_the_future_starter/l10n/app_localizations.dart';
import '../viewmodel/chat_view_model.dart';
import 'component/chat_bubble.dart';
import 'component/input_bar.dart';
import 'component/typing_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel()..init();
  }

  @override
  void dispose() {
    _viewModel.disposeConversation();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _viewModel.send(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _stop() {
    _viewModel.disposeConversation();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🛑 Generation stopped.")));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: CupertinoNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          middle: Text(l10n.appBarTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
          border: const Border(bottom: BorderSide(color: Color(0x33000000), width: 0.5)),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            return Container(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
              child: Column(
                children: [
                  if (_viewModel.messages.isEmpty)
                    Expanded(child: EmptyState())
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        itemCount: _viewModel.messages.length,
                        itemBuilder: (_, i) {
                          final m = _viewModel.messages[i];
                          return ChatBubble(model: m, host: _viewModel.host, l10n: l10n);
                        },
                      ),
                    ),

                  // Typing indicator or stop button
                  ValueListenableBuilder<bool>(
                    valueListenable: _viewModel.isProcessing,
                    builder: (_, isProcessing, __) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: isProcessing ? const Padding(padding: EdgeInsets.only(bottom: 8.0), child: TypingBubble()) : const SizedBox.shrink(),
                      );
                    },
                  ),

                  // Typing indicator or stop button
                  ValueListenableBuilder<bool>(
                    valueListenable: _viewModel.isProcessing,
                    builder: (_, isProcessing, __) {
                      return InputBar(
                        onStop: _stop,
                        isProcessing: isProcessing,
                        controller: _textController,
                        onSend: _send,
                        hintText: l10n.hintTypeMessage,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
