import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/whiteboard_state.dart';

class StorageService {
  static const String _fileNamePrefix = 'whiteboard_';
  static const String _fileExtension = '.json';

  Future<Directory> get _documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  Future<Directory?> get _externalDirectory async {
    try {
      return await getExternalStorageDirectory();
    } catch (e) {
      return null;
    }
  }

  String _generateFileName() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return '$_fileNamePrefix$timestamp$_fileExtension';
  }

  Future<String> saveWhiteboard(WhiteboardState state) async {
    try {
      final directory = await _documentsDirectory;
      final fileName = _generateFileName();
      final file = File('${directory.path}/$fileName');

      final jsonData = state.toJson();
      await file.writeAsString(jsonEncode(jsonData));

      return fileName;
    } catch (e) {
      throw Exception('Failed to save whiteboard: $e');
    }
  }

  Future<WhiteboardState> loadWhiteboard(String fileName) async {
    try {
      final directory = await _documentsDirectory;
      final file = File('${directory.path}/$fileName');

      if (!await file.exists()) {
        throw Exception('File not found: $fileName');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return WhiteboardState.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load whiteboard: $e');
    }
  }

  Future<List<String>> getSavedWhiteboards() async {
    try {
      final directory = await _documentsDirectory;
      final files = directory.listSync();

      return files
          .whereType<File>()
          .where(
            (file) =>
                file.path.contains(_fileNamePrefix) &&
                file.path.endsWith(_fileExtension),
          )
          .map((file) => file.path.split('/').last)
          .toList()
        ..sort((a, b) => b.compareTo(a));
    } catch (e) {
      throw Exception('Failed to get saved whiteboards: $e');
    }
  }

  Future<void> deleteWhiteboard(String fileName) async {
    try {
      final directory = await _documentsDirectory;
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete whiteboard: $e');
    }
  }

  Future<String> exportAsImage(String fileName, List<int> imageBytes) async {
    try {
      final directory = await _documentsDirectory;
      final imageFileName = fileName.replaceAll(_fileExtension, '.png');
      final file = File('${directory.path}/$imageFileName');

      await file.writeAsBytes(imageBytes);

      return imageFileName;
    } catch (e) {
      throw Exception('Failed to export image: $e');
    }
  }

  Future<Map<String, dynamic>> getFileInfo(String fileName) async {
    try {
      final directory = await _documentsDirectory;
      final file = File('${directory.path}/$fileName');

      if (!await file.exists()) {
        throw Exception('File not found: $fileName');
      }

      final stat = await file.stat();

      return {
        'name': fileName,
        'size': stat.size,
        'created': stat.changed,
        'modified': stat.modified,
      };
    } catch (e) {
      throw Exception('Failed to get file info: $e');
    }
  }
}
