import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/DataSeeder.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/DatabaseAgent.dart'
    as DatabaseAgent;
import 'package:ice_shield/data_layer/Protocol/Canvas/ExternalWidgetProtocol.dart';
import 'package:ice_shield/initial_layer/CoreLogics/CustomAuthService.dart';
import 'package:ice_shield/initial_layer/CoreLogics/PasskeyAuthService.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/PersonBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/FinanceBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/GrowthBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/ContentBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/WidgetSettingsBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/AuthBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Home/InternalWidgetBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Home/ExternalWidgetBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/ObjectDatabaseBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Project/ProjectBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/FocusBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Widgets/ScoreBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Canvas/WidgetManagerBlock.dart';
import 'package:ice_shield/security_routing_layer/Routing/url_route/InternalRoute.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';

// Note: We are assuming AppDatabase and ExternalWidgetsDAO are defined in this file.
// We'll use dynamic type hints until we know the exact import path for those types.

// To make this runnable, I will use AppDatabase as the type, but if you need
// AppDatabase, you must ensure the import matches the actual file path.

// 1. Convert to StatefulWidget to manage the database lifecycle internally.
class DataLayer extends StatefulWidget {
  final Widget childWidget;
  final AppDatabase database;
  // Blocks should be in State if they are initialized there.
  // late PersonBlock personBlock; // Removed
  // late AuthBlock authBlock; // Removed
  // late ObjectDatabaseBlock objectDatabaseBlock; // Removed

  // The database is no longer passed in the constructor.
  const DataLayer({
    super.key,
    required this.database,
    required this.childWidget,
  });

  @override
  State<DataLayer> createState() => _DataLayerState();
}

class _DataLayerState extends State<DataLayer> {
  // 2. Declare the database instance using 'late final'.
  // 'late' guarantees it will be initialized before its first use.
  // late final AppDatabase database;

  late PersonBlock personBlock;
  late AuthBlock authBlock;
  late ObjectDatabaseBlock objectDatabaseBlock;
  late ScoreBlock scoreBlock;
  late WidgetManagerBlock widgetManagerBlock;
  late GrowthBlock growthBlock;
  late FocusBlock focusBlock;

  late Stream<StepCount> _stepCountStream;
  // late Stream<PedestrianStatus> _pedestrianStatusStream; // Removed

  late HealthMetricsDAO healthMetricsDAO;
  // late StreamSubscription<StepCount> _stepSubscription; // Removed
  int currentSteps = 0;

  @override
  void initState() {
    super.initState();

    // 1. Keep initState() synchronous.
    initPedometer();

    _initializeData();
  }

  void initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(_onStepCount, onError: _onStepCountError);
  }

  void _onStepCount(StepCount event) {
    debugPrint("Sensor updated: ${event.steps}");

    setState(() {
      // Note: event.steps is total steps since last phone reboot
      currentSteps = event.steps;
    });

    // Automatically update your database score
    // _updateDatabaseScore(event.steps);
  }

  void _onStepCountError(error) {
    debugPrint("Pedometer Error: $error");
  }

  // 2. Create an async helper function to perform setup.
  Future<void> _initializeData() async {
    // Use a try-catch block for robust error handling during async setup.
    try {
      // 3. Initialize the database instance internally.
      // database = AppDatabase();

      // --- Database and Asset Loading ---
      var baseUrl = "https://backend.duylong.art";
      var authService = CustomAuthService(baseUrl: baseUrl);
      var passkeyService = PasskeyAuthService();

      // Initialize Blocks
      personBlock = PersonBlock(authService: authService);
      authBlock = AuthBlock(
        authService: authService,
        sessionDao: widget.database.sessionDAO,
        passkeyService: passkeyService,
        personDao: widget.database.personManagementDAO,
      );
      healthMetricsDAO = widget.database.healthMetricsDAO;

      // int steps = 0;3

      DateTime now = DateTime.now();
      print("currentSteps: $currentSteps");
      healthMetricsDAO.insertOrUpdateMetrics(
        HealthMetricsTableCompanion(
          steps: Value(currentSteps),
          date: Value(now),
        ),
      );

      // Initialize GrowthBlock
      growthBlock = GrowthBlock()..init(widget.database.growthDAO, 1);

      // Initialize ScoreBlock
      scoreBlock = ScoreBlock()
        ..init(
          widget.database.scoreDAO,
          widget.database.personManagementDAO,
          widget.database.financeDAO,
          widget.database.healthMetricsDAO,
          widget.database.healthMealDAO,
          1,
        );

      // Initialize FocusBlock
      focusBlock =
          FocusBlock(
              focusSessionDao: widget.database.focusSessionsDAO,
              personId: 1, // Default to 1 for now
            )
            ..growthBlock = growthBlock
            ..scoreBlock = scoreBlock;

      // widget.database.scoreDAO.insertOrUpdateScore(ScoreLocalData(personID: 1, healthGlobalScore: 0, socialGlobalScore: 0, financialGlobalScore: 0, careerGlobalScore: 0, createdAt: DateTime.now(), updatedAt: DateTime.now(), scoreID: 1));

      // Initialize ObjectDatabaseBlock
      objectDatabaseBlock = ObjectDatabaseBlock();

      widgetManagerBlock = WidgetManagerBlock(
        widgetDao: widget.database.widgetDAO,
        personIdSignal: computed(
          () => personBlock.information.value.profiles.id,
        ),
      );

      // Check session immediately on startup
      authBlock.checkSession(context);

      // Await asset loading
      String jsonString = await rootBundle.loadString(
        "assets/LightThemePurple.json",
      );
      // print(jsonString);

      ExternalWidgetProtocol externalWidgetProtocol = ExternalWidgetProtocol(
        name: '',
        protocol: '',
        host: '',
        url: '',
      );
      // Await database operations
      await widget.database.externalWidgetsDAO.insertNewWidget(
        externalWidgetProtocol: externalWidgetProtocol,
      );

      await widget.database.themesTableDAO.insertNewTheme(
        name: "Light theme",
        jsonContent: jsonString,
        author: "Duy Long",
      );

      // --- NEW: Seed Data ---
      // print("Seed data started");
      await DataSeeder.seed(widget.database);
      // print("Seed data completed");

      // 4. Optionally, notify the UI that loading is complete if needed
      // (e.g., using setState if a loading indicator is present).
      setState(() {}); // Rebuild to provide initialized blocks
    } catch (e) {
      // Handle any initialization errors gracefully (e.g., logging)
      print("Initialization error: $e");
      // You might want to display an error to the user here
    }

    // --- NEW: Monitoring --- Agent
    await DatabaseAgent.monitoring(widget.database);

    // --- NEW: Global Data Initializer ---
    // Listen to AuthBlock token changes to trigger initial data fetch
    effect(() {
      final token = authBlock.jwt.value;
      if (token != null && token.isNotEmpty) {
        personBlock.fetchInitialData(token).then((_) {
          // Update object database urls after initial fetch
          objectDatabaseBlock.updateUrlOfUser(personBlock);
        });
      }
    });

    // Bridge AuthBlock status to GoRouter refresh notifier
    effect(() {
      authStatusNotifier.value = authBlock.status.value;
    });
  }

  @override
  void dispose() {
    // OPTIONAL: It's good practice to close the database when the root widget dies.
    // database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only build MultiProvider if blocks are initialized to avoid LateInitializationError
    // But since we are providing them, and they are late, we need to be careful.
    // effectively they are initialized in initState -> _initializeData (sync part starts).
    // But _initializeData has async parts. personBlock, authBlock are sync initialized before async await.
    // So usually safe.

    return MultiProvider(
      providers: [
        // 1. Provider for the main database instance.
        // The type provided is AppDatabase (your database class).
        Provider<AppDatabase>(
          create: (_) =>
              widget.database, // Use the internally initialized field
        ),

        // 2. Provider for the DAO instance.
        // The type provided is ExternalWidgetDao (your DAO class).
        Provider<ExternalWidgetsDAO>(
          // Access the DAO getter from the database instance.
          create: (context) => widget.database.externalWidgetsDAO,
        ),

        // 3. Provider for ProjectNoteDAO
        Provider<ProjectNoteDAO>(
          create: (context) => widget.database.projectNoteDAO,
        ),
        Provider<InternalWidgetsDAO>(
          create: (context) => widget.database.internalWidgetsDAO,
        ),

        // 3. StreamProvider to watch the live list of data. (For READ operations)
        StreamProvider<List<ExternalWidgetData>>(
          create: (context) =>
              widget.database.externalWidgetsDAO.watchAllWidgets(),
          initialData: const [],
          catchError: (_, error) {
            debugPrint('Error watching widgets: $error');
            return const [];
          },
        ),

        // --- NEW: DAOs ---
        Provider<PersonManagementDAO>(
          create: (_) => widget.database.personManagementDAO,
        ),
        Provider<FinanceDAO>(create: (_) => widget.database.financeDAO),
        Provider<GrowthDAO>(create: (_) => widget.database.growthDAO),
        Provider<ContentDAO>(create: (_) => widget.database.contentDAO),
        Provider<WidgetDAO>(create: (_) => widget.database.widgetDAO),
        Provider<HealthMetricsDAO>(
          create: (_) => widget.database.healthMetricsDAO,
        ),
        Provider<ProjectsDAO>(create: (_) => widget.database.projectsDAO),
        Provider<ScoreDAO>(create: (_) => widget.database.scoreDAO),

        // --- NEW: Reactive Blocks ---
        // PersonBlock (Load user ID 1 by default)
        Provider<PersonBlock>(create: (_) => personBlock),

        // AuthBlock
        Provider<AuthBlock>(create: (_) => authBlock),

        // ObjectDatabaseBlock
        Provider<ObjectDatabaseBlock>(create: (_) => objectDatabaseBlock),

        // FinanceBlock
        Provider<FinanceBlock>(
          create: (_) => FinanceBlock()..init(widget.database.financeDAO, 1),
          dispose: (_, block) => block.dispose(),
        ),

        // GrowthBlock
        Provider<GrowthBlock>.value(value: growthBlock),

        // ContentBlock
        Provider<ContentBlock>(
          create: (_) => ContentBlock()..init(widget.database.contentDAO, 1),
          dispose: (_, block) => block.dispose(),
        ),
        Provider<HealthMealDAO>(create: (_) => widget.database.healthMealDAO),

        // WidgetSettingsBlock
        Provider<WidgetSettingsBlock>(
          create: (_) =>
              WidgetSettingsBlock()..init(widget.database.widgetDAO, 1),
          dispose: (_, block) => block.dispose(),
        ),

        Provider<ScoreBlock>.value(value: scoreBlock),
        Provider<ProjectBlock>(
          create: (_) => ProjectBlock()..init(widget.database.projectsDAO, 1),
          dispose: (_, block) => block.dispose(),
        ),
        Provider<InternalWidgetBlock>(create: (_) => InternalWidgetBlock()),
        Provider<ExternalWidgetBlock>(create: (_) => ExternalWidgetBlock()),
        Provider<WidgetManagerBlock>(create: (_) => widgetManagerBlock),

        // --- Focus ---
        Provider<FocusSessionsDAO>(
          create: (_) => widget.database.focusSessionsDAO,
        ),
        Provider<FocusBlock>.value(value: focusBlock..init()),
      ],
      // Use MaterialApp as the child and WidgetConsumer as the home screen.
      child: widget.childWidget,
    );
  }
}
