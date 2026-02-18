import 'package:flutter/material.dart';
import 'package:ice_shield/ui_layer/ReusableWidget/DepartmentCard.dart';
import 'package:ice_shield/ui_layer/canvas_page/DragCanvasGridPage.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/PersonBlock.dart';

// --- MOCK DATA MODEL ---
// --- DASHBOARD WIDGET ---

// --- DASHBOARD WIDGET ---
class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  // bool _isInteractingWithCard = false; // Unused

  void _setCardInteraction(bool isInteracting) {
    // setState(() {
    //   _isInteractingWithCard = isInteracting;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Watch PersonBlock
    final personBlock = context.watch<PersonBlock>();
    final info = personBlock.information.watch(context);
    final userProfile = info.profiles;
    final userDetails = info.details;

    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27), // Dark background
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: const Text(
                  'Hunter Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 0.5,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: Colors.white,
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
                color: Colors.white,
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Enhanced Profile Header
                _buildEnhancedProfileHeader(context, userProfile),

                const SizedBox(height: 24),

                // StatsCard - Passing null or default for now as stats are missing
                _buildStatsCard(context),

                const SizedBox(height: 24),

                // Metrics Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'System Metrics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Enhanced Metrics Grid
                _buildEnhancedMetricsGrid(context, isLargeScreen),

                const SizedBox(height: 32),

                // Department Canvas Section
                _buildCanvasHeader(context),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Interactive Canvas
          SliverToBoxAdapter(child: _buildInteractiveCanvas()),
          // DragCanvas(),
          SliverToBoxAdapter(child: DragCanvasGrid()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // Enhanced Profile Header with glass morphism effect
  Widget _buildEnhancedProfileHeader(BuildContext context, UserProfile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              // Avatar with glow effect
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                  child: user.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.firstName} ${user.lastName}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.alias.isNotEmpty
                          ? user.alias
                          : "No alias", // Email is missing
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'S-Rank Hunter',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced Stats Card with better visual design
  Widget _buildStatsCard(BuildContext context) {
    // Default values for now
    const strength = 0;
    const intelligence = 0;
    const agility = 0;
    const stamina = 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_graph,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '[STATUS WINDOW] Properties',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildEnhancedStatBar(
                'Strength',
                strength,
                const Color(0xFFEF4444),
                Icons.fitness_center,
              ),
              const SizedBox(height: 16),
              _buildEnhancedStatBar(
                'Intelligence',
                intelligence,
                const Color(0xFF3B82F6),
                Icons.psychology,
              ),
              const SizedBox(height: 16),
              _buildEnhancedStatBar(
                'Agility',
                agility,
                const Color(0xFF10B981),
                Icons.speed,
              ),
              const SizedBox(height: 16),
              _buildEnhancedStatBar(
                'Stamina',
                stamina,
                const Color(0xFFF59E0B),
                Icons.favorite,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced stat bar with icon and better styling
  Widget _buildEnhancedStatBar(
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    final double progress = value / 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Enhanced Metrics Grid with modern cards
  Widget _buildEnhancedMetricsGrid(BuildContext context, bool isLargeScreen) {
    List<Map<String, dynamic>> metrics = [
      {
        'title': 'Total Logins',
        'value': 0, // Placeholder
        'icon': Icons.login,
        'gradient': [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
      },
      {
        'title': 'Active Projects',
        'value': 0, // Placeholder
        'icon': Icons.work_outline,
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      },
      {
        'title': 'Tasks Completed',
        'value': 0, // Placeholder
        'icon': Icons.task_alt,
        'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLargeScreen ? 3 : 1,
          childAspectRatio: isLargeScreen ? 1.5 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return _buildEnhancedMetricCard(
            title: metric['title'],
            value: metric['value'].toString(),
            icon: metric['icon'],
            gradient: metric['gradient'],
          );
        },
      ),
    );
  }

  // Enhanced metric card with gradient and animation potential
  Widget _buildEnhancedMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Canvas section header
  Widget _buildCanvasHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Department Canvas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Double tap to toggle',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Interactive Canvas with enhanced styling
  Widget _buildInteractiveCanvas() {
    return Container(
      height: 600,
      width: 2000,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          // panEnabled: false, // Disable panning
          // scaleEnabled: false, // Disable scaling/zooming
          // boundaryMargin: EdgeInsets.zero, // No boundary margin
          // minScale: 4.0, // Fixed scale
          // maxScale: 4.0, // Fixed scale
          // constrained: true, // Constrain to container size
          child: Stack(
            children: [
              DraggableCard(
                initialLeft: 10,
                initialTop: 50,
                title: "Health",
                onInteractionChanged: _setCardInteraction,
              ),
              DraggableCard(
                initialLeft: 200,
                initialTop: 100,
                title: "Mana",
                onInteractionChanged: _setCardInteraction,
              ),
              DraggableCard(
                initialLeft: 100,
                initialTop: 250,
                title: "Stamina",
                onInteractionChanged: _setCardInteraction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Enhanced DraggableCard Widget ---
class DraggableCard extends StatefulWidget {
  final double initialLeft;
  final double initialTop;
  final String title;
  final Function(bool) onInteractionChanged;

  const DraggableCard({
    super.key,
    required this.initialLeft,
    required this.initialTop,
    required this.title,
    required this.onInteractionChanged,
  });

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  late double currentLeft;
  late double currentTop;
  double currentWidthPercent = 0.5;
  double currentHeightPercent = 0.5;
  bool onDragMode = true;
  double cardWidth = 200.0;
  double cardHeight = 200.0;
  @override
  void initState() {
    super.initState();
    currentLeft = widget.initialLeft;
    currentTop = widget.initialTop;
  }

  @override
  Widget build(BuildContext context) {
    final canvasWidth = MediaQuery.of(context).size.width;
    final canvasHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: currentLeft,
      top: currentTop,
      child: Listener(
        onPointerDown: (event) => widget.onInteractionChanged(true),
        onPointerUp: (event) => widget.onInteractionChanged(false),
        onPointerCancel: (event) => widget.onInteractionChanged(false),
        onPointerMove: (event) {
          setState(() {
            if (onDragMode) {
              currentLeft += event.delta.dx;
              currentTop += event.delta.dy;
              currentLeft = currentLeft.clamp(0.0, canvasWidth - cardWidth);
              currentTop = currentTop.clamp(0.0, canvasHeight - cardHeight);
            } else {
              if (cardHeight > 100 && cardWidth > 100) {
                cardWidth = cardWidth + event.delta.dx;
                cardHeight = cardHeight + event.delta.dy;
              } else {
                cardHeight = 200;
                cardWidth = 200;
              }

              currentWidthPercent = (cardWidth / canvasWidth).clamp(0.5, 1);
              currentHeightPercent = (cardHeight / canvasHeight).clamp(0.5, 1);
              // print("Hi hi hi");
            }
          });
        },
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
              onDragMode = !onDragMode;
            });
          },
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: Stack(
              children: [
                DepartmentCard(
                  title: widget.title,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: onDragMode
                              ? [
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFF7C3AED),
                                ]
                              : [
                                  const Color(0xFFF59E0B),
                                  const Color(0xFFD97706),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (onDragMode
                                        ? const Color(0xFF8B5CF6)
                                        : const Color(0xFFF59E0B))
                                    .withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            onDragMode ? Icons.open_with : Icons.aspect_ratio,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            onDragMode ? 'DRAG MODE' : 'RESIZE MODE',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
