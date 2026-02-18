import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ice_shield/ui_layer/health_page/subpage/FoodDashboardPage.dart';
import 'package:ice_shield/ui_layer/health_page/subpage/FoodInputPage.dart';
import 'package:ice_shield/ui_layer/home_page/HomePage.dart';
import 'package:ice_shield/ui_layer/canvas_page/DragCanvasGridPage.dart';
import 'package:ice_shield/ui_layer/user_page/PersonalInformationPage.dart';
import 'package:ice_shield/ui_layer/user_page/ProfileDashboardPage.dart';
import 'package:ice_shield/ui_layer/health_page/HealthPage.dart';
import 'package:ice_shield/ui_layer/finance_page/FinancePage.dart';
import 'package:ice_shield/ui_layer/social_page/SocialPage.dart';
import 'package:ice_shield/ui_layer/projects_page/ProjectsPage.dart';

import 'package:ice_shield/ui_layer/home_page/IceGateAppBar.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});
  Widget _getMainButtonForRoute(BuildContext context, String route) {
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    // final cross = sqrt(width * width + height * height);

    final double responsiveSize = (width * 0.18).clamp(56.0, 70.0);

    // print("Current route: $route");
    // Determine which page's icon to show based on the route
    Widget pageIcon;
    switch (route) {
      case '/':
        pageIcon = HomePage.icon(context, size: responsiveSize);
        break;
      case '/canvas':
        pageIcon = DragCanvasGrid.icon(context, size: responsiveSize);
        break;
      case '/profile':
        pageIcon = ProfileDashboardPage.icon(context, size: responsiveSize);
        break;
      case '/health':
        pageIcon = HealthPage.icon(context, size: responsiveSize);
        break;
      case '/health/food':
        pageIcon = FoodInputPage.icon(context, size: responsiveSize);
        break;
      case '/health/exercise':
        pageIcon = HealthPage.icon(context, size: responsiveSize);
        break;
      case '/health/steps':
        pageIcon = HealthPage.icon(context, size: responsiveSize);
        break;
      case '/health/heart_rate':
        pageIcon = HealthPage.icon(context, size: responsiveSize);
        break;
      case '/health/sleep':
        pageIcon = HealthPage.icon(context, size: responsiveSize);
        break;
      case '/health/water':
        pageIcon = HealthPage.icon(context, size: responsiveSize);
        break;
      case '/health/food/dashboard':
        pageIcon = FoodDashboardPage.icon(context, size: responsiveSize);
        break;
      case '/finance':
        pageIcon = FinancePage.icon(context, size: responsiveSize);
        break;

      case '/social':
        pageIcon = SocialPage.icon(context, size: responsiveSize);
        break;
      case '/projects':
        pageIcon = ProjectsPage.icon(context, size: responsiveSize);
        break;
      case '/projects/editor':
        return const SizedBox.shrink();
      case '/personal-info':
        pageIcon = PersonalInformationPage.icon(context, size: responsiveSize);
        break;
      case '/project_notes':
        pageIcon = ProjectsPage.icon(context, size: responsiveSize);
        break;
      default:
        // Default to home icon
        pageIcon = HomePage.returnHomeIcon(context, size: responsiveSize);
    }

    // Wrap with custom size
    return SizedBox(
      width: responsiveSize,
      height: responsiveSize,
      child: pageIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;

    final bool shouldHideAppBar =
        currentRoute == '/projects/focus' ||
        currentRoute.startsWith('/widgets/webview');

    return Scaffold(
      // --- PERSISTENT APP BAR (Hidden for Focus Page & WebView) ---
      appBar: shouldHideAppBar ? null : const IceGateAppBar(),

      // --- DYNAMIC BODY (Changes based on route) ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 10),
        child: _getMainButtonForRoute(context, currentRoute),
      ),

      body: child,
    );
  }
}
