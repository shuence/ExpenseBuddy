import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../router/routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    setState(() => _isLoading = true);

    try {
      // Simulate password reset delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Reset Failed',
          'Please check your email address and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Check Your Email'),
        content: const Text('We\'ve sent you a password reset link. Please check your email and follow the instructions.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityGraphic() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Dark blue rectangle (phone/card)
          Positioned(
            top: 20,
            left: 35,
            child: Container(
              width: 50,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A), // Dark blue
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Key icon (bottom-left)
          Positioned(
            bottom: 25,
            left: 25,
            child: Icon(
              CupertinoIcons.lock_open,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ),
          // Shield icon with checkmark (top-right)
          Positioned(
            top: 25,
            right: 25,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981), // Green
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.check_mark,
                color: CupertinoColors.white,
                size: 16,
              ),
            ),
          ),
          // Padlock icon (bottom-right)
          Positioned(
            bottom: 25,
            right: 25,
            child: Icon(
              CupertinoIcons.lock_fill,
              color: const Color(0xFF10B981), // Green
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String placeholder,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
              width: 1,
            ),
          ),
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            fontSize: ResponsiveConstants.fontSize16,
          ),
          placeholderStyle: TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: ResponsiveConstants.fontSize16,
          ),
          suffix: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              icon,
              color: CupertinoColors.systemGrey,
              size: ResponsiveConstants.iconSize20,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveConstants.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => context.pop(),
                  child: Icon(
                    CupertinoIcons.arrow_left,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    size: ResponsiveConstants.iconSize24,
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing32),
              
              // Security Graphic
              Center(
                child: _buildSecurityGraphic(),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing32),
              
              // Title
              Text(
                'Forgot Password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing16),
              
              // Subtitle
              Text(
                'Enter your email address to reset your password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing40),
              
              // Email Input Field
              _buildInputField(
                label: 'Email Address',
                placeholder: 'Enter your email',
                icon: CupertinoIcons.mail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              
              SizedBox(height: ResponsiveConstants.spacing40),
              
              // Reset Password Button
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _resetPassword,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveConstants.spacing16,
                ),
                borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                child: _isLoading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing24),
              
              // Back to Login Link
              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => context.pop(),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      fontSize: ResponsiveConstants.fontSize16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing40),
              
              // Footer
              Center(
                child: Text(
                  'Need help? Contact Support',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: ResponsiveConstants.fontSize14,
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}
