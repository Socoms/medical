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
            child: const Text('OK'),
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
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!_privacyConsent || !_medicalConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to all terms')),
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
          const SnackBar(content: Text('Email already exists')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during sign up')),
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
        title: const Text('Sign Up'),
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
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
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
                  labelText: 'Password',
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
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              // Privacy Policy Consent
              Row(
                children: [
                  Checkbox(
                    value: _privacyConsent,
                    onChanged: (value) => setState(() => _privacyConsent = value!),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showConsentDetails(
                        'Privacy Policy Consent',
                        '''
1. Personal Information We Collect
- Required: Name, Email address
- Optional: None

2. Purpose of Collection and Use
- Service provision and member management
- Notification delivery
- Service usage statistics and analysis

3. Retention and Usage Period
- Until membership withdrawal
- As required by relevant laws and regulations

4. Right to Refuse and Consequences
- You may refuse to consent to the collection and use of personal information,
  but in this case, you will not be able to register for membership.
''',
                      ),
                      child: const Text(
                        '[Required] Privacy Policy Consent',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Medical Records Consent
              Row(
                children: [
                  Checkbox(
                    value: _medicalConsent,
                    onChanged: (value) => setState(() => _medicalConsent = value!),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showConsentDetails(
                        'Medical Records Consent',
                        '''
1. Medical Information We Collect
- Medical records
- Prescription information
- Test results
- Medical imaging data

2. Purpose of Collection and Use
- Smooth medical service provision
- Sharing medical information between healthcare providers
- Emergency response
- Improving medical service quality

3. Retention and Usage Period
- As required by medical law
- 5 years after membership withdrawal

4. Right to Refuse and Consequences
- You may refuse to consent to the collection and use of medical information,
  but in this case, some services may be limited.
''',
                      ),
                      child: const Text(
                        '[Required] Medical Records Consent',
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
                        'Sign Up',
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