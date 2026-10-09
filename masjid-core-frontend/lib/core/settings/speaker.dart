import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reads text aloud with the device's own voice (phone or browser), so it
/// costs nothing and works offline when a voice is installed.
abstract class Speaker {
  /// Completes when speaking ends or is stopped.
  Future<void> speak(String text, {required String languageCode});

  Future<void> stop();
}

class FlutterTtsSpeaker implements Speaker {
  FlutterTtsSpeaker() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;

  static const Map<String, String> _voices = <String, String>{
    'en': 'en-IN',
    'hi': 'hi-IN',
    'ur': 'ur-IN',
  };

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    if (!_ready) {
      await _tts.awaitSpeakCompletion(true);
      _ready = true;
    }
    await _tts.stop();
    // A missing voice is not an error worth showing; the device then uses
    // its default voice.
    await _tts.setLanguage(_voices[languageCode] ?? 'en-IN');
    await _tts.setSpeechRate(kIsWeb ? 0.9 : 0.45);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();
}

final speakerProvider = Provider<Speaker>((ref) => FlutterTtsSpeaker());

/// The text being read aloud right now, or null. Only one thing speaks at a
/// time, so starting a new one stops the old one and its button resets.
final readAloudControllerProvider =
    NotifierProvider<ReadAloudController, String?>(ReadAloudController.new);

class ReadAloudController extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> speak(String text, {required String languageCode}) async {
    state = text;
    try {
      await ref.read(speakerProvider).speak(text, languageCode: languageCode);
    } catch (_) {
      // No speech engine on this device; the button just resets.
    }
    if (state == text) state = null;
  }

  Future<void> stop() async {
    state = null;
    try {
      await ref.read(speakerProvider).stop();
    } catch (_) {}
  }
}
