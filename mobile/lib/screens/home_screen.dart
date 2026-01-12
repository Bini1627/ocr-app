import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _image;
  String _text = '';
  bool _loading = false;
  String _lang = 'eng';
  String _error = '';
  bool _copySuccess = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = picked;
        _text = '';
        _error = '';
        _copySuccess = false;
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
      setState(() => _error = 'Failed to process image. Please try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _text));
    if (!mounted) return;
    setState(() => _copySuccess = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copySuccess = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Text Extractor'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Convert images to editable text',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Language Selector
              Center(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'eng', label: Text('English')),
                    ButtonSegment(value: 'amh', label: Text('አማርኛ')),
                  ],
                  selected: {_lang},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _lang = newSelection.first);
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    selectedBackgroundColor: Colors.blue[600],
                    selectedForegroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload Area
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                      title: const Text('Upload an image'),
                      subtitle: const Text('Supports JPG, PNG, BMP'),
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
                      title: const Text('Capture photo'),
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Image Preview
              if (_image != null) ...[
                const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FutureBuilder<Uint8List>(
                      future: _image!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _processImage,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Icon(Icons.auto_fix_high_outlined),
                  label: Text(_loading ? 'Processing...' : 'Extract Text'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.red, width: 4),
                            ),
                          ),
                  child: Text(_error, style: const TextStyle(color: Colors.red)),
                ),

              // Result Section
              if (_text.isNotEmpty) ...[
                const Text('Extracted Text', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: TextField(
                    readOnly: true,
                    maxLines: 8,
                    controller: TextEditingController(text: _text),
                    style: TextStyle(
                      fontFamily: _lang == 'amh' ? 'NotoSansEthiopic' : null,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration.collapsed(hintText: ''),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _copyToClipboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _copySuccess ? Colors.green[600] : Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _copySuccess ? 'Copied!' : 'Copy Text',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Implement download
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Download', style: TextStyle(color: Colors.blue)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}