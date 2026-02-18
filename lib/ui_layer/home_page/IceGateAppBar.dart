import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ice_shield/ui_layer/ReusableWidget/SettingWidget.dart';

class IceGateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IceGateAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "ICE Gate",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 0,
      actions: [
        // 1. Navigate to Home
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: "Home",
          iconSize: 30,
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
          iconSize: 30,
        ),

        // 3. Settings
        SettingsWidget.icon(context, size: 30),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
