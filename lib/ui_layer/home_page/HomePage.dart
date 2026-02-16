import 'package:flutter/material.dart';
import 'package:ice_shield/data_layer/Protocol/Health/HealthMetricsData.dart';
import 'package:ice_shield/initial_layer/CoreLogics/GamificationService.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Home/InternalWidgetBlock.dart'
    show InternalWidgetBlock;
// import 'package:ice_shield/initial_layer/FireAPI/UrlNavigate.dart' as WidgetNavigatorAction;
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/AuthBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/PersonBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Widgets/ScoreBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/FinanceBlock.dart';
import 'package:ice_shield/ui_layer/health_page/models/HealthMetric.dart';
import 'package:pedometer/pedometer.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/GrowthBlock.dart';
import 'package:ice_shield/data_layer/Protocol/Home/InternalWidgetProtocol.dart';
import 'package:provider/provider.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart'
    hide ThemeData;
import 'package:go_router/go_router.dart';
import 'package:ice_shield/ui_layer/home_page/MainButton.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ice_shield/ui_layer/widget_page/AddPluginForm.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Home/ExternalWidgetBlock.dart';
import 'package:ice_shield/orchestration_layer/Action/WidgetNavigator.dart';
import 'package:ice_shield/ui_layer/ReusableWidget/SwipeablePage.dart';
import 'package:ice_shield/ui_layer/health_page/services/HealthService.dart';
import 'package:ice_shield/ui_layer/projects_page/CreateProjectDialog.dart';
import 'package:ice_shield/ui_layer/projects_page/TextEditorPage.dart';
import 'package:ice_shield/ui_layer/projects_page/ProjectsPage.dart';
import 'package:ice_shield/ui_layer/projects_page/ProjectDetailsPage.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Project/ProjectBlock.dart';
import 'package:ice_shield/ui_layer/ReusableWidget/ScoreAnimations.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  static Widget icon(BuildContext context, {double? size}) {
    return MainButton(
      type: "home",
      destination: "/",
      size: size,
      mainFunction: () => context.go("/"),
      icon: Icons.ac_unit,
      doubleClickFunction: () {
        print("double click");
        context.pop();
      },
      subButtons: [
        SubButton(
          icon: Icons.create_new_folder_rounded,
          backgroundColor: Colors.deepPurple,
          tooltip: "New Project",
          label: "Project",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const CreateProjectDialog(),
            );
          },
        ),
        SubButton(
          icon: Icons.folder_open_rounded,
          backgroundColor: Colors.blueAccent,
          tooltip: "View Projects",
          label: "Projects",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProjectsPage()),
            );
          },
        ),
        SubButton(
          icon: Icons.note_add_rounded,
          backgroundColor: Colors.orange,
          tooltip: "New Note",
          label: "Note",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TextEditorPage()),
            );
          },
        ),
      ],
    );
  }

  static Widget returnHomeIcon(BuildContext context, {double? size}) {
    return MainButton(
      type: "home",
      destination: "/",
      size: size,
      mainFunction: () => context.go("/"),
      icon: Icons.ac_unit,
      doubleClickFunction: () {
        print("double click");
        context.pop();
      },
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isEditMode = false;
  late AppDatabase database;
  late InternalWidgetBlock internalWidgetBlock;
  late AuthBlock authBlock;
  late PersonBlock personBlock;
  late HealthMetricsDAO healthMetricsDAO;
  late Map<String, HealthMetric> healthMetricsData = {};
  late Map<String, HealthMetric> financeMetricsData = {};
  late Map<String, HealthMetric> socialMetricsData = {};
  late ScoreBlock scoreBlock;
  late FinanceBlock financeBlock;
  late ExternalWidgetBlock externalWidgetBlock;
  late GrowthBlock growthBlock;
  EffectCleanup? _levelEffect;
  final _levelUpToShow = signal<int?>(null);

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  int currentSteps = 0;
  late double sizeOfWidget;

  @override
  void initState() {
    super.initState();

    database = context.read<AppDatabase>();
    internalWidgetBlock = context.read<InternalWidgetBlock>();
    externalWidgetBlock = context.read<ExternalWidgetBlock>();
    authBlock = context.read<AuthBlock>();
    scoreBlock = context.read<ScoreBlock>();
    authBlock.fetchUser();
    personBlock = context.read<PersonBlock>();
    growthBlock = context.read<GrowthBlock>();
    healthMetricsDAO = context.read<HealthMetricsDAO>();
    financeBlock = context.read<FinanceBlock>();

    _initPedometer();
    _fetchInitialData();

    // Level Up effect
    int? lastLevel;
    _levelEffect = effect(() {
      final currentLevel = scoreBlock.globalLevel.value;
      if (lastLevel != null && currentLevel > lastLevel!) {
        _levelUpToShow.value = currentLevel;
      }
      lastLevel = currentLevel;
    });
  }

  void _initPedometer() {
    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream
          .listen((event) {
            if (mounted) setState(() => currentSteps = event.steps);
          })
          .onError((error) => debugPrint('Step Count Error: $error'));

      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
      _pedestrianStatusStream
          .listen((event) {
            debugPrint("Pedestrian status: ${event.status}");
          })
          .onError((error) => debugPrint('Pedestrian Status Error: $error'));
    } catch (e) {
      debugPrint("Pedometer initialization error: $e");
    }
  }

  void _fetchInitialData() {
    final jwtValue = authBlock.jwt.value;
    if (jwtValue != null) {
      personBlock.fetchFromDatabase(jwtValue);
    }

    Future.microtask(() {
      internalWidgetBlock.refreshBlock(database.internalWidgetsDAO);
      externalWidgetBlock.refreshBlock(database.externalWidgetsDAO);

      HealthService.fetchStepCount().then((steps) {
        if (mounted) setState(() => currentSteps = steps);
      });

      HealthMetricsData.getMetricsByDay(DateTime.now(), context).then((
        newData,
      ) {
        if (mounted) {
          setState(() {
            healthMetricsData = newData;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _levelEffect?.call();
    super.dispose();
  }

  // 1. Handles the actual step count data
  void _navigateInternalUrl(String name) {
    if (name == '/projects') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const ProjectsPage()));
      return;
    }

    if (name.startsWith('/project/')) {
      final parts = name.split('/');
      if (parts.length > 2) {
        final id = int.tryParse(parts.last);
        if (id != null) {
          try {
            final project = context
                .read<ProjectBlock>()
                .projects
                .value
                .firstWhere((p) => p.projectID == id);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProjectDetailsPage(project: project),
              ),
            );
            return;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Project $id not found, opening Hub instead'),
              ),
            );
          }
        }
      }
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const ProjectsPage()));
      return;
    }
    context.push(name);
  }

  void _showAddPluginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: AddPluginForm(
          data: FormData(
            title: "Add App Plugin",
            description: "Choose a plugin to extend your dashboard",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    sizeOfWidget = MediaQuery.of(context).size.width * 0.25;
    sizeOfWidget = sizeOfWidget.clamp(100, 120);
    return SwipeablePage(
      onSwipe: () => Navigator.maybePop(context), // Use maybePop for safety
      direction: SwipeablePageDirection.leftToRight,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: SwipeablePage(
            onSwipe: () => context.pop(),
            child: AutoSizeText(
              widget.title,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                child: Icon(
                  Icons.person_outline,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              onPressed: () => context.go('/profile'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Watch((context) {
          final internalWidgets =
              internalWidgetBlock.listInternalWidgetHomePage.value;
          final externalWidgets = externalWidgetBlock.listExternalWidgets.value;

          return SwipeablePage(
            direction: SwipeablePageDirection.leftToRight,
            onSwipe: () => context.pop(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION: GAMIFIED HEADER ---
                  _buildGamifiedHeader(context),
                  const SizedBox(height: 24),

                  // --- SECTION: LIFE DASHBOARD ---
                  _buildSectionHeader(context, 'Life Dashboard', '/profile'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildQuickAccessCard(
                          context,
                          'Health',
                          Icons.favorite_rounded,
                          Colors.green,
                          '${healthMetricsData['steps']?.value ?? 0} steps•${healthMetricsData['food']?.value ?? 0} kcal',
                          '/health',
                          scoreBlock.score.healthGlobalScore,
                        ),
                        Watch((context) {
                          final balance = financeBlock.totalBalance.value;
                          final spending = financeBlock.monthlySpending.value;
                          return _buildQuickAccessCard(
                            context,
                            'Finance',
                            Icons.account_balance_wallet_rounded,
                            Colors.blue,
                            '\$${balance.toStringAsFixed(0)} •\$${spending.toStringAsFixed(0)} this mo',
                            '/finance',
                            scoreBlock.score.financialGlobalScore,
                          );
                        }),
                        StreamBuilder<List<PersonData>>(
                          stream: database.personDAO.getAllPersons(),
                          builder: (context, snapshot) {
                            final count = snapshot.data?.length ?? 0;
                            print('count: ${snapshot.data}');
                            return _buildQuickAccessCard(
                              context,
                              'Social',
                              Icons.people_alt_rounded,
                              Colors.purple,
                              '$count relationships',
                              '/social',
                              scoreBlock.score.socialGlobalScore,
                            );
                          },
                        ),
                        Watch((context) {
                          final projectGoals = growthBlock.goals.value
                              .where((g) => g.category == 'project')
                              .toList();
                          final activeCount = projectGoals
                              .where((g) => g.status != 'done')
                              .length;
                          final doneCount = projectGoals
                              .where((g) => g.status == 'done')
                              .length;

                          return _buildQuickAccessCard(
                            context,
                            'Projects',
                            Icons.rocket_launch_rounded,
                            Colors.orange,
                            '$activeCount active • $doneCount done',
                            '/projects',
                            scoreBlock.score.careerGlobalScore,
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- SECTION: QUICK ACCESS GRID ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        'Quick Access',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditMode = !_isEditMode;
                          });
                        },
                        child: Text(_isEditMode ? 'Done' : 'Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: sizeOfWidget,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(right: 20),
                      itemCount:
                          internalWidgets.length + externalWidgets.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: 110,
                              child: _buildAddButton(context),
                            ),
                          );
                        } else if (index <= internalWidgets.length) {
                          final widget = internalWidgets[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),

                            child: SizedBox(
                              width: 110,
                              child: _buildGridItem(context, widget),
                            ),
                          );
                        } else {
                          final ext =
                              externalWidgets[index -
                                  internalWidgets.length -
                                  1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: 110,
                              child: _buildExternalGridItem(context, ext),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- SECTION: RECENT ACTIVITY ---
                  AutoSizeText(
                    'Recent Insights',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),

                  // Placeholder for insights
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart Tip',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You\'ve been 20% more active this week. Keep it up!',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }),
        floatingActionButton: Watch((context) {
          final level = _levelUpToShow.value;
          if (level == null) return const SizedBox.shrink();
          return LevelUpCelebration(
            level: level,
            onFinished: () => _levelUpToShow.value = null,
          );
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildGamifiedHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final level = scoreBlock.globalLevel.value;
    final progress = scoreBlock.levelProgress.value;
    final rank = scoreBlock.rankTitle.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
            colorScheme.primary.withOpacity(0.6),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.onPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank.toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.9),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Level $level',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.onPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  color: colorScheme.onPrimary,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress to Level ${level + 1}',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.85),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AutoSizeText(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
        ),
        TextButton.icon(
          onPressed: () => context.go(route),
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          label: const Text('View All'),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
    String route,
    double scoreData,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final safeScore = scoreData.isFinite ? scoreData.toInt() : 0;
    final level = GamificationService.getLevel(safeScore);
    final progress = GamificationService.getProgressToNextLevel(safeScore);

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: color.withOpacity(0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(route),
          child: Stack(
            children: [
              // Glassmorphism Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.18),
                        color.withOpacity(0.08),
                        color.withOpacity(0.02),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Subtle Glow
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.2),
                                      blurRadius: 8,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: Icon(icon, color: color, size: 28),
                              ),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: ScorePulseWrapper(
                            value: scoreData,
                            child: Column(
                              key: ValueKey(title),
                              children: [
                                RollingScoreText(
                                  value: level,
                                  prefix: "LV ",
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                RollingScoreText(
                                  value: scoreData,
                                  prefix: "P: ",
                                  decimalPlaces: 1,
                                  style: TextStyle(
                                    color: color.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    AutoSizeText(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value.clamp(0.0, 1.0),
                            backgroundColor: color.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    AutoSizeText(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildGridItem(
    BuildContext context,
    InternalWidgetProtocol? widgetData,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widgetData == null) {
      return InkWell(
        onTap: () => _showAddPluginDialog(context),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 5,
              style: BorderStyle
                  .none, // Can change to solid for dashed effect if custom painter
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 5,
                    style: BorderStyle
                        .none, // Can change to solid for dashed effect if custom painter
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    final item = Container(
      width: 120,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.4),
          width: 5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(widgetData.icon, color: colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            widgetData.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );

    return Stack(
      children: [
        InkWell(
          onTap: _isEditMode
              ? () {
                  _showRenameInternalDialog(context, widgetData);
                }
              : () => _navigateInternalUrl(widgetData.url),
          borderRadius: BorderRadius.circular(20),
          child: item,
        ),
        if (_isEditMode) ...[
          Positioned(
            top: 5,
            right: 5,
            child: InkWell(
              onTap: () {
                // Logic to delete internal widget
                internalWidgetBlock.deleteWidget(
                  database.internalWidgetsDAO,
                  widgetData.name,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),

                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.4),
                    width: 5,
                  ),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 15,
            child: Text(
              "Tap to rename",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExternalGridItem(BuildContext context, ExternalWidgetData data) {
    final colorScheme = Theme.of(context).colorScheme;
    final String fullUrl = "${data.protocol}://${data.host}${data.url}";

    final item = Container(
      width: sizeOfWidget,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.4),
          width: 5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: Colors.blueAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            data.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );

    return Stack(
      children: [
        InkWell(
          onTap: _isEditMode
              ? () {
                  _showRenameExternalDialog(context, data);
                }
              : () {
                  WidgetNavigatorAction.navigateExternalUrl(context, fullUrl);
                },
          borderRadius: BorderRadius.circular(28),
          child: item,
        ),
        if (_isEditMode) ...[
          Positioned(
            top: 5,
            right: 5,
            child: InkWell(
              onTap: () {
                // Logic to delete external widget
                externalWidgetBlock.deleteWidget(
                  database.externalWidgetsDAO,
                  data.widgetID,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.4),
                    width: 5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 15,
            child: Text(
              "Tap to change name",
              style: TextStyle(
                color: Colors.white,
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showRenameInternalDialog(
    BuildContext context,
    InternalWidgetProtocol widgetData,
  ) {
    final controller = TextEditingController(text: widgetData.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Internal Widget'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Widget Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                internalWidgetBlock.renameWidget(
                  database.internalWidgetsDAO,
                  widgetData.name,
                  controller.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showRenameExternalDialog(
    BuildContext context,
    ExternalWidgetData data,
  ) {
    final controller = TextEditingController(text: data.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename External Widget'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Widget Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                externalWidgetBlock.renameWidget(
                  database.externalWidgetsDAO,
                  data.widgetID,
                  controller.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _showAddPluginDialog(context),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: colorScheme.primary, size: 32),
              const SizedBox(height: 4),
              Text(
                'Add',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
