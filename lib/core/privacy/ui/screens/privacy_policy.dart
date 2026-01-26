import 'package:ay_bay_app/app/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const policyURL =
        'https://farhanasblogsidemidia.blogspot.com/2026/01/privacy-policy-aybay-app-body-font.html';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.loginTextButtonColor,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              _header(
                title: 'AyBay App Privacy Policy',
                subtitle: 'Effective Date: January 2026',
              ),

              const SizedBox(height: 20),

              _section(
                icon: Icons.info_outline,
                title: 'Information We Collect',
                content:
                '• Full Name\n'
                    '• Phone Number\n'
                    '• Profile Picture (Avatar)\n'
                    '• Email (for password reset via Firebase)\n'
                    '• Transactions, categories, monthly records',
              ),

              _section(
                icon: Icons.settings_outlined,
                title: 'How We Use Your Information',
                content:
                '• Account creation and login\n'
                    '• Saving and retrieving transactions\n'
                    '• Income & expense analysis\n'
                    '• Monthly reports and summaries\n'
                    '• Displaying your profile information',
              ),

              _section(
                icon: Icons.security_outlined,
                title: 'Data Sharing & Security',
                content:
                '• We never share your data with third parties\n'
                    '• Securely stored in Firebase Firestore\n'
                    '• Accessible only by you via authentication\n'
                    '• Encrypted using TLS/HTTPS and at rest',
              ),

              _section(
                icon: Icons.extension_outlined,
                title: 'Third-Party Services',
                content:
                '• Flutter packages for UI & charts\n'
                    '• Firebase Authentication & Firestore\n'
                    '• No third-party data collection without consent',
              ),

              _section(
                icon: Icons.person_outline,
                title: 'User Control',
                content:
                '• Edit profile anytime\n'
                    '• Add, update, or delete transactions\n'
                    '• Your data always remains private',
              ),

              _section(
                icon: Icons.download_outlined,
                title: 'Downloads',
                content:
                '• Monthly reports can be downloaded\n'
                    '• Reports include only your personal data',
              ),

              _section(
                icon: Icons.check_circle_outline,
                title: 'Consent',
                content:
                'By using AyBay App, you agree to this Privacy Policy.\n'
                    'Minimum user age: 13+',
              ),

              const SizedBox(height: 16),

              /// LINK
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    const TextSpan(
                      text: 'Latest version available at:\n',
                    ),
                    TextSpan(
                      text: policyURL,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _launchURL(policyURL),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// CONTACT
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                  Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.email_outlined),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Contact: farhanaakter10506264robi@gmail.com',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  '© 2026 AyBay App',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 SECTION WIDGET
  Widget _section({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 HEADER
  Widget _header({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
