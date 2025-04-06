import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'package:medical/main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _privacyConsent = false;
  bool _medicalConsent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showConsentDetails(String title, String content) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
      );
      return;
    }

    if (!_privacyConsent || !_medicalConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 약관에 동의해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.signUp(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 가입된 이메일입니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 중 오류가 발생했습니다')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              // 개인정보 수집 동의
              Row(
                children: [
                  Checkbox(
                    value: _privacyConsent,
                    onChanged: (value) => setState(() => _privacyConsent = value!),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showConsentDetails(
                        '개인정보 수집 및 이용 동의',
                        '''
1. 수집하는 개인정보 항목
- 필수항목: 이름, 이메일 주소
- 선택항목: 없음

2. 개인정보의 수집 및 이용목적
- 서비스 제공 및 회원관리
- 고지사항 전달
- 서비스 이용 통계 및 분석

3. 개인정보의 보유 및 이용기간
- 회원 탈퇴 시까지
- 관계법령에 따른 보존기간

4. 동의를 거부할 권리 및 동의 거부에 따른 불이익
- 개인정보 수집 및 이용에 대한 동의를 거부할 수 있으나, 
  이 경우 회원가입이 제한됩니다.
''',
                      ),
                      child: const Text(
                        '[필수] 개인정보 수집 및 이용 동의',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
              
              // 의료기록 수집 동의
              Row(
                children: [
                  Checkbox(
                    value: _medicalConsent,
                    onChanged: (value) => setState(() => _medicalConsent = value!),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showConsentDetails(
                        '의료기록 수집 및 열람 동의',
                        '''
1. 수집하는 의료정보 항목
- 진료기록
- 처방전 정보
- 검사결과
- 의료영상자료

2. 의료정보의 수집 및 이용목적
- 원활한 의료서비스 제공
- 의료기관 간 진료정보 공유
- 응급상황 대응
- 의료서비스 품질 향상

3. 의료정보의 보유 및 이용기간
- 의료법에 따른 보존기간
- 회원 탈퇴 후 5년

4. 동의를 거부할 권리 및 동의 거부에 따른 불이익
- 의료정보 수집 및 이용에 대한 동의를 거부할 수 있으나,
  이 경우 일부 서비스 이용이 제한될 수 있습니다.
''',
                      ),
                      child: const Text(
                        '[필수] 의료기록 수집 및 열람 동의',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 