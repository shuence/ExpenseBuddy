import 'package:flutter/cupertino.dart';
import '../../core/constants/responsive_constants.dart';

/// Example widget demonstrating how to use the responsive system
/// This shows different layouts for mobile, tablet, and desktop
class ResponsiveExample extends StatelessWidget {
  const ResponsiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Responsive Example',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveConstants.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive Header
              _buildResponsiveHeader(context),
              
              SizedBox(height: ResponsiveConstants.spacing32),
              
              // Responsive Grid
              _buildResponsiveGrid(context),
              
              SizedBox(height: ResponsiveConstants.spacing32),
              
              // Responsive Cards
              _buildResponsiveCards(context),
              
              SizedBox(height: ResponsiveConstants.spacing32),
              
              // Screen Info
              _buildScreenInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.spacing24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.device_phone_portrait,
            size: ResponsiveConstants.iconSize64,
            color: CupertinoColors.activeBlue,
          ),
          SizedBox(height: ResponsiveConstants.spacing16),
          Text(
            'Responsive Design',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.spacing8),
          Text(
            'This layout adapts to different screen sizes',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize16,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context) {
    // Responsive grid columns based on screen size
    int crossAxisCount = context.isMobile ? 1 : context.isTablet ? 2 : 3;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responsive Grid (${crossAxisCount} columns)',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveConstants.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: ResponsiveConstants.spacing16,
            mainAxisSpacing: ResponsiveConstants.spacing16,
            childAspectRatio: context.isMobile ? 1.5 : 1.2,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      size: ResponsiveConstants.iconSize32,
                      color: CupertinoColors.systemYellow,
                    ),
                    SizedBox(height: ResponsiveConstants.spacing8),
                    Text(
                      'Item ${index + 1}',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResponsiveCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responsive Cards',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveConstants.spacing16),
        
        // Responsive card layout
        if (context.isMobile) ...[
          // Mobile: Stacked vertically
          _buildCard('Mobile Layout', 'Optimized for small screens', CupertinoIcons.phone),
          SizedBox(height: ResponsiveConstants.spacing16),
          _buildCard('Touch Friendly', 'Large touch targets', CupertinoIcons.hand_raised),
        ] else if (context.isTablet) ...[
          // Tablet: Side by side
          Row(
            children: [
              Expanded(child: _buildCard('Tablet Layout', 'Balanced design', CupertinoIcons.device_phone_portrait)),
              SizedBox(width: ResponsiveConstants.spacing16),
              Expanded(child: _buildCard('Medium Screen', 'Optimal spacing', CupertinoIcons.device_phone_landscape)),
            ],
          ),
        ] else ...[
          // Desktop: Three columns
          Row(
            children: [
              Expanded(child: _buildCard('Desktop Layout', 'Full feature set', CupertinoIcons.desktopcomputer)),
              SizedBox(width: ResponsiveConstants.spacing16),
              Expanded(child: _buildCard('Large Screen', 'Rich content', CupertinoIcons.device_phone_portrait)),
              SizedBox(width: ResponsiveConstants.spacing16),
              Expanded(child: _buildCard('Wide View', 'Multi-column layout', CupertinoIcons.rectangle_expand_vertical)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.spacing20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: ResponsiveConstants.iconSize40,
            color: CupertinoColors.activeBlue,
          ),
          SizedBox(height: ResponsiveConstants.spacing16),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.spacing20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
        border: Border.all(
          color: CupertinoColors.systemBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Screen Information',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemBlue,
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing16),
          
          _buildInfoRow('Screen Width', '${context.screenWidth.toStringAsFixed(1)}px'),
          _buildInfoRow('Screen Height', '${context.screenHeight.toStringAsFixed(1)}px'),
          _buildInfoRow('Device Type', context.isMobile ? 'Mobile' : context.isTablet ? 'Tablet' : 'Desktop'),
          _buildInfoRow('Orientation', context.isPortrait ? 'Portrait' : 'Landscape'),
          _buildInfoRow('Status Bar', '${context.statusBarHeight.toStringAsFixed(1)}px'),
          _buildInfoRow('Safe Area', '${context.safeAreaHeight.toStringAsFixed(1)}px'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemBlue,
            ),
          ),
        ],
      ),
    );
  }
}
