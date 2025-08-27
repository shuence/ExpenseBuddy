import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../router/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void dispose() {
    super.dispose();
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


 Widget _buildSocialButton({
    required String imagePath,
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveConstants.spacing16,
          horizontal: ResponsiveConstants.spacing16,
        ),
        color: CupertinoColors.transparent,
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CupertinoActivityIndicator(
                color: CupertinoColors.systemGrey,
                radius: 10,
              )
            else
            Image.asset(
              imagePath,
              width: ResponsiveConstants.iconSize20,
              height: ResponsiveConstants.iconSize20,
              fit: BoxFit.contain,
            ),
            SizedBox(width: ResponsiveConstants.spacing8),
            Text(
              isLoading ? 'Signing in...' : text,
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize14,
                color: isLoading ? CupertinoColors.systemGrey : CupertinoColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(AppRoutes.home); // Keep context.go - resets navigation stack
        } else if (state is AuthenticatedButNoPreferences) {
          context.push(AppRoutes.userPreferences);
        } else if (state is AuthError) {
          _showErrorDialog('Authentication Error', state.message);
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.white,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveConstants.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: ResponsiveConstants.spacing56),

              // App Icon and Welcome Text
              Center(
                child: Column(
                  children: [
                    Container(
                      width: ResponsiveConstants.containerHeight80,
                      height: ResponsiveConstants.containerHeight80,
                      decoration: BoxDecoration(
                        color: AppTheme.getPrimaryColor(
                          CupertinoTheme.brightnessOf(context),
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveConstants.radius16,
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.creditcard_fill,
                        size: ResponsiveConstants.iconSize40,
                        color: CupertinoColors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.spacing24),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize28,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.spacing8),
                    Text(
                      'Sign in to manage your expenses',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveConstants.spacing48),

              // Continue with Email Button
              CupertinoButton(
                onPressed: () {
                  context.push(AppRoutes.emailAuth, extra: false);
                },
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveConstants.spacing16,
                ),
                color: AppTheme.getPrimaryColor(
                  CupertinoTheme.brightnessOf(context),
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveConstants.radius12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.mail,
                      color: CupertinoColors.white,
                      size: ResponsiveConstants.iconSize20,
                    ),
                    SizedBox(width: ResponsiveConstants.spacing8),
                    Text(
                      'Continue with Email',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveConstants.spacing32),

              // Or continue with separator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: CupertinoColors.systemGrey4,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveConstants.spacing16,
                    ),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: ResponsiveConstants.fontSize14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: CupertinoColors.systemGrey4,
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveConstants.spacing32),

              // Social Login Buttons
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  
                  return Column(
                children: [
                  _buildSocialButton(
                    imagePath: 'assets/icons/google.png',
                    text: 'Sign in with Google',
                    onPressed: () {
                      context.read<AuthBloc>().add(GoogleSignInRequested());
                    },
                        isLoading: isLoading,
                  ),
                  SizedBox(height: ResponsiveConstants.spacing20),
                  _buildSocialButton(
                    imagePath: 'assets/icons/apple.png',
                    text: 'Sign in with Apple',
                    onPressed: () {
                      context.read<AuthBloc>().add(AppleSignInRequested());
                    },
                        isLoading: isLoading,
                  ),
                ],
                  );
                },
              ),

              SizedBox(height: ResponsiveConstants.spacing16),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: ResponsiveConstants.fontSize14,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      context.push(AppRoutes.emailAuth, extra: true);
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                        fontSize: ResponsiveConstants.fontSize14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
      ),
    );
  }
}
