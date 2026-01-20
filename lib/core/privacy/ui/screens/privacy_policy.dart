import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    const policyURL =
        'https://farhanasblogsidemidia.blogspot.com/2026/01/privacy-policy-aybay-app-body-font.html';

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black,
            ),
            children: [
              const TextSpan(
                text: '''
Privacy Policy for AyBay App

Effective Date: January 2026

1. Information We Collect
-------------------------
AyBay app collects the following personal information:
- Full Name
- Phone Number
- Profile Picture (Avatar)
- Email (used for password reset via Firebase)
- Transactions, categories, monthly records

2. How We Use Your Information
-------------------------------
- To create and manage your account (Sign up / Login)
- To save and retrieve your financial transactions
- To provide analysis of income, expenses, and monthly reports
- To allow you to view and download your monthly summaries
- To display your profile information within the app

3. Data Sharing and Security
-----------------------------
- Your personal information and financial data are **never shared** with third parties.
- All data is securely stored in Firebase Firestore.
- Only you can access your data using your authenticated account.

4. Third-Party Services
-----------------------
- The app uses Flutter packages for charts, reports, and UI.
- Firebase Authentication and Firestore are used for login and data storage.
- No third-party services collect your personal data without your consent.

5. User Control
----------------
- You can edit your profile information (name, avatar) anytime.
- You can delete or modify your transactions anytime.
- Your financial data remains private and secure.

6. Downloads
-------------
- Monthly summaries or reports can be downloaded by you only.
- These reports contain only your personal financial data.

7. Consent
-----------
- By using AyBay app, you agree to this Privacy Policy.
- If you do not agree, please do not use the app.

Contact Us
-----------
If you have any questions about this Privacy Policy, please contact us via farhanaakter10506264robi@gmail.com

- All personal and financial data is encrypted using TLS/HTTPS during transmission and encrypted at rest in Firebase.
- We do not sell or rent your personal data to third parties.
- We may update this Privacy Policy occasionally; the latest version will be available at ''',
              ),
              TextSpan(
                text: policyURL,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _launchURL(policyURL);
                  },
              ),
              const TextSpan(
                text: '''
.
- Minimum user age: 13+.

Thank you for trusting AyBay App.

Copyright© 2026
''',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
