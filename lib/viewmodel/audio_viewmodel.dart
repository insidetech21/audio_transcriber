import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/recording_model.dart';
import '../data/repositories/audio_repository.dart';
import 'package:uuid/uuid.dart';

class AudioViewModel with ChangeNotifier {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioRepository _repo = AudioRepository();

  bool _isRecording = false;
  String? _filePath;
  Duration _duration = Duration.zero;
  Timer? _timer;

  bool get isRecording => _isRecording;

  String? get filePath => _filePath;

  String get durationText =>
      "${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}";

  List<RecordingModel> _recordings = [];

  List<RecordingModel> get recordings => _recordings;

  Future<void> init() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await loadRecordings();
  }

  Future<void> startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    _filePath =
        '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: _filePath!);
    _isRecording = true;
    _duration = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _duration += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> stopRecording() async {
    final path = _filePath;
    await _recorder.stopRecorder();
    _timer?.cancel();
    _isRecording = false;

    if (path != null) {
      // Calculate audio duration
      final player = AudioPlayer();
      await player.setFilePath(path);
      final duration = player.duration ?? Duration.zero;
      await player.dispose();

      final newRecording = RecordingModel(
        id: const Uuid().v4(),
        filePath: path,
        fileName: File(path).uri.pathSegments.last,
        dateTime: DateTime.now(),
        duration: duration, // ✅ save duration here
      );

      _recordings.add(newRecording);
      await _repo.saveRecordings(_recordings);
    }

    notifyListeners();
  }

  /// Call this to persist the in-memory recordings list to storage.
  ///
  /// Requires your AudioRepository to expose `saveRecordings(List<RecordingModel>)`.
  Future<void> saveRecordings() async {
    try {
      await _repo.saveRecordings(_recordings);
    } catch (e) {
      // optionally handle/save error
      debugPrint('Error saving recordings: $e');
    }
  }

  /// Update the transcript for the recording identified by [filePath].
  /// This updates the model in memory, persists it, and notifies listeners.
  Future<void> updateTranscript(String filePath, String transcript) async {
    try {
      final idx = _recordings.indexWhere((r) => r.filePath == filePath);
      if (idx == -1) {
        debugPrint('Recording not found for path: $filePath');
        return;
      }

      _recordings[idx].transcript = transcript;
      await saveRecordings();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update transcript: $e');
    }
  }

  Future<void> uploadRecording(RecordingModel recording) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final uploadsDir = Directory('${appDir.path}/uploads');
      if (!await uploadsDir.exists()) {
        await uploadsDir.create(recursive: true);
      }

      final sourceFile = File(recording.filePath);
      final newFilePath = '${uploadsDir.path}/${recording.fileName}';
      await sourceFile.copy(newFilePath);

      final updatedRecording = recording.copyWith(
        isUploaded: true,
        uploadedPath: newFilePath,
      );

      // Update in local list
      final index = _recordings.indexWhere((r) => r.id == recording.id);
      if (index != -1) {
        _recordings[index] = updatedRecording;
        await _repo.saveRecordings(_recordings);
        notifyListeners();
      }

      debugPrint('Upload simulated: $newFilePath');
    } catch (e) {
      debugPrint('Upload failed: $e');
      rethrow;
    }
  }

  Future<void> loadRecordings() async {
    _recordings = await _repo.loadRecordings();
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _timer?.cancel();
    super.dispose();
  }
}
