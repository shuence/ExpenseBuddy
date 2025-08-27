import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../providers/auth_provider.dart';

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
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog(
        'Email Required',
        'Please enter your email address.',
      );
      return;
    }

    if (!_emailController.text.trim().contains('@')) {
      _showErrorDialog(
        'Invalid Email',
        'Please enter a valid email address.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call the AuthBloc to send password reset email
      context.read<AuthBloc>().add(
        ForgotPasswordRequested(_emailController.text.trim()),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          'Reset Failed',
          'An error occurred. Please try again.',
        );
      }
    }
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Check Your Email'),
        content: const Text(
          'We\'ve sent you a password reset link. Please check your email and follow the instructions.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
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
          prefix: Padding(
            padding: const EdgeInsets.only(left: 16),
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordSent) {
          setState(() => _isLoading = false);
          _showSuccessDialog();
        } else if (state is AuthError) {
          setState(() => _isLoading = false);
          _showErrorDialog('Password Reset Failed', state.message);
        }
      },
      child: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (!didPop) {
            Navigator.of(context).pop();
          } 
        },
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.white,
          navigationBar: CupertinoNavigationBar(
            middle: const Text(
              'Forgot Password',
              style: TextStyle(
                color: CupertinoColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: CupertinoColors.white,
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveConstants.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
                    ),
                    child: Stack(
                      children: [
                        // Dark blue rectangle (phone/card)
                        Positioned(
                          top: 20,
                          left: 30,
                          child: Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
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
                        
                        // Green shield with checkmark (top-right)
                        Positioned(
                          top: 15,
                          right: 15,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGreen,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              CupertinoIcons.check_mark,
                              color: CupertinoColors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        
                        // Green padlock (bottom-right)
                        Positioned(
                          bottom: 15,
                          right: 15,
                          child: Icon(
                            CupertinoIcons.lock,
                            color: CupertinoColors.systemGreen,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveConstants.spacing32),

                // Title
                Text(
                  'Forgot Password?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.fontSize28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimaryColor(
                      CupertinoTheme.brightnessOf(context),
                    ),
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
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                  ),
                  child: CupertinoButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveConstants.spacing16,
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                    color: CupertinoColors.transparent,
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
                ),

                SizedBox(height: ResponsiveConstants.spacing40),

                // Back to Email Auth Link
                Center(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(), // Go back instead of navigating to new route
                    child: Text(
                      'Back to Sign In',
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(
                          CupertinoTheme.brightnessOf(context),
                        ),
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
              ],
            ),
          ),
        ),
      ),
    )
    );
  }
}
