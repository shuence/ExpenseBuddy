import 'package:flutter/cupertino.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Help & Support'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Quick Help Section
                const Text(
                  'Quick Help',
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
                          CupertinoIcons.question_circle,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'FAQ',
                      subtitle: 'Frequently asked questions',
                      onTap: () => _showFAQ(context),
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
                          CupertinoIcons.book,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'User Guide',
                      subtitle: 'Learn how to use ExpenseBuddy',
                      onTap: () => _showUserGuide(context),
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
                          CupertinoIcons.play_rectangle,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Video Tutorials',
                      subtitle: 'Watch step-by-step guides',
                      onTap: () => _showVideoTutorials(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Contact Support Section
                const Text(
                  'Contact Support',
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
                          CupertinoIcons.chat_bubble_2,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Live Chat',
                      subtitle: 'Chat with our support team',
                      onTap: () => _startLiveChat(context),
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
                          CupertinoIcons.mail,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Email Support',
                      subtitle: 'support@expensebuddy.com',
                      onTap: () => _sendEmail(context),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.phone,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Phone Support',
                      subtitle: '1-800-EXPENSE (1-800-397-3673)',
                      onTap: () => _callSupport(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Feedback Section
                const Text(
                  'Feedback',
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
                          color: CupertinoColors.systemYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.star,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Rate the App',
                      subtitle: 'Share your experience',
                      onTap: () => _rateApp(context),
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
                          CupertinoIcons.pencil,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Send Feedback',
                      subtitle: 'Help us improve the app',
                      onTap: () => _sendFeedback(context),
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
                          CupertinoIcons.lightbulb,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Feature Request',
                      subtitle: 'Suggest new features',
                      onTap: () => _requestFeature(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Report Issues Section
                const Text(
                  'Report Issues',
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
                          CupertinoIcons.exclamationmark_triangle,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Report a Bug',
                      subtitle: 'Something not working correctly?',
                      onTap: () => _reportBug(context),
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
                          CupertinoIcons.shield_slash,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Security Issue',
                      subtitle: 'Report a security concern',
                      onTap: () => _reportSecurityIssue(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Community Section
                const Text(
                  'Community',
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
                          CupertinoIcons.person_3,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Community Forum',
                      subtitle: 'Connect with other users',
                      onTap: () => _openCommunityForum(context),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.link,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Social Media',
                      subtitle: 'Follow us for updates',
                      onTap: () => _showSocialMediaLinks(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Support Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.heart_fill,
                            color: CupertinoColors.systemRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'We\'re Here to Help',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our support team is available 24/7 to help you with any questions or issues. We typically respond within 2 hours.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                          height: 1.4,
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

  void _showFAQ(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('FAQ'),
        content: const Text('The FAQ section will be available in a future update with answers to common questions.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showUserGuide(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('User Guide'),
        content: const Text('The complete user guide will be available soon with detailed instructions.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showVideoTutorials(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Video Tutorials'),
        content: const Text('Video tutorials will be available in the next update.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _startLiveChat(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Live Chat'),
        content: const Text('Live chat support will be available soon. For immediate assistance, please use email or phone support.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _sendEmail(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Email Support'),
        content: const Text('Opening your email app to contact support@expensebuddy.com'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _callSupport(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Phone Support'),
        content: const Text('Call 1-800-EXPENSE (1-800-397-3673) for immediate assistance.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Call'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Rate ExpenseBuddy'),
        content: const Text('Thank you for using ExpenseBuddy! Would you like to rate us on the App Store?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Not Now'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Rate'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Send Feedback'),
        content: const Text('Your feedback helps us improve ExpenseBuddy. You\'ll be redirected to our feedback form.'),
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

  void _requestFeature(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Feature Request'),
        content: const Text('Have an idea for a new feature? We\'d love to hear it!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Submit'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _reportBug(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Report a Bug'),
        content: const Text('Help us fix issues by reporting bugs. Please include as much detail as possible.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Report'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _reportSecurityIssue(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Security Issue'),
        content: const Text('Security issues are taken seriously. Please email security@expensebuddy.com directly.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _openCommunityForum(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Community Forum'),
        content: const Text('The community forum will be available soon where you can connect with other users.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSocialMediaLinks(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Follow ExpenseBuddy'),
        message: const Text('Stay updated with the latest news and updates'),
        actions: [
        CupertinoActionSheetAction(
          child: const Text('Twitter'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('Facebook'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('Instagram'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('LinkedIn'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    );
  }
}
