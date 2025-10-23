import 'dart:convert';
import 'package:flutter/foundation.dart';

class RecordingModel {
  final String id;
  final String filePath;
  final String fileName;
  final DateTime dateTime;
  final Duration duration;
  late final String? transcript;
  final bool isUploaded;
  final String? uploadedPath;

  RecordingModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.dateTime,
    required this.duration,
    this.transcript,
    this.isUploaded = false,
    this.uploadedPath,
  });

  RecordingModel copyWith({
    String? transcript,
    bool? isUploaded,
    String? uploadedPath,
  }) {
    return RecordingModel(
      id: id,
      filePath: filePath,
      fileName: fileName,
      dateTime: dateTime,
      duration: duration,
      transcript: transcript ?? this.transcript,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadedPath: uploadedPath ?? this.uploadedPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'fileName': fileName,
    'dateTime': dateTime.toIso8601String(),
    'duration': duration.inMilliseconds,
    'transcript': transcript,
    'isUploaded': isUploaded,
    'uploadedPath': uploadedPath,
  };

  factory RecordingModel.fromJson(Map<String, dynamic> json) => RecordingModel(
    id: json['id'],
    filePath: json['filePath'],
    fileName: json['fileName'],
    dateTime: DateTime.parse(json['dateTime']),
    duration: Duration(milliseconds: json['duration']),
    transcript: json['transcript'],
    isUploaded: json['isUploaded'] ?? false,
    uploadedPath: json['uploadedPath'],
  );
}

