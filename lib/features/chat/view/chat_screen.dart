import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hack_the_future_starter/l10n/app_localizations.dart';
import '../models/chat_message.dart';
import '../viewmodel/chat_view_model.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🛑 Generation stopped.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarTitle),
        actions: [],
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
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      itemCount: _viewModel.messages.length,
                      itemBuilder: (_, i) {
                        final m = _viewModel.messages[i];
                        return _ChatBubble(
                          model: m,
                          host: _viewModel.host,
                          l10n: l10n,
                        );
                      },
                    ),
                  ),

                  // Typing indicator or stop button
                  ValueListenableBuilder<bool>(
                    valueListenable: _viewModel.isProcessing,
                    builder: (_, isProcessing, __) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: isProcessing
                            ? const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: _TypingBubble(),
                        )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),


                  // Typing indicator or stop button
                  ValueListenableBuilder<bool>(
                    valueListenable: _viewModel.isProcessing,
                    builder: (_, isProcessing, __) {
                      return _InputBar(
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

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.hintText,
    required this.isProcessing,
    required this.onStop,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;
  final bool isProcessing;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            if(isProcessing)
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                tooltip: "Stop generation",
                onPressed: onStop,
              )
            else
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.blueAccent),
                onPressed: onSend,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.model,
    required this.host,
    required this.l10n,
  });

  final ChatMessageModel model;
  final GenUiHost host;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceId = model.surfaceId;
    final isUser = model.isUser;
    final isError = model.isError;

    final bgColor = isError
        ? Colors.red.shade300
        : isUser
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surface;

    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: surfaceId == null
                      ? Text(
                    model.text ?? '',
                    style: TextStyle(
                      color: isError
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  )
                      : GenUiSurface(host: host, surfaceId: surfaceId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = _controller.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final opacity =
                (t * 3 - i).clamp(0, 1) < 0.5 ? 1.0 : 0.3; // wave pulse
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Opacity(
                    opacity: opacity,
                    child: const CircleAvatar(radius: 4, backgroundColor: Colors.grey),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
