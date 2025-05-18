import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = 'Translation will appear here';
  bool _isTranslating = false;
  String _sourceLanguage = 'ko';
  String _targetLanguage = 'en';
  bool _isSpeaking = false;
  
  // Google translator 인스턴스 생성
  final GoogleTranslator translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();
  
  @override
  void initState() {
    super.initState();
    _initTts();
  }
  
  void _initTts() async {
    await flutterTts.setLanguage(_targetLanguage);
    
    flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    flutterTts.setErrorHandler((message) {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> translateText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _translatedText = 'Translating...';
    });

    try {
      // translator 패키지를 사용하여 번역
      final translation = await translator.translate(
        text,
        from: _sourceLanguage,
        to: _targetLanguage,
      );
      
      setState(() {
        _translatedText = translation.text;
      });
    } catch (e) {
      setState(() {
        _translatedText = '오류 발생: $e';
      });
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }
  
  Future<void> _speak() async {
    if (_translatedText != 'Translation will appear here' && 
        _translatedText != 'Translating...' &&
        !_translatedText.startsWith('오류 발생')) {
      await flutterTts.setLanguage(_targetLanguage);
      await flutterTts.speak(_translatedText);
    }
  }
  
  Future<void> _stopSpeaking() async {
    await flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  void swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      _inputController.clear();
      _translatedText = 'Translation will appear here';
      flutterTts.setLanguage(_targetLanguage);
    });
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'ko':
        return 'Korean';
      case 'en':
        return 'English';
      case 'ja':
        return 'Japanese';
      case 'zh-cn':
        return 'Chinese';
      case 'vi':
        return 'Vietnamese';
      case 'id':
        return 'Indonesian';
      case 'th':
        return 'Thai';
      case 'de':
        return 'German';
      case 'ru':
        return 'Russian';
      case 'es':
        return 'Spanish';
      case 'it':
        return 'Italian';
      case 'fr':
        return 'French';
      default:
        return code.toUpperCase();
    }
  }

  // 언어 선택 드롭다운 위젯
  Widget _buildLanguageDropdown(String currentLanguage, Function(String?) onChanged) {
    return DropdownButton<String>(
      value: currentLanguage,
      icon: const Icon(Icons.arrow_drop_down, size: 18),
      underline: Container(
        height: 1,
        color: Colors.deepPurpleAccent,
      ),
      style: const TextStyle(fontSize: 12, color: Colors.black),
      onChanged: onChanged,
      items: <String>['ko', 'en', 'ja', 'zh-cn', 'vi', 'id', 'th', 'de', 'ru', 'es', 'it', 'fr']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(getLanguageName(value)),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Translator',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // 언어 선택 부분
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: _buildLanguageDropdown(_sourceLanguage, (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sourceLanguage = newValue;
                          });
                        }
                      }),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: swapLanguages,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildLanguageDropdown(_targetLanguage, (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _targetLanguage = newValue;
                            flutterTts.setLanguage(_targetLanguage);
                          });
                        }
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 번역 입력/출력 부분
              Expanded(
                child: Column(
                  children: [
                    // 입력 영역
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getLanguageName(_sourceLanguage),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final data = await Clipboard.getData('text/plain');
                                          if (data != null && data.text != null) {
                                            _inputController.text = data.text!;
                                            translateText();
                                          }
                                        },
                                        child: const Icon(Icons.paste, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      if (_inputController.text.isNotEmpty)
                                        InkWell(
                                          onTap: () {
                                            _inputController.clear();
                                            setState(() {
                                              _translatedText = 'Translation will appear here';
                                            });
                                          },
                                          child: const Icon(Icons.clear, size: 18),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: TextField(
                                  controller: _inputController,
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter text to translate',
                                    hintStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (_) {
                                    // Auto-translate after a delay
                                    Future.delayed(const Duration(milliseconds: 800), translateText);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // 번역 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: translateText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 40),
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isTranslating ? 'Translating...' : 'Translate',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    
                    // 출력 영역
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getLanguageName(_targetLanguage),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (_translatedText != 'Translation will appear here' && 
                                          _translatedText != 'Translating...')
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: _isSpeaking ? _stopSpeaking : _speak,
                                              child: Icon(
                                                _isSpeaking ? Icons.stop : Icons.volume_up,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () {
                                                // Copy to clipboard functionality 
                                                Clipboard.setData(ClipboardData(text: _translatedText)).then((_) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Copied to clipboard')),
                                                  );
                                                });
                                              },
                                              child: const Icon(Icons.copy, size: 18),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _translatedText,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _translatedText == 'Translation will appear here' || 
                                                 _translatedText == 'Translating...' ? 
                                                 Colors.grey : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_isTranslating)
                                const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 