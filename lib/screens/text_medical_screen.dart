import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TextMedicalScreen extends StatefulWidget {
  const TextMedicalScreen({super.key});

  @override
  State<TextMedicalScreen> createState() => _TextMedicalScreenState();
}

class _TextMedicalScreenState extends State<TextMedicalScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    setState(() {
      _messages.add({
        'text': 'Hello! I\'m your AI Medical Assistant. What symptoms are you experiencing?',
        'isUser': false,
        'isInitial': true,
      });
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
      });
      _isLoading = true;
    });
    _textController.clear();
    _generateAIResponse(text);
    _scrollToBottom();
  }

  Future<void> _generateAIResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an AI Medical Assistant. Your role is to:
              1. Ask relevant follow-up questions about symptoms
              2. Provide possible causes based on symptoms
              3. Suggest appropriate medical specialists when needed
              4. Give general health advice while being clear you're not replacing professional medical care
              5. Maintain a professional but empathetic tone
              6. Keep responses concise but informative'''
            },
            ..._messages.map((msg) => {
              'role': msg['isUser'] ? 'user' : 'assistant',
              'content': msg['text'],
            }),
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        setState(() {
          _messages.add({
            'text': aiResponse,
            'isUser': false,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'text': 'I apologize, but I\'m having trouble processing your request. Please try again.',
          'isUser': false,
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Medical Assistant'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;
                final isInitial = message['isInitial'] as bool? ?? false;

                if (isInitial) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Medical Assistant',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMessageBubble(message, isUser),
                    ],
                  );
                }

                return _buildMessageBubble(message, isUser);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter your symptoms',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFFF5F5F5),
              child: Image.asset(
                'assets/images/ai_avatar.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.medical_services, color: Colors.purple);
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.purple : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message['text'],
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
} 