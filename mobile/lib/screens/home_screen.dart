import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String _text = '';
  bool _loading = false;
  String _lang = 'eng';
  String _error = '';

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _text = '';
        _error = '';
      });
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;
    setState(() => _loading = true);
    try {
      final text = await ApiService.extractText(_image!, _lang);
      setState(() => _text = text);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OCR App')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<String>(
                value: _lang,
                onChanged: (v) => setState(() => _lang = v!),
                items: [
                  DropdownMenuItem(value: 'eng', child: Text('English')),
                  DropdownMenuItem(value: 'amh', child: Text('Amharic')),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text('Choose Image'),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('Capture Photo'),
              ),
              if (_image != null) Image.file(_image!, height: 200),
              if (_loading) CircularProgressIndicator(),
              if (_error.isNotEmpty) Text(_error, style: TextStyle(color: Colors.red)),
              if (_text.isNotEmpty) ...[
                TextField(
                  readOnly: true,
                  maxLines: 10,
                  controller: TextEditingController(text: _text),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Clipboard.setData(ClipboardData(text: _text)),
                      child: Text('Copy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Save to file or share
                      },
                      child: Text('Download'),
                    ),
                  ],
                ),
              ],
              if (_image != null && !_loading)
                ElevatedButton(
                  onPressed: _processImage,
                  child: Text('Extract Text'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}