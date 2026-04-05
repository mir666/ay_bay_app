import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
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
        title: Text(
          context.localization.privacyPolicy,
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
                title: context.localization.ayBayAppPrivacyPolicy,
                subtitle: context.localization.effectiveDate,
              ),

              const SizedBox(height: 20),

              _section(
                icon: Icons.info_outline,
                title: context.localization.informationWeCollect,
                content:
                '${context.localization.readFullName}'
                    '${context.localization.readPhoneNumber}'
                    '${context.localization.readProfilePicture}'
                    '${context.localization.readEmail}'
                    '${context.localization.readTransactionsCategoriesMonthlyRecords}',
              ),

              _section(
                icon: Icons.settings_outlined,
                title: context.localization.howWeUseYourInformation,
                content:
                '${context.localization.readAccountCreationAndLogin}'
                    '${context.localization.readSavingAndRetrievingTransactions}'
                    '${context.localization.incomeAndExpenseAnalysis}'
                    '${context.localization.monthlyReportsAndSummaries}'
                    '${context.localization.displayingYourProfileInformation}',
              ),

              _section(
                icon: Icons.security_outlined,
                title: context.localization.dataSharingAndSecurity,
                content:
                '${context.localization.weNeverShareYourDataWithThirdParties}'
                    '${context.localization.securelyStoredInFirebaseFirestore}'
                    '${context.localization.accessibleOnlyByYouViaAuthentication}'
                    '${context.localization.encryptedUsingAndAtRest}',
              ),

              _section(
                icon: Icons.extension_outlined,
                title: context.localization.thirdPartyServices,
                content:
                '${context.localization.flutterPackagesForUIAndCharts}'
                    '${context.localization.firebaseAuthenticationFirestore}'
                    '${context.localization.noThirdPartyDataCollectionWithoutConsent}',
              ),

              _section(
                icon: Icons.person_outline,
                title: context.localization.userControl,
                content:
                '${context.localization.editProfileAnytime}'
                    '${context.localization.addUpdateOrDeleteTransactions}'
                    '${context.localization.yourDataAlwaysRemainsPrivate}',
              ),

              _section(
                icon: Icons.download_outlined,
                title: context.localization.downloads,
                content:
                '${context.localization.monthlyReportsCanBeDownloaded}'
                    '${context.localization.reportsIncludeOnlyYourPersonalData}',
              ),

              _section(
                icon: Icons.check_circle_outline,
                title: context.localization.consent,
                content:
                '${context.localization.byUsingAyBayAppYouAgreeToThisPrivacyPolicy}'
                    '${context.localization.minimumUserAge}',
              ),

              const SizedBox(height: 16),

              /// LINK
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: context.localization.latestVersionAvailableAt,
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
                  Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined,size: 20,),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${context.localization.contact} farhanaakter10506264robi@gmail.com',
                        style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  context.localization.copyright,
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
