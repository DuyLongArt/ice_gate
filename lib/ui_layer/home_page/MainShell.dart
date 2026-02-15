import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ice_shield/ui_layer/ReusableWidget/SettingWidget.dart';
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

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  Widget _getMainButtonForRoute(BuildContext context, String route) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final cross = sqrt(width * width + height * height);

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

    return Scaffold(
      // --- PERSISTENT APP BAR ---
      appBar: AppBar(
        title: const Text(
          "ICE Shield",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // 1. Navigate to Home
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: "Home",
            onPressed: () {
              try {
                context.pop();
              } catch (e) {
                context.go('/');
              }
            },
          ),
          // 2. Navigate to Canvas (Your Grid)
          IconButton(
            icon: const Icon(Icons.grid_view),
            tooltip: "Canvas",
            onPressed: () => context.go('/canvas'),
          ),

          // 3. Navigate to Settings (Example)
          // IconButton(
          //   icon: const Icon(Icons.settings),
          //   tooltip: "Settings",
          //   onPressed: () => context.go('/settings'),
          // ),
          SettingsWidget.icon(context),
        ],
      ),

      // --- DYNAMIC BODY (Changes based on route) ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 10),
        child: _getMainButtonForRoute(context, currentRoute),
      ),

      body: child,
    );
  }
}
