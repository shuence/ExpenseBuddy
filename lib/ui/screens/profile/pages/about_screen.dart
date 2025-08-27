import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _version = '2.1.0';
        _buildNumber = '100';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('About ExpenseBuddy'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // App Info Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          CupertinoIcons.money_dollar_circle,
                          size: 40,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ExpenseBuddy',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version $_version ($_buildNumber)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your personal expense tracking companion',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // App Information Section
                const Text(
                  'App Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                
                SettingsSection(
                  children: [
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.info,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'What\'s New',
                      subtitle: 'See the latest features and improvements',
                      onTap: () => _showWhatsNew(context),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_text,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Release Notes',
                      subtitle: 'Complete changelog',
                      onTap: () => _showReleaseNotes(context),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.device_phone_portrait,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'System Requirements',
                      subtitle: 'iOS 12.0 or later',
                      onTap: () => _showSystemRequirements(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Legal Section
                const Text(
                  'Legal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                
                SettingsSection(
                  children: [
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_text,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Terms of Service',
                      subtitle: 'Read our terms of service',
                      onTap: () => _showTermsOfService(context),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemTeal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.shield,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Privacy Policy',
                      subtitle: 'How we protect your data',
                      onTap: () => _showPrivacyPolicy(context),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemIndigo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.building_2_fill,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Licenses',
                      subtitle: 'Open source licenses',
                      onTap: () => _showLicenses(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Company Section
                const Text(
                  'Company',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                
                SettingsSection(
                  children: [
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.globe,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Website',
                      subtitle: 'www.expensebuddy.com',
                      onTap: () => _openWebsite(context),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.person_3,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'About Us',
                      subtitle: 'Learn more about our team',
                      onTap: () => _showAboutUs(context),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.mail,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Contact',
                      subtitle: 'Get in touch with us',
                      onTap: () => _showContact(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Credits Section
                const Text(
                  'Credits',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                
                SettingsSection(
                  children: [
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.heart,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Acknowledgments',
                      subtitle: 'Special thanks to our contributors',
                      onTap: () => _showAcknowledgments(context),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.square_stack_3d_up,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Third-Party Libraries',
                      subtitle: 'Open source libraries used',
                      onTap: () => _showThirdPartyLibraries(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Copyright Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                                              Icon(
                          CupertinoIcons.circle,
                          color: CupertinoColors.systemGrey,
                          size: 24,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '© 2024 ExpenseBuddy Inc.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All rights reserved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWhatsNew(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('What\'s New'),
        content: const Text('• Improved performance\n• Bug fixes and stability improvements\n• New expense categories\n• Enhanced security features'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showReleaseNotes(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Release Notes'),
        content: const Text('Complete release notes will be available on our website and in the app store.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSystemRequirements(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('System Requirements'),
        content: const Text('iOS 12.0 or later\niPadOS 13.0 or later\nCompatible with iPhone, iPad, and iPod touch'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('You\'ll be redirected to our website to view the complete terms of service.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Continue'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('You\'ll be redirected to our website to view our privacy policy.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Continue'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Open Source Licenses'),
        content: const Text('This app uses various open source libraries. Tap Continue to view their licenses.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Continue'),
                          onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => Theme(
                      data: ThemeData.light(),
                      child: LicensePage(
                        applicationName: 'ExpenseBuddy',
                        applicationVersion: _version,
                      ),
                    ),
                  ),
                );
              },
          ),
        ],
      ),
    );
  }

  void _openWebsite(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Visit Website'),
        content: const Text('Opening www.expensebuddy.com in your browser.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAboutUs(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About Us'),
        content: const Text('ExpenseBuddy was created to help people manage their finances better. Our team is passionate about creating simple, powerful tools for personal finance.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showContact(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Contact Us'),
        content: const Text('Email: contact@expensebuddy.com\nPhone: 1-800-EXPENSE\nAddress: 123 Finance St, Money City, MC 12345'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAcknowledgments(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Acknowledgments'),
        content: const Text('Special thanks to our beta testers, contributors, and the Flutter community for making this app possible.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showThirdPartyLibraries(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Third-Party Libraries'),
        content: const Text('This app uses Flutter, Firebase, and other open source libraries. View complete list in the licenses section.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
