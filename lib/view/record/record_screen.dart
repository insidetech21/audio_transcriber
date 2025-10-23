import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/audio_viewmodel.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioVM = Provider.of<AudioViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Record Audio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(audioVM.durationText, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(audioVM.isRecording ? Icons.stop : Icons.mic),
              label: Text(audioVM.isRecording ? 'Stop' : 'Record'),
              onPressed: () async {
                if (audioVM.isRecording) {
                  await audioVM.stopRecording();
                } else {
                  await audioVM.startRecording();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
