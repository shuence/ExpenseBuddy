import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_extensions.dart';

/// Theme settings screen for users to choose app theme
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Theme Settings'),
      ),
      child: SafeArea(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return ListView(
              padding: EdgeInsets.all(ResponsiveConstants.spacing20),
              children: [
                // Theme Mode Selection
                _buildSectionHeader(context, 'Theme Mode'),
                SizedBox(height: ResponsiveConstants.spacing16),
                
                // Light Theme Option
                _buildThemeOption(
                  context,
                  title: 'Light Theme',
                  subtitle: 'Always use light theme',
                  icon: CupertinoIcons.sun_max,
                  iconColor: AppColors.accent,
                  isSelected: themeProvider.themeMode == ThemeMode.light,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing12),
                
                // Dark Theme Option
                _buildThemeOption(
                  context,
                  title: 'Dark Theme',
                  subtitle: 'Always use dark theme',
                  icon: CupertinoIcons.moon,
                  iconColor: AppColors.secondary,
                  isSelected: themeProvider.themeMode == ThemeMode.dark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing12),
                
                // System Theme Option
                _buildThemeOption(
                  context,
                  title: 'System Theme',
                  subtitle: 'Follow system theme',
                  icon: CupertinoIcons.settings,
                  iconColor: AppColors.info,
                  isSelected: themeProvider.themeMode == ThemeMode.system,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing32),
                
                // Current Theme Preview
                _buildSectionHeader(context, 'Preview'),
                SizedBox(height: ResponsiveConstants.spacing16),
                
                _buildThemePreview(context, themeProvider),
                
                SizedBox(height: ResponsiveConstants.spacing32),
                
                // Theme Information
                _buildSectionHeader(context, 'About'),
                SizedBox(height: ResponsiveConstants.spacing16),
                
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.spacing16),
                  decoration: BoxDecoration(
                    color: context.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Features',
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.spacing12),
                      _buildFeatureItem(
                        context,
                        icon: CupertinoIcons.palette,
                        text: 'Automatic light/dark mode switching',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: CupertinoIcons.eye,
                        text: 'Optimized for readability',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: CupertinoIcons.collections,
                        text: 'Consistent color scheme',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: CupertinoIcons.device_phone_portrait,
                        text: 'Responsive design support',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveConstants.fontSize18,
        fontWeight: FontWeight.w600,
        color: context.textPrimaryColor,
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.spacing16),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor.withOpacity(0.1) : context.surfaceColor,
          borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.spacing12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveConstants.radius8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: ResponsiveConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize16,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.spacing4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: context.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreview(BuildContext context, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.spacing20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  CupertinoIcons.money_dollar_circle,
                  color: CupertinoColors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: ResponsiveConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Card',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'This is how your app will look',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveConstants.spacing16),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.spacing8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: context.primaryColor,
          ),
          SizedBox(width: ResponsiveConstants.spacing8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize14,
                color: context.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}