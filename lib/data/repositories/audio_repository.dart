import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recording_model.dart';

class AudioRepository {
  static const _recordingsKey = 'recordings';

  Future<List<RecordingModel>> loadRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_recordingsKey);
    if (data == null) return [];
    final List list = json.decode(data);
    return list.map((e) => RecordingModel.fromJson(e)).toList();
  }

  Future<void> saveRecordings(List<RecordingModel> recordings) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
    json.encode(recordings.map((r) => r.toJson()).toList());
    await prefs.setString(_recordingsKey, encoded);
  }

  Future<String> transcribeAudio(File audioFile) async {
    // TODO: Replace with real API call (OpenAI Whisper, Google Speech, etc.)
    await Future.delayed(const Duration(seconds: 2));
    return "Mock transcription for ${audioFile.path.split('/').last}";
  }
}
