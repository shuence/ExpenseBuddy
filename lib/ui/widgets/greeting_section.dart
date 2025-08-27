import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/responsive_constants.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class GreetingSection extends StatelessWidget {
  final UserModel? currentUser;
  final bool isLoading;
  final UserService userService;

  const GreetingSection({
    super.key,
    required this.currentUser,
    required this.isLoading,
    required this.userService,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    final greeting = userService.getTimeBasedGreeting();
    final userName = userService.getUserDisplayName(currentUser);
    final userInitials = userService.getUserInitials(currentUser);
    final profileImageUrl = userService.getUserProfileImageUrl(currentUser);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize14,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: ResponsiveConstants.spacing2),
              Text(
                userName,
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveConstants.spacing12),
        _buildUserAvatar(context, userInitials, profileImageUrl),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 14,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            SizedBox(height: ResponsiveConstants.spacing2),
            Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CupertinoColors.systemGrey5,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(BuildContext context, String initials, String? profileImageUrl) {
    return GestureDetector(
      onTap: () {
        _showProfileOptions(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: profileImageUrl != null 
              ? CupertinoColors.white 
              : AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: profileImageUrl != null
              ? Image.network(
                  profileImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitialsAvatar(context, initials);
                  },
                )
              : _buildInitialsAvatar(context, initials),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context, String initials) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
            AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize12,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }

  void _showProfileOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          currentUser?.displayName ?? 'User Profile',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize16,
            fontWeight: FontWeight.w600,
          ),
        ),
        message: Text(
          currentUser?.email ?? '',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to profile screen
            },
            child: Text('View Profile'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to settings
            },
            child: Text('Settings'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ),
    );
  }
}
