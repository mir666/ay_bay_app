import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_path.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/core/about/ui/widget/about_app.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/core/help/ui/widget/help_app.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final UserController userController = Get.find<UserController>();
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
                gradient: LinearGradient(
                  colors: [
                    AppColors.loginTextButtonColor,
                    AppColors.bannerBottomColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  /// Background image
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.45,
                      child: Image.asset(
                        AssetsPath.drawerBannerImg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// Glass overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),

                  /// Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Obx(
                        () => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// Avatar with glow
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 34,
                                backgroundColor: Colors.blueGrey.withValues(
                                  alpha: 0.9,
                                ),
                                backgroundImage:
                                    userController.avatarUrl.value.isNotEmpty
                                    ? NetworkImage(
                                        userController.avatarUrl.value,
                                      )
                                    : null,
                                child: userController.avatarUrl.value.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),

                            SizedBox(width: 16),

                            /// Text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.localization.welcome,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userController.fullName.value.isNotEmpty
                                      ? userController.fullName.value
                                      : 'User',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Bottom accent line
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _DrawerItem(
              icon: Icons.person_2_outlined,
              title: context.localization.profile,
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
              title: context.localization.analytics,
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
              title: context.localization.budgetPlanner,
              iconSize: iconSize,
              textSize: textSize,
              padding: verticalPadding,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.appBudget);
              },
            ),

            _DrawerItem(
              icon: Icons.settings_outlined,
              title: context.localization.setting,
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
              title: context.localization.aboutApp,
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
              title: context.localization.help,
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
              title: context.localization.privacyPolicy,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Material(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Get.back();
                    controller.logout();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          context.localization.logOut,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 1.5,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: padding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.addButtonColor.withValues(alpha: 0.9),
                        AppColors.addButtonColor.withValues(alpha: 0.6),
                      ],
                    ),
                    border: Border.all(color: AppColors.bannerBottomColor.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.addButtonColor.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
