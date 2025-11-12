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
}
