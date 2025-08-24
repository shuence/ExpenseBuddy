import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/navigation_service.dart';

class EmailAuthScreen extends StatefulWidget {
  final bool initialSignUpMode;
  
  const EmailAuthScreen({
    super.key,
    this.initialSignUpMode = false,
  });

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialSignUpMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _authenticate() async {
    if (_isSignUp) {
      if (_nameController.text.isEmpty || 
          _emailController.text.isEmpty || 
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showErrorDialog(
          'Validation Error',
          'Please fill in all fields.',
        );
        return;
      }
      
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorDialog(
          'Validation Error',
          'Passwords do not match.',
        );
        return;
      }
      
      if (_passwordController.text.length < 6) {
        _showErrorDialog(
          'Validation Error',
          'Password must be at least 6 characters long.',
        );
        return;
      }
    } else {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _showErrorDialog(
          'Validation Error',
          'Please fill in all fields.',
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        context.read<AuthBloc>().add(SignUpRequested(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        ));
      } else {
        context.read<AuthBloc>().add(SignInRequested(
          _emailController.text.trim(),
          _passwordController.text,
        ));
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          _isSignUp ? 'Sign Up Failed' : 'Sign In Failed',
          'Please check your credentials and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    bool isPassword = false,
    bool isConfirmPassword = false,
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
          obscureText: isPassword ? (isConfirmPassword ? _obscureConfirmPassword : _obscurePassword) : false,
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
          suffix: isPassword
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (isConfirmPassword) {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    } else {
                      setState(() => _obscurePassword = !_obscurePassword);
                    }
                  },
                  child: Icon(
                    (isConfirmPassword ? _obscureConfirmPassword : _obscurePassword)
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                    color: CupertinoColors.systemGrey,
                    size: ResponsiveConstants.iconSize20,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          NavigationService().handleSuccessfulAuth(context, state.user, hasPreferences: true);
        } else if (state is AuthenticatedButNoPreferences) {
          NavigationService().handleSuccessfulAuth(context, state.user, hasPreferences: false);
        } else if (state is AuthError) {
          _showErrorDialog('Authentication Error', state.message);
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.white,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            _isSignUp ? 'Create Account' : 'Sign In',
            style: TextStyle(
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
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
                SizedBox(height: ResponsiveConstants.spacing32),
                
                // Header Text
                Center(
                  child: Column(
                    children: [
                      Text(
                        _isSignUp ? 'Create Account' : 'Welcome Back',
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize28,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.spacing8),
                      Text(
                        _isSignUp 
                            ? 'Sign up to start managing your expenses'
                            : 'Sign in to manage your expenses',
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize16,
                          color: CupertinoColors.systemGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing48),
                
                // Name Field (only for sign up)
                if (_isSignUp) ...[
                  _buildInputField(
                    label: 'Full Name',
                    placeholder: 'Enter your full name',
                    icon: CupertinoIcons.person,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                  ),
                  
                  SizedBox(height: ResponsiveConstants.spacing24),
                ],
                
                // Email Field
                _buildInputField(
                  label: 'Email',
                  placeholder: 'Enter your email',
                  icon: CupertinoIcons.mail,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                SizedBox(height: ResponsiveConstants.spacing24),
                
                // Password Field
                _buildInputField(
                  label: 'Password',
                  placeholder: _isSignUp ? 'Create a password' : 'Enter your password',
                  icon: CupertinoIcons.lock,
                  controller: _passwordController,
                  isPassword: true,
                ),
                
                // Confirm Password Field (only for sign up)
                if (_isSignUp) ...[
                  SizedBox(height: ResponsiveConstants.spacing24),
                  
                  _buildInputField(
                    label: 'Confirm Password',
                    placeholder: 'Confirm your password',
                    icon: CupertinoIcons.lock,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    isConfirmPassword: true,
                  ),
                ],
                
                // Forgot Password (only show for sign in)
                if (!_isSignUp) ...[
                  SizedBox(height: ResponsiveConstants.spacing16),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => NavigationService().navigateToForgotPassword(context),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          fontSize: ResponsiveConstants.fontSize14,
                        ),
                      ),
                    ),
                  ),
                ],
                
                SizedBox(height: ResponsiveConstants.spacing32),
                
                // Action Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                  ),
                  child: CupertinoButton(
                    onPressed: _isLoading ? null : _authenticate,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveConstants.spacing16,
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                    color: CupertinoColors.transparent,
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : Text(
                            _isSignUp ? 'Create Account' : 'Sign In',
                            style: TextStyle(
                              fontSize: ResponsiveConstants.fontSize18,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing16),
                
                // Toggle between Sign In and Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: ResponsiveConstants.fontSize14,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() => _isSignUp = !_isSignUp);
                      },
                      child: Text(
                        _isSignUp ? 'Sign In' : 'Sign Up',
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
      ),
    );
  }
}
