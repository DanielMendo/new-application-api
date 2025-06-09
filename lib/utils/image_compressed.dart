import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

class ImageCompressed {
  Future<XFile?> compressImage(File file) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.parent.path}/compressed_${file.path.split('/').last}',
      quality: 70,
      format: CompressFormat.jpeg,
    );
    return compressedFile;
  }
}
