import 'package:flutter/material.dart';
import 'package:hack_the_future_starter/features/chat/models/chat_message.dart';
import 'package:hack_the_future_starter/l10n/app_localizations.dart';
import 'package:genui/genui.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.model, required this.host, required this.l10n});

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
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
                  child: surfaceId == null
                      ? Text(model.text ?? '', style: TextStyle(color: isError ? Colors.white : theme.colorScheme.onSurface))
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
