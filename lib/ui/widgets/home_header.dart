import 'package:flutter/cupertino.dart';
import '../../services/user_service.dart';
import '../../services/user_preferences_service.dart';
import '../../models/user_model.dart';
import 'connectivity_status_widget.dart';

class HomeHeader extends StatefulWidget {
  final UserModel? currentUser;
  final bool isLoading;
  final UserService userService;

  const HomeHeader({
    super.key,
    required this.currentUser,
    required this.isLoading,
    required this.userService,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  String? _profileImageUrl;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final imageUrl = await _preferencesService.getProfileImageUrl();
      if (mounted) {
        setState(() {
          _profileImageUrl = imageUrl;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row: Greeting and Right side elements
        Row(
          children: [
            // Greeting Text (Left side)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getDisplayName(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                ],
              ),
            ),
            
            // Right side: Connectivity Icon and User Avatar
            Row(
              children: [
                // Connectivity Status Icon
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: const ConnectivityStatusWidget(size: 20, showBackground: false),
                ),
                
                // User Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: CupertinoColors.systemGrey4,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildProfileImage(),
                  ),
                ),
              ],
            ),
          ],
        ),
        

      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getDisplayName() {
    if (widget.isLoading) {
      return 'Loading...';
    }
    
    if (widget.currentUser?.displayName.isNotEmpty == true) {
      return widget.currentUser!.displayName;
    } else if (widget.currentUser?.email.isNotEmpty == true) {
      return widget.currentUser!.email.split('@').first;
    }
    return 'User';
  }

  Widget _buildProfileImage() {
    if (_isLoadingImage) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: CupertinoColors.systemGrey4,
        ),
        child: const Center(
          child: CupertinoActivityIndicator(radius: 8),
        ),
      );
    }

    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return Image.network(
        _profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsAvatar();
        },
      );
    }

    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CupertinoColors.systemGrey4,
      ),
      child: Center(
        child: Text(
          widget.currentUser != null 
              ? widget.userService.getUserInitials(widget.currentUser) 
              : 'U',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
      ),
    );
  }
}
