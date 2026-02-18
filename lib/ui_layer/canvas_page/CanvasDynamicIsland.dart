import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';

import 'package:ice_shield/ui_layer/ReusableWidget/ManaNotificationWidget.dart';
import 'package:ice_shield/ui_layer/notification_page/NotificationManagerPage.dart';
import 'package:ice_shield/ui_layer/canvas_page/DragCanvasGridPage.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/FocusBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/HealthBlock.dart';
import 'package:provider/provider.dart';

class CanvasDynamicIsland extends StatelessWidget {
  const CanvasDynamicIsland({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isStoreOpen = DragCanvasGrid.isOpenStore.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        width: isStoreOpen ? 360 : 300,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(
            0xFF1E1E1E,
          ), // Slightly lighter than pure black for depth
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go('/');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            // Center Title
            // Hide title when store is open to make room? Or just shrink it.
            if (!isStoreOpen)
              Expanded(
                child: Center(
                  child: AutoSizeText(
                    "CANVAS",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                    maxLines: 1,
                  ),
                ),
              )
            else
              const Spacer(),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Notifications
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationManagerPage(),
                      ),
                    );
                  },
                  child: Watch((context) {
                    final focusBlock = context.watch<FocusBlock>();
                    final count = focusBlock.sessionsCompletedToday.watch(
                      context,
                    );

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),

                const SizedBox(width: 8),

                // Step Goal Customizer
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showGoalCustomizer(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_suggest_rounded,
                      color: Colors.white70,
                      size: 26,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // vertical divider
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.white.withOpacity(0.2),
                ),

                const SizedBox(width: 8),

                // Store Toggle
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    DragCanvasGrid.toggleStore();
                  },
                  child: AnimatedRotation(
                    turns: isStoreOpen ? 0.125 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.add_circle_rounded, // Filled looks strong
                      color: isStoreOpen ? Colors.redAccent : Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showGoalCustomizer(BuildContext context) {
    final healthBlock = context.read<HealthBlock>();
    final controller = TextEditingController(
      text: healthBlock.dailyStepGoal.value.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          "Personal Goal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Set your daily step target to stay on track with your fitness journey.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Daily Step Goal",
                labelStyle: const TextStyle(color: Colors.white60),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(
                  Icons.directions_walk,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                healthBlock.dailyStepGoal.value = newGoal;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Step goal updated to $newGoal!"),
                    backgroundColor: Colors.blueAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
