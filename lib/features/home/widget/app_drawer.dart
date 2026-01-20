import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_path.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/core/about/ui/widget/about_app.dart';
import 'package:ay_bay_app/core/help/ui/widget/help_app.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final size = MediaQuery.sizeOf(context);

    final bool isSmall = size.width < 360;
    final bool isTablet = size.width >= 600;

    final double headerHeight = isTablet ? 220 : isSmall ? 130 : 160;
    final double iconSize = isTablet ? 28 : isSmall ? 20 : 24;
    final double textSize = isTablet ? 18 : isSmall ? 14 : 16;
    final double verticalPadding = isTablet ? 18 : isSmall ? 12 : 14;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 HEADER
            Container(
              height: headerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bannerBottomColor,
                image: DecorationImage(
                  image: AssetImage(AssetsPath.drawerBannerImg),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _DrawerItem(
              icon: Icons.person_2_outlined,
              title: 'প্রোফাইল',
              iconSize: iconSize,
              textSize: textSize,
              padding: verticalPadding,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.appProfile);
              },
            ),

            _DrawerItem(
              icon: Icons.analytics_outlined,
              title: 'Analytics',
              iconSize: iconSize,
              textSize: textSize,
              padding: verticalPadding,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.appAnalysis);
              },
            ),

            _DrawerItem(
              icon: Icons.next_plan_outlined,
              title: 'Budget Planner',
              iconSize: iconSize,
              textSize: textSize,
              padding: verticalPadding,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.appBudget);
              }
            ),

            _DrawerItem(
              icon: Icons.settings_outlined,
              title: 'সেটিংস',
              iconSize: iconSize,
              textSize: textSize,
              padding: verticalPadding,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.appSettings);
              },
            ),

            _DrawerItem(
              icon: Icons.info_outline,
              title: 'About App',
              iconSize: iconSize,
              textSize: textSize,
              padding: verticalPadding,
              onTap: () {
                Get.back();
                AboutAppDialog.show();
              },
            ),
            _DrawerItem(
              icon: Icons.help_outline_sharp,
              title: 'Help / FAQ',
              iconSize: iconSize,
              textSize: textSize,
              padding: verticalPadding,
              onTap: () {
                Get.back();
                HelpDialog.show();
              },
            ),
            _DrawerItem(
              icon: Icons.warning_amber_outlined,
              title: 'Privacy Policy',
              iconSize: iconSize,
              textSize: textSize,
              padding: verticalPadding,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.appPrivacy);
              },
            ),

            const Divider(height: 24),

            /// 🔹 LOGOUT
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: verticalPadding,
              ),
              child: InkWell(
                onTap: () {
                  Get.back();
                  controller.logout();
                },
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: iconSize),
                    const SizedBox(width: 12),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: textSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}

/// 🔹 Responsive Drawer Item
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final double iconSize;
  final double textSize;
  final double padding;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.iconSize,
    required this.textSize,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: padding),
        child: Row(
          children: [
            Icon(icon, size: iconSize, color: AppColors.addButtonColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
