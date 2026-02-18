import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ice_shield/ui_layer/home_page/MainButton.dart';
import 'package:ice_shield/ui_layer/widget_page/AddPluginForm.dart';
import 'package:provider/provider.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Canvas/WidgetManagerBlock.dart';
import 'dart:ui';
import 'InternalDragIconWidget.dart'; // The Grid Cell
import 'StoreWidget.dart'; // The Bottom Bar
import 'package:ice_shield/ui_layer/canvas_page/CanvasDynamicIsland.dart';

// --- MAIN SCREEN WRAPPER ---

void buildAddCell(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: AddPluginForm(
        data: FormData(
          title: "Add Custom Widget",
          description: "Enter the name and URL of the website you want to add.",
        ),
      ),
    ),
  );
}

class DragCanvasGrid extends StatefulWidget {
  const DragCanvasGrid({super.key});

  // Global signal for tab state
  static final activeCanvasTab = signal<String>('none');

  static void toggleStore() {
    print("Toggle store");
    if (activeCanvasTab.value == 'store') {
      activeCanvasTab.value = 'none';
    } else {
      activeCanvasTab.value = 'store';
    }
  }

  static Widget icon(BuildContext context, {double? size}) {
    return MainButton(
      type: "grid",
      destination: "/canvas",
      size: size,
      // Note: Some MainButton implementations use 'icon' as a fallback.
      // If it looks weird, try setting icon to Icons.circle (invisible) or null.
      // icon: Icons.grid_view,
      iconWidget: Center(
        child: Transform.rotate(
          angle: 45 * math.pi / 180,
          child: Icon(
            Icons.grid_view,
            color: Colors.white,
            size: size! * 0.6, // Ensure the icon respects the passed size
          ),
        ),
      ),
      mainFunction: toggleStore,
    );
  }

  @override
  State<DragCanvasGrid> createState() => _DragCanvasGridState();
}

class _DragCanvasGridState extends State<DragCanvasGrid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: baseColor,
      body: SafeArea(
        bottom: false,
        child: DragCanvas(baseColor: baseColor, isDark: isDark),
      ),
    );
  }
}

class DragCanvas extends StatefulWidget {
  final Color baseColor;
  final bool isDark;

  const DragCanvas({super.key, required this.baseColor, required this.isDark});

  @override
  State<DragCanvas> createState() => _DragCanvasState();
}

class _DragCanvasState extends State<DragCanvas> {
  bool isClick = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WidgetManagerBlock>().loadFromDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetBlock = Provider.of<WidgetManagerBlock>(context, listen: false);

    return Column(
      children: [
        const SizedBox(height: 12),
        const Center(child: CanvasDynamicIsland()),
        const SizedBox(height: 10),

        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: widget.baseColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(color: Colors.transparent),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DotGridPainter(
                        color: widget.isDark ? Colors.white : Colors.black,
                        opacity: 0.1,
                        spacing: 25,
                      ),
                    ),
                  ),
                  Watch((context) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: widgetBlock.widgets.length,
                      itemBuilder: (context, index) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return InternalDragIconWidget(
                              index: index,
                              store: widgetBlock,
                              widthCard: constraints.maxWidth,
                              heightCard: constraints.maxHeight,
                              name: widgetBlock.widgets[index].name,
                            );
                          },
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Watch((context) {
          final activeTab = DragCanvasGrid.activeCanvasTab.value;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              );
            },
            child: activeTab == 'store'
                ? const StoreWidget()
                : const SizedBox.shrink(),
          );
        }),
      ],
    );
  }
}

class DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double opacity;

  DotGridPainter({required this.color, this.spacing = 20, this.opacity = 0.1});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 2;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.opacity != opacity;
  }
}
