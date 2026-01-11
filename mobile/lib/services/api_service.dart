import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost

  static Future<String> extractText(File imageFile, String lang) async {
    final uri = Uri.parse('$baseUrl/ocr');
    final request = http.MultipartRequest('POST', uri);
    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);
    request.fields['lang'] = lang;

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody);
      return json['text'];
    } else {
      final error = await response.stream.bytesToString();
      throw Exception('OCR failed: $error');
    }
  }
}