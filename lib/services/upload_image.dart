import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:new_application_api/config.dart';

class UploadImage {
  final String baseUrl = '${AppConfig.baseUrl}/editor/image/upload';

  Future<String> uploadImage(File imageFile, String token) async {
    final uri = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: path.basename(imageFile.path),
    ));

    request.headers['Authorization'] = 'Bearer $token';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      throw Exception('Error al subir la imagen: ${response.body}');
    }
  }
}
