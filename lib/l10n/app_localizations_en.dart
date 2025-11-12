// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ocean GPT';

  @override
  String get appBarTitle => 'Ocean GPT';

  @override
  String get hintTypeMessage => 'Type your message…';

  @override
  String get labelAI => 'AI';

  @override
  String get labelError => 'Error';

  @override
  String get labelYou => 'You';

  @override
  String get emptyWelcomeTitle => 'Welcome to Ocean GPT';

  @override
  String get emptyWelcomeSubtitle =>
      'Ask me about ocean temperatures, salinity, wave patterns, or create stunning visual charts of ocean data.';

  @override
  String get emptyExamplePrompt =>
      'Try asking: “Show a heat map of sea surface temperatures in the Pacific Ocean.”';

  @override
  String get emptyStopTip =>
      'Tap the stop icon to cancel generation at any time.';

  @override
  String get snackbarGenerationStopped => '🛑 Generation stopped.';

  @override
  String get historyTitle => 'Chat History';

  @override
  String get historyEmptyTitle => 'No chat history yet';

  @override
  String get historyEmptySubtitle =>
      'Your previous chats will appear here once you start using Ocean GPT.';

  @override
  String get historyDialogTitle => 'Clear chat history?';

  @override
  String get historyDialogMessage =>
      'This will permanently delete all saved messages.';

  @override
  String get historyDialogCancel => 'Cancel';

  @override
  String get historyDialogDelete => 'Delete';

  @override
  String get historyDialogOk => 'OK';

  @override
  String get historyClearedMessage => 'Chat history cleared.';

  @override
  String get historyDeleteSingleTitle => 'Delete this chat?';

  @override
  String get historyDeleteSingleMessage =>
      'This message will be permanently removed from your history.';

  @override
  String get historyDeletedMessage => 'Message deleted';

  @override
  String get historyClearTooltip => 'Clear all history';
}
