import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';

class TranscriptionViewModel with ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isLiveTranscribing = false;
  String _liveTranscript = '';

  bool get isLiveTranscribing => _isLiveTranscribing;

  String get liveTranscript => _liveTranscript;

  /// Initialize the speech recognizer
  Future<void> initSpeech() async {
    bool available = await _speech.initialize(
      onError: (val) {
        debugPrint('Speech recognition error: $val');
      },
      onStatus: (status) {
        debugPrint('Speech recognition status: $status');
      },
    );
    if (!available) {
      _isLiveTranscribing = false;
      notifyListeners();
    }
  }

  /// Start listening to the microphone for live transcription
  void startListening() {
    if (!_speech.isAvailable) return;

    _liveTranscript = '';
    _isLiveTranscribing = true;
    notifyListeners();

    _speech.listen(
      onResult: (val) {
        _liveTranscript = val.recognizedWords;
        notifyListeners();
      },
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  /// Stop listening to the microphone
  void stopListening() {
    if (!_isLiveTranscribing) return;

    _speech.stop();
    _isLiveTranscribing = false;
    notifyListeners();
  }

  /// Transcribe an audio file (mock or real API)
  Future<String> transcribeAudio(File audioFile) async {
    // Mock transcription for now
    await Future.delayed(const Duration(seconds: 2));
    return "Mock transcription for ${audioFile.path.split('/').last}";
  }
}

// import 'dart:io';
// import 'package:flutter/foundation.dart';
//
// class TranscriptionViewModel extends ChangeNotifier {
//   bool isTranscribing = false;
//   String? lastTranscript;
//
//   /// Mock transcription: returns a fake text after a short delay
//   Future<String> transcribeAudio(File audioFile) async {
//     isTranscribing = true;
//     notifyListeners();
//
//     try {
//       // Simulate network/API delay
//       await Future.delayed(const Duration(seconds: 2));
//
//       // Generate a fake transcript based on file name
//       final transcript =
//           "Mock transcript for ${audioFile.path.split('/').last}";
//       lastTranscript = transcript;
//
//       return transcript;
//     } catch (e) {
//       return "Transcription failed: $e";
//     } finally {
//       isTranscribing = false;
//       notifyListeners();
//     }
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
// class TranscriptionViewModel extends ChangeNotifier {
//   bool isTranscribing = false;
//   String? lastTranscript;
//
//   Future<String> transcribeAudio(File audioFile) async {
//     isTranscribing = true;
//     notifyListeners();
//
//     try {
//       final apiKey = "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"; // 🔑 Replace this
//       final url = Uri.parse("https://api.openai.com/v1/audio/transcriptions");
//
//       final request = http.MultipartRequest("POST", url)
//         ..headers['Authorization'] = "Bearer $apiKey"
//         ..fields['model'] = "whisper-1"
//         ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));
//
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//
//       if (response.statusCode == 200) {
//         final decoded = json.decode(responseBody);
//         final text = decoded['text'] ?? '';
//         lastTranscript = text;
//         return text;
//       } else {
//         throw Exception("Transcription failed: $responseBody");
//       }
//     } catch (e) {
//       debugPrint("Error during transcription: $e");
//       return "Transcription failed: $e";
//     } finally {
//       isTranscribing = false;
//       notifyListeners();
//     }
//   }
// }
