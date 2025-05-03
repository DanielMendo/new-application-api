import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';

class UploadImage {
  final String baseUrl = 'http://192.168.1.70:8000/api/editor/image/upload';

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
