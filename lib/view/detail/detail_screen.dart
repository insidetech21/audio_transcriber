import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../data/models/recording_model.dart';
import '../../viewmodel/audio_viewmodel.dart';
import '../../viewmodel/transcription_viewmodel.dart';

class DetailScreen extends StatefulWidget {
  final RecordingModel recording;

  const DetailScreen({super.key, required this.recording});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late AudioPlayer _player;

  late TextEditingController _transcriptController;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setFilePath(widget.recording.filePath);

    // Listen to playback state to update icon
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
          }
        });
      }
    });

    _transcriptController = TextEditingController(
      text: widget.recording.transcript ?? '',
    );

    final transVM = Provider.of<TranscriptionViewModel>(context, listen: false);

    // Update TextField in real-time while transcribing live
    transVM.addListener(() {
      if (mounted && transVM.isLiveTranscribing) {
        _transcriptController.text = transVM.liveTranscript;
        _transcriptController.selection = TextSelection.fromPosition(
          TextPosition(offset: _transcriptController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final transVM = Provider.of<TranscriptionViewModel>(context);
    final audioVM = Provider.of<AudioViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.recording.fileName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Audio playback + Duration
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final isPlaying = playerState?.playing ?? false;

                return ElevatedButton.icon(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                  label: Text(isPlaying ? 'Pause Audio' : 'Play Audio'),
                  onPressed: () async {
                    if (isPlaying) {
                      await _player.pause();
                    } else {
                      await _player.play();
                    }
                  },
                );
              },
            ),

            StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return Text(
                  'Duration: ${formatDuration(duration)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                );
              },
            ),
            const SizedBox(height: 16),

            // File transcription with error handling
            ElevatedButton.icon(
              icon: const Icon(Icons.transcribe),
              label: const Text('Transcribe Audio File'),
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transcribing audio file...')),
                  );

                  final transcript = await transVM.transcribeAudio(
                    File(widget.recording.filePath),
                  );

                  await audioVM.updateTranscript(
                    widget.recording.filePath,
                    transcript,
                  );

                  _transcriptController.text = transcript;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File transcription complete!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Live transcription controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Live'),
                  onPressed: () async {
                    await transVM.initSpeech();
                    transVM.startListening();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Live'),
                  onPressed: transVM.isLiveTranscribing
                      ? () => transVM.stopListening()
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (transVM.isLiveTranscribing)
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),

            // Editable transcript field
            Expanded(
              child: TextField(
                controller: _transcriptController,
                enabled: !transVM.isLiveTranscribing,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Transcript',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons: Save / Copy / Export
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  onPressed: () async {
                    final updatedText = _transcriptController.text;
                    await audioVM.updateTranscript(
                      widget.recording.filePath,
                      updatedText,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transcript saved')),
                      );
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _transcriptController.text),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export .txt'),
                  onPressed: () async {
                    final dir = await getApplicationDocumentsDirectory();
                    final file = File(
                      '${dir.path}/${widget.recording.fileName}.txt',
                    );
                    await file.writeAsString(_transcriptController.text);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Exported to ${file.path}')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
