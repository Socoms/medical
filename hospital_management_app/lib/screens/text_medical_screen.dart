import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

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
  int _currentQuestionIndex = 0;
  
  // 사용자 증상 정보 저장
  final Map<String, String> _userSymptoms = {
    'painArea': '',
    'symptoms': '',
    'duration': '',
    'history': '',
    'otherConditions': '',
  };
  
  // 현재 위치 정보
  Position? _currentPosition;
  String? _locationInput;
  bool _askingForLocation = false;
  
  // 언어 설정 - 현재는 'ko'(한국어), 나중에 'en'(영어)으로 변경 가능
  String _currentLanguage = 'ko';
  
  // 다국어 지원을 위한 텍스트 맵
  final Map<String, Map<String, String>> _localization = {
    'ko': {
      'appTitle': 'AI 의료 도우미',
      'messageHint': '메시지를 입력하세요',
      'errorMessage': '죄송합니다. 요청을 처리하는 데 문제가 발생했습니다. 다시 시도해 주세요.',
      'invalidResponse': '죄송합니다만, 질문에 맞는 답변을 부탁드립니다.',
      'locationPermission': '가까운 병원을 찾기 위해 위치 권한이 필요합니다.',
      'useCurrentLocation': '현재 위치 사용하기',
      'enterLocation': '위치 직접 입력하기',
      'locationQuestion': '가까운 병원을 찾을 위치를 알려주세요. 구나 동 이름을 입력해주세요. (예: 강남구, 역삼동)',
      'findingHospitals': '해당 지역의 병원을 찾고 있습니다...',
    },
    'en': {
      'appTitle': 'AI Medical Assistant',
      'messageHint': 'Enter your message',
      'errorMessage': 'I apologize, but I\'m having trouble processing your request. Please try again.',
      'invalidResponse': 'I\'m sorry, but please provide an answer relevant to the question.',
      'locationPermission': 'Location permission is needed to find nearby hospitals.',
      'useCurrentLocation': 'Use current location',
      'enterLocation': 'Enter location manually',
      'locationQuestion': 'Please let me know where to find hospitals near you. Enter district or neighborhood name.',
      'findingHospitals': 'Finding hospitals in the area...',
    }
  };
  
  // 질문 다국어 지원
  final Map<String, List<String>> _questions = {
    'ko': [
      '안녕하세요! 의료 AI 도우미입니다. 먼저 어디가 아프신지 알려주세요.',
      '어떤 증상을 경험하고 계신가요? 자세히 설명해 주세요.',
      '증상이 얼마나 지속되었나요? (며칠, 몇 주 등)',
      '과거에 비슷한 질환을 겪은 적이 있으신가요?',
      '현재 다른 질병이나 건강 상태가 있으신가요?'
    ],
    'en': [
      'Hello! I\'m your AI Medical Assistant. Please tell me where you are experiencing pain.',
      'What symptoms are you experiencing? Please describe in detail.',
      'How long have you been experiencing these symptoms? (days, weeks, etc.)',
      'Have you experienced similar conditions in the past?',
      'Do you have any other current medical conditions or health issues?'
    ]
  };
  
  // AI 시스템 메시지 다국어 지원
  final Map<String, String> _aiSystemMessages = {
    'ko': '''당신은 한국어로 대화하는 AI 의료 보조원입니다. 역할은 다음과 같습니다:
    1. 증상에 대한 가능한 원인 분석하기
    2. 진단 제안 및 어떤 병원(내과, 외과, 정형외과 등)을 방문해야 하는지 안내
    3. 가까운 병원을 찾을 수 있도록 도움 제공
    4. 전문적이지만 공감적인 톤 유지
    5. 간결하면서도 유익한 응답 제공
    6. 사용자가 관련 없는 답변을 할 경우 원래 질문으로 돌아가도록 안내
    
    사용자의 증상과 제공된 정보를 바탕으로 진단하고, 적절한 병원 과를 추천하세요.
    마지막에는 항상 "가까운 병원을 찾아드릴까요?"라고 물어보세요.''',
    
    'en': '''You are an AI Medical Assistant. Your role is to:
    1. Analyze possible causes based on symptoms
    2. Suggest diagnoses and recommend which type of hospital (internal medicine, surgery, orthopedics, etc.) to visit
    3. Provide assistance in finding nearby hospitals
    4. Maintain a professional but empathetic tone
    5. Keep responses concise but informative
    6. Guide users back to the original question if they provide irrelevant responses
    
    Diagnose based on the user's symptoms and provided information, and recommend appropriate medical departments.
    Always end with "Would you like me to find nearby hospitals for you?"'''
  };
  
  // 부적절한 응답 필터링을 위한 키워드
  final Map<String, List<String>> _invalidKeywords = {
    'ko': ['사랑해', '사귀자', '밥은 먹었어?', '안녕'],
    'en': ['love you', 'date me', 'have you eaten?', 'hi']
  };

  // 각 언어별 현재 텍스트 맵을 반환하는 getter
  Map<String, String> get _localizedText => _localization[_currentLanguage]!;
  // 각 언어별 질문 목록을 반환하는 getter
  List<String> get _localizedQuestions => _questions[_currentLanguage]!;
  // 각 언어별 AI 시스템 메시지를 반환하는 getter
  String get _aiSystemMessage => _aiSystemMessages[_currentLanguage]!;
  // 각 언어별 부적절한 응답 키워드 목록을 반환하는 getter
  List<String> get _invalidResponseKeywords => _invalidKeywords[_currentLanguage]!;

  @override
  void initState() {
    super.initState();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    setState(() {
      _messages.add({
        'text': _localizedQuestions[0],
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
    
    // 위치 입력 모드인 경우
    if (_askingForLocation) {
      _handleLocationInput(text);
      return;
    }
    
    if (_currentQuestionIndex < _localizedQuestions.length - 1) {
      _processInitialQuestions(text);
    } else {
      _generateAIResponse(text);
    }
    
    _scrollToBottom();
  }
  
  void _processInitialQuestions(String userMessage) {
    // 관련 없는 답변인지 확인하는 간단한 필터링
    final bool isInvalidResponse = _invalidResponseKeywords.any((invalid) => 
      userMessage.toLowerCase().contains(invalid.toLowerCase()));
      
    if (isInvalidResponse) {
      setState(() {
        _messages.add({
          'text': '${_localizedText['invalidResponse']} ${_localizedQuestions[_currentQuestionIndex]}',
          'isUser': false,
        });
        _isLoading = false;
      });
    } else {
      // 사용자 답변 저장
      _saveUserSymptomData(userMessage);
      
      _currentQuestionIndex++;
      setState(() {
        _messages.add({
          'text': _localizedQuestions[_currentQuestionIndex],
          'isUser': false,
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }
  
  // 사용자 증상 데이터 저장
  void _saveUserSymptomData(String message) {
    switch(_currentQuestionIndex) {
      case 0: // 아픈 부위
        _userSymptoms['painArea'] = message;
        break;
      case 1: // 증상
        _userSymptoms['symptoms'] = message;
        break;
      case 2: // 지속 기간
        _userSymptoms['duration'] = message;
        break;
      case 3: // 과거 병력
        _userSymptoms['history'] = message;
        break;
      case 4: // 기타 질병
        _userSymptoms['otherConditions'] = message;
        break;
    }
  }

  Future<void> _generateAIResponse(String userMessage) async {
    // 만약 '병원 찾아줘', '병원 검색' 등의 메시지가 있으면 위치 요청으로 전환
    if (_checkIfHospitalSearchRequested(userMessage)) {
      _askForLocation();
      return;
    }
    
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
              'content': _aiSystemMessage
            },
            // 사용자 증상 정보 추가
            {
              'role': 'system',
              'content': '''사용자의 증상 정보:
              - 아픈 부위: ${_userSymptoms['painArea']}
              - 증상: ${_userSymptoms['symptoms']} 
              - 지속 기간: ${_userSymptoms['duration']}
              - 과거 병력: ${_userSymptoms['history']}
              - 기타 질병: ${_userSymptoms['otherConditions']}
              
              위 정보를 바탕으로 가능한 진단과 어떤 진료과를 방문해야 할지 추천해주세요.
              진료과 추천시 구체적으로 내과, 외과, 정형외과, 이비인후과, 피부과, 안과, 비뇨기과, 산부인과 등 추천해주세요.'''
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
          'text': _localizedText['errorMessage'] ?? 'Error occurred',
          'isUser': false,
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }
  
  // 병원 검색 요청인지 확인
  bool _checkIfHospitalSearchRequested(String message) {
    List<String> hospitalSearchKeywords = _currentLanguage == 'ko' 
        ? ['병원', '찾아', '검색', '의원', '어디로', '가까운', '주변'] 
        : ['hospital', 'find', 'search', 'clinic', 'where', 'nearby'];
    
    return hospitalSearchKeywords.any((keyword) => 
      message.toLowerCase().contains(keyword.toLowerCase()));
  }
  
  // 위치 정보 요청
  void _askForLocation() {
    setState(() {
      _askingForLocation = true;
      _isLoading = false;
      _messages.add({
        'text': _localizedText['locationQuestion'] ?? '가까운 병원을 찾을 위치를 알려주세요.',
        'isUser': false,
        'isLocationRequest': true,
      });
    });
    
    _scrollToBottom();
    
    // 위치 권한 확인
    _checkLocationPermission();
  }
  
  // 위치 권한 확인
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화된 경우 처리
      return;
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한이 거부된 경우 처리
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우 처리
      return;
    }
    
    // 권한이 있으면 현재 위치 가져오기
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      // 위치를 가져오는데 실패한 경우
    }
  }
  
  // 위치 입력 처리
  void _handleLocationInput(String locationText) {
    setState(() {
      _locationInput = locationText;
      _askingForLocation = false;
      _isLoading = true;
    });
    
    _searchHospitals();
  }
  
  // 병원 검색
  Future<void> _searchHospitals() async {
    setState(() {
      _messages.add({
        'text': _localizedText['findingHospitals'] ?? 'Finding hospitals...',
        'isUser': false,
      });
    });
    
    // 여기서는 실제 API 연동 대신 AI에 병원 정보 요청
    try {
      String locationString = '';
      
      if (_currentPosition != null) {
        locationString = '위도: ${_currentPosition!.latitude}, 경도: ${_currentPosition!.longitude}';
      } else if (_locationInput != null && _locationInput!.isNotEmpty) {
        locationString = _locationInput!;
      } else {
        locationString = '위치 정보 없음';
      }
      
      final medicalDept = _extractMedicalDepartment(_messages);
      
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
              'content': '''당신은 의료 도우미입니다. 사용자가 제공한 위치 주변의 병원 정보를 제공해주세요.
              한국의 병원 이름과 위치를 알려드리되, 만약 정확한 정보를 모르는 경우에는 일반적인 병원 검색 방법을 안내해 주세요.
              
              사용자의 증상을 바탕으로 방문하면 좋을 진료과는 ${medicalDept}입니다.
              해당 진료과가 있는 병원 또는 의원을 중심으로 안내해 주세요.'''
            },
            {
              'role': 'user',
              'content': '${locationString} 주변의 ${medicalDept} 병원을 찾아주세요.'
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
          'text': _localizedText['errorMessage'] ?? 'Error occurred',
          'isUser': false,
        });
        _isLoading = false;
      });
    }
  }
  
  // 메시지에서 진료과 추출
  String _extractMedicalDepartment(List<Map<String, dynamic>> messages) {
    // 최근 AI 메시지에서 진료과 키워드 추출
    for (int i = messages.length - 1; i >= 0; i--) {
      if (!messages[i]['isUser']) {
        String message = messages[i]['text'];
        
        List<String> departments = [
          '내과', '외과', '정형외과', '신경과', '신경외과', '소아과', 
          '이비인후과', '피부과', '안과', '비뇨기과', '산부인과', '정신과',
          '재활의학과', '가정의학과', '치과', '한의원'
        ];
        
        for (String dept in departments) {
          if (message.contains(dept)) {
            return dept;
          }
        }
        
        // 영어인 경우
        List<String> engDepartments = [
          'internal medicine', 'surgery', 'orthopedics', 'neurology', 
          'neurosurgery', 'pediatrics', 'otorhinolaryngology', 'dermatology', 
          'ophthalmology', 'urology', 'obstetrics and gynecology', 'psychiatry',
          'rehabilitation medicine', 'family medicine', 'dental', 'oriental medicine'
        ];
        
        for (String dept in engDepartments) {
          if (message.toLowerCase().contains(dept)) {
            return dept;
          }
        }
      }
    }
    
    // 기본값
    return _currentLanguage == 'ko' ? '내과' : 'internal medicine';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localizedText['appTitle'] ?? 'AI Medical Assistant'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // 개발 중에만 사용할 언어 전환 버튼
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              setState(() {
                // 언어 전환 (ko <-> en)
                _currentLanguage = _currentLanguage == 'ko' ? 'en' : 'ko';
                // 앱 문구들이 바로 변경되지만, 대화는 유지됩니다.
              });
            },
          )
        ],
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
                final isLocationRequest = message['isLocationRequest'] as bool? ?? false;

                if (isInitial) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localizedText['appTitle'] ?? 'AI Medical Assistant',
                        style: const TextStyle(
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
                
                if (isLocationRequest && _currentPosition != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMessageBubble(message, isUser),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.my_location),
                              label: Text(_localizedText['useCurrentLocation'] ?? 'Use current location'),
                              onPressed: () {
                                setState(() {
                                  _askingForLocation = false;
                                  _isLoading = true;
                                });
                                _searchHospitals();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.edit_location),
                              label: Text(_localizedText['enterLocation'] ?? 'Enter location'),
                              onPressed: null, // 이미 텍스트 입력 필드가 활성화되어 있으므로 비활성화
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.purple,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                      hintText: _askingForLocation 
                          ? (_currentLanguage == 'ko' ? '위치를 입력하세요 (예: 강남구)' : 'Enter location')
                          : (_localizedText['messageHint'] ?? 'Enter your message'),
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