import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static Future<File?> compressImage(File file, {int quality = 85}) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.absolute.path, 
      '${path.basenameWithoutExtension(file.path)}_compressed.jpg'
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: 1080,
      minHeight: 1080,
    );

    if (result != null) {
      return File(result.path);
    }
    return null;
  }

  static Future<List<File>> compressImages(List<File> files, {int quality = 85}) async {
    final compressedFiles = <File>[];
    for (final file in files) {
      final compressed = await compressImage(file, quality: quality);
      if (compressed != null) {
        compressedFiles.add(compressed);
      }
    }
    return compressedFiles;
  }
}
