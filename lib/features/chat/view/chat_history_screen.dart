import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hack_the_future_starter/features/chat/models/chat_message.dart';
import 'package:hack_the_future_starter/features/chat/viewmodel/chat_view_model.dart';
import 'package:hack_the_future_starter/l10n/app_localizations.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key, required this.viewModel});

  final ChatViewModel viewModel;

  Future<void> _confirmClear(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(l10n.historyDialogTitle),
        content: Text(l10n.historyDialogMessage),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.historyDialogCancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.historyDialogDelete),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await viewModel.clearHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🗑️ ${l10n.historyClearedMessage}")),
      );
    }
  }


  Future<void> _confirmDeleteSingle(BuildContext context, ChatMessageModel message) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(l10n.historyDeleteSingleTitle),
        content: Text(l10n.historyDeleteSingleMessage),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.historyDialogCancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.historyDialogDelete),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await viewModel.deleteById(message.id ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🗑️ ${l10n.historyDeletedMessage}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final history = viewModel.messagesHistory;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: CupertinoNavigationBar(
              backgroundColor: theme.colorScheme.surface,
              middle: Text(
                l10n.historyTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(CupertinoIcons.clear),
              ),
              trailing: history.isEmpty
                  ? null
                  : Tooltip(
                message: l10n.historyClearTooltip,
                child: GestureDetector(
                  onTap: () => _confirmClear(context),
                  child: const Icon(
                    CupertinoIcons.trash,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0x33000000), width: 0.5),
              ),
            ),
          ),
          body: history.isEmpty
              ? _EmptyHistoryView(l10n: l10n)
              : ListView.builder(
            itemCount: history.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final message = history[index];
              final preview = message.text ??
                  (message.surfaceId != null ? "[Surface content]" : "");
              final icon = message.isUser
                  ? CupertinoIcons.person_crop_circle
                  : (message.isError
                  ? CupertinoIcons.exclamationmark_triangle
                  : CupertinoIcons.sparkles);

              return Dismissible(
                key: ValueKey(message.id ?? index),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    CupertinoIcons.delete_solid,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (_) async {
                  await _confirmDeleteSingle(context, message);
                  return false; // handled manually
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0.8,
                  color: message.isUser
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : theme.colorScheme.surface,
                  child: ListTile(
                    leading: Icon(icon, color: theme.colorScheme.primary),
                    title: Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: message.isUser
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      message.isUser ? l10n.labelYou : l10n.labelAI,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    onTap: () {
                      viewModel.send(message.text ?? '');
                      Navigator.pop(context);
                    },
                    onLongPress: () => _confirmDeleteSingle(context, message),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.time,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.historyEmptyTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.historyEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
