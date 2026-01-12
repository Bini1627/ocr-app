import 'package:image_picker/image_picker.dart'; // Already imported
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'https://ocr-backend-7uq2.onrender.com';

  static Future<String> extractText(XFile imageFile, String lang) async {
    final uri = Uri.parse('$baseUrl/ocr');
    final request = http.MultipartRequest('POST', uri);

    // Read bytes from XFile
    final bytes = await imageFile.readAsBytes();

    // Create MultipartFile from bytes
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: imageFile.name,
      contentType: MediaType('image', getImageExtension(imageFile.name)),
    );

    request.files.add(multipartFile);
    request.fields['lang'] = lang;

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody);
      return json['text'];
    } else {
      final errorBody = await response.stream.bytesToString();
      throw Exception('OCR failed: $errorBody');
    }
  }

  static String getImageExtension(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    if (ext == 'jpg') return 'jpeg';
    return ext;
  }
}