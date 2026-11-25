import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Opens the device camera and converts the captured photo to a PlatformFile
/// so it can follow the existing multi-file upload pipeline.
Future<PlatformFile?> captureTaskPhoto({required String namePrefix}) async {
  final captured = await ImagePicker().pickImage(
    source: ImageSource.camera,
    imageQuality: 82,
    maxWidth: 1920,
    maxHeight: 1920,
  );
  if (captured == null) return null;

  final bytes = await captured.readAsBytes();
  if (bytes.isEmpty) {
    throw Exception('Foto dari kamera kosong atau tidak dapat dibaca.');
  }

  // image_picker camera output is JPEG on supported mobile implementations.
  // Use a predictable .jpg name because Laravel validates file extensions.
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final fileName = '${namePrefix}_$timestamp.jpg';

  return PlatformFile(name: fileName, size: bytes.length, bytes: bytes);
}
