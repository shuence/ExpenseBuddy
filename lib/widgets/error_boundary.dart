import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../services/navigation_service.dart';
import '../router/routes.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = _handleFlutterError;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    debugPrint('🚨 Flutter Error caught by ErrorBoundary: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
    
    setState(() {
      _error = details.exception;
      _stackTrace = details.stack;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget();
    }

    return widget.child;
  }

  Widget _buildErrorWidget() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(_error!, _stackTrace);
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 64,
                color: CupertinoColors.systemRed,
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'The app encountered an unexpected error. Don\'t worry, your data is safe.',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CupertinoButton.filled(
                onPressed: _retry,
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: _goToHome,
                child: const Text('Go to Home'),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                const Text(
                  'Debug Information:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Error: $_error\n\nStack Trace:\n$_stackTrace',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  void _goToHome() {
    try {
      NavigationService().emergencyNavigate(context);
    } catch (e) {
      debugPrint('Emergency navigation failed: $e');
      // Last resort: go to onboarding
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    FlutterError.onError = null;
    super.dispose();
  }
}
