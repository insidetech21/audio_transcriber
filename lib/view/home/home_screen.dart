import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/audio_viewmodel.dart';
import '../detail/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  Timer? _timer;
  int _recordSeconds = 0;

  final AudioPlayer _player = AudioPlayer();
  String? _currentlyPlayingPath;
  bool _manuallyPaused = false;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _recordSeconds = 0;
  }

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback(String filePath) async {
    final isSameFile = _currentlyPlayingPath == filePath;

    if (isSameFile && _player.playing) {
      // Pause immediately
      setState(() => _manuallyPaused = true);
      await _player.pause();
    } else {
      // Play new or resume
      await _player.stop();
      await _player.setFilePath(filePath);
      await _player.play();

      setState(() {
        _currentlyPlayingPath = filePath;
        _manuallyPaused = false;
      });

      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _currentlyPlayingPath = null;
            _manuallyPaused = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioVM = Provider.of<AudioViewModel>(context);
    final filtered = audioVM.recordings.where((rec) {
      return rec.fileName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (rec.transcript ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Recordings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recordings...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Text(
                audioVM.isRecording ? 'Recording...' : 'No recordings found',
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final rec = filtered[index];
                final isCurrent = _currentlyPlayingPath == rec.filePath;

                final durationText = rec.duration != null
                    ? "${rec.duration!.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(rec.duration!.inSeconds.remainder(60)).toString().padLeft(2, '0')}"
                    : "--:--";

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final playing = playerState?.playing ?? false;
                      final isPlaying =
                          isCurrent && playing && !_manuallyPaused;

                      return ListTile(
                        leading: IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            size: 36,
                            color: isPlaying
                                ? Colors.redAccent
                                : Colors.blueAccent,
                          ),
                          onPressed: () => _togglePlayback(rec.filePath),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                rec.fileName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (rec.isUploaded)
                              const Icon(
                                Icons.cloud_done,
                                color: Colors.green,
                                size: 20,
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${rec.transcript?.isNotEmpty == true ? rec.transcript! : 'No transcript yet'} • $durationText',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(recording: rec),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (audioVM.isRecording) {
            await audioVM.stopRecording();
            stopTimer();
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Recording saved!')));
            }
          } else {
            await audioVM.startRecording();
            startTimer();
          }
        },
        backgroundColor: audioVM.isRecording ? Colors.red : Colors.blue,
        icon: Icon(audioVM.isRecording ? Icons.stop : Icons.mic),
        label: Text(
          audioVM.isRecording ? formatDuration(_recordSeconds) : 'Record',
        ),
      ),
    );
  }
}
