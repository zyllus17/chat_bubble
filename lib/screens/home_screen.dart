import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/chat_bubble.dart';
import '../widgets/dotted_line.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isMe = false;
  final List<Map<String, String>> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'message': _messageController.text,
          'sender': _isMe ? 'me' : 'them',
        });
        _messageController.clear();
      });
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              for (var message in _messages)
                pw.Column(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        message['message']!,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor(0, 0, 0, 1),
                        ),
                      ),
                    ),
                    pw.Container(
                      height: 1,
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            width: 1,
                            color: PdfColor(0, 0, 0, 0.1),
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChatBubble',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFe5ddd5),
                    const Color(0xFFdcf8c6),
                  ],
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/whatsapp_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Enter your message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<bool>(
                            value: _isMe,
                            decoration: const InputDecoration(
                              labelText: 'Sender',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: false,
                                child: Text('Them'),
                              ),
                              DropdownMenuItem(
                                value: true,
                                child: Text('Me'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _isMe = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _addMessage,
                          child: const Text('Add Message'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ChatBubble(
                              message: message['message']!,
                              isMe: message['sender'] == 'me',
                            ),
                            const DottedLine(
                              height: 1,
                              strokeWidth: 1,
                              color: Color(0xFFcccccc),
                            ),
                            if (index < _messages.length - 1 &&
                                message['sender'] != _messages[index + 1]['sender'])
                              const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _generatePDF,
              icon: const Icon(Icons.print),
              label: const Text('Export to PDF (A4)'),
            ),
          ),
        ],
      ),
    );
  }
}
