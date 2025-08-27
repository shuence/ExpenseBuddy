import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../../../../services/connectivity_service.dart';
import '../../../widgets/connectivity_status_widget.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel? user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  UserModel? _actualUser;
  final UserService _userService = UserService();
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    debugPrint('ProfileHeader: Loading user data...');
    debugPrint('ProfileHeader: Widget user: ${widget.user}');
    debugPrint('ProfileHeader: Widget user displayName: ${widget.user?.displayName}');
    debugPrint('ProfileHeader: Widget user email: ${widget.user?.email}');
    
    // Always try to fetch from service first (most reliable)
    try {
      final user = await _userService.getCurrentUser();
      debugPrint('ProfileHeader: UserService returned: ${user?.displayName}');
      debugPrint('ProfileHeader: UserService email: ${user?.email}');
      
      if (mounted && user != null) {
        setState(() {
          _actualUser = user;
        });
        debugPrint('ProfileHeader: Using UserService user: ${_actualUser?.displayName}');
        return;
      }
    } catch (e) {
      debugPrint('ProfileHeader: Error loading user from service: $e');
    }
    
    // Fall back to widget user if service fails
    if (widget.user != null) {
      setState(() {
        _actualUser = widget.user;
      });
      debugPrint('ProfileHeader: Falling back to widget user: ${_actualUser?.displayName}');
    } else {
      debugPrint('ProfileHeader: No user data available from any source');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Connectivity Status Icon
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: const ConnectivityStatusWidget(size: 16),
          ),
          
          // Profile Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: CupertinoColors.systemGrey4,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _actualUser?.photoURL != null && _actualUser!.photoURL!.isNotEmpty
                  ? Image.network(
                      _actualUser!.photoURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar();
                      },
                    )
                  : _buildInitialsAvatar(),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDisplayName(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _actualUser?.email ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          
          // Arrow Icon
          const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.systemGrey2,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _getDisplayName() {
    if (_actualUser?.displayName.isNotEmpty == true) {
      return _actualUser!.displayName;
    } else if (_actualUser?.email.isNotEmpty == true) {
      return _actualUser!.email.split('@').first;
    }
    return 'User';
  }

  Widget _buildInitialsAvatar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CupertinoColors.systemGrey4,
      ),
      child: Center(
        child: Text(
          _actualUser != null ? _userService.getUserInitials(_actualUser) : 'U',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
      ),
    );
  }
}
