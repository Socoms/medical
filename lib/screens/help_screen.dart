import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Help',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildContactCard(
              'Email',
              'support@hospitalapp.com',
              Icons.email,
              () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'support@hospitalapp.com',
                );
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              'Phone',
              '+82 10-1234-5678',
              Icons.phone,
              () async {
                final Uri phoneLaunchUri = Uri(
                  scheme: 'tel',
                  path: '+821012345678',
                );
                if (await canLaunchUrl(phoneLaunchUri)) {
                  await launchUrl(phoneLaunchUri);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              'Website',
              'www.hospitalapp.com',
              Icons.language,
              () async {
                final Uri websiteLaunchUri = Uri(
                  scheme: 'https',
                  path: 'www.hospitalapp.com',
                );
                if (await canLaunchUrl(websiteLaunchUri)) {
                  await launchUrl(websiteLaunchUri);
                }
              },
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'If you encounter any issues or have questions while using the app, please feel free to contact us. We will respond as quickly as possible.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 