# 🎙️ Audio Transcriber Demo (Flutter)

## 🧭 Overview
A Flutter demo app that allows users to **record audio**, **transcribe it into text**, and **manage recordings locally**.  
Users can view past recordings, play or pause audio, edit transcripts, and export them as `.txt` files.  

This project demonstrates clean architecture, local state management with `Provider`, and integration with speech-to-text APIs.

---

## 🚀 Features

### ✅ Core Requirements
- **Record Audio** – Start/stop recording with microphone permission and live duration display.  
- **Transcribe Audio** – Converts recorded audio to text using a speech-to-text API.  
- **List & View Recordings** – Displays all saved recordings with filename, duration, and transcript preview.  
- **Detail Screen** – View playback controls and full transcript with edit/save support.  
- **Error & Progress Handling** – Snackbars and loaders for upload/transcribe states.

### 💡 Bonus Features
- 🔍 **Search/Filter** – Filter recordings by name or transcript content.  
- ✏️ **Edit & Save** – Edit transcripts inline and save changes locally.  
- 📋 **Copy/Export** – Copy transcript to clipboard or export as `.txt`.  
- 🎵 **Audio Player** – Play/pause individual recordings with dynamic button updates.  

---

## 🧱 Tech Stack

| Component | Package | Purpose |
|------------|----------|----------|
| 🎧 Audio Recording | `flutter_sound` / `record` | Record and save audio files |
| 🔊 Playback | `just_audio` | Local file playback and duration |
| 🧠 State Management | `provider` | ViewModel-based architecture |
| 🗂️ Storage | `path_provider` + local | Stores audio + transcript locally |
| 🗣️ Transcription | Speech-to-text API | Converts audio to text |
| 💬 UI | `Material` widgets | Modern and clean interface |

---

## 📱 App Flow
1. **Home Screen** – Start/stop recording, view list of previous recordings.  
2. **Detail Screen** – Play audio, transcribe, edit, save, copy, or export transcript.  
3. **Search Bar** – Quickly filter recordings by filename or text.

---

## 🧪 Steps to Test the App

1. Grant microphone permission when prompted.
2. Tap the Record button to start recording; tap Stop to finish.
3. The recording appears in the Home Screen list with the filename and duration.
4. Tap Play to listen to the audio.
5. Tap Transcribe to convert the audio to text.
6. Edit the transcript if needed.
7. Use the Save, Copy, or Export .txt buttons to manage the transcript.
8. Use the Search Bar to filter recordings by filename or transcript text.

---

## ⚙️ Setup Instructions
1. Clone the project:
   ```bash
   git clone https://github.com/yourusername/audio_transcriber_demo.git
