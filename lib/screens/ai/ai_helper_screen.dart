import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class AiHelperScreen extends StatefulWidget {
  final String? prefilledQuery;
  const AiHelperScreen({super.key, this.prefilledQuery});

  @override
  State<AiHelperScreen> createState() => _AiHelperScreenState();
}

class _AiHelperScreenState extends State<AiHelperScreen> {
  final _textController = TextEditingController();
  String _aiResponse = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledQuery != null) {
      _textController.text = widget.prefilledQuery!;
      _callGemini();
    } else {
      _aiResponse = """
### 👋 Halo, saya **LabKom Asisten**!
Saya siap membantu Anda terkait alat laboratorium.
""";
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // --- PEMANGGILAN API GEMINI ---
  Future<void> _callGemini() async {
    if (_textController.text.isEmpty) return;
    final userQuery = _textController.text.trim();
    _textController.clear();

    setState(() {
      _isLoading = true;
      _aiResponse = "";
    });

    final apiKey = "AIzaSyCwAEV82O6PIb2ZJ7fP0hkk_F_G1Rrh0HQ";
    final apiUrl = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey",
    );

    final systemPrompt = """
Anda adalah asisten virtual untuk Lab Komputer Politeknik Negeri Malang bernama **LabKom Asisten**.
Tugas Anda adalah membantu mahasiswa dalam peminjaman alat, menjelaskan fungsi alat,
dan memberi saran seputar proyek teknologi. Jawab dengan **bahasa Indonesia yang sopan dan ringkas.**

Daftar alat yang tersedia (simulasi):
- Proyektor InFocus
- Arduino Uno R3 Kit
- Kabel VGA
- Laptop Dell
Gunakan markdown untuk menampilkan hasil dengan jelas.
""";

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "$systemPrompt\n\nPertanyaan pengguna: $userQuery}"},
          ],
        },
      ],
    });

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final text =
            result["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
            "Tidak ada respons dari AI.";
        setState(() {
          _aiResponse = text;
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _aiResponse = "❌ Terjadi kesalahan: ${error['error']['message']}";
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse =
            "⚠️ Gagal terhubung ke server AI. Pastikan internet aktif.\n\nDetail: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asisten AI LabKom"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[100],
              width: double.infinity,
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: colorMaroon),
                          SizedBox(height: 16),
                          Text("AI sedang berpikir..."),
                        ],
                      ),
                    )
                  : Markdown(
                      data: _aiResponse,
                      selectable: true,
                      padding: const EdgeInsets.all(16.0),
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16, height: 1.5),
                        h2: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 2,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        code: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Ketik pertanyaan Anda...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: _isLoading ? null : (_) => _callGemini(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _callGemini,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: colorMaroon,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
