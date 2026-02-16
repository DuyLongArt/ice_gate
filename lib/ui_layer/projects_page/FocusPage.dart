import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Project/ProjectBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/FocusBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/GrowthBlock.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  static Widget icon(BuildContext context, {double? size}) {
    final focusBlock = context.watch<FocusBlock>();
    final isRunning = focusBlock.isRunning.watch(context);

    return Tooltip(
      message: isRunning ? 'Focusing...' : 'Focus Timer',
      child: IconButton(
        icon: Icon(
          isRunning ? Icons.pause_circle_filled_rounded : Icons.timer_rounded,
          color: isRunning ? Theme.of(context).colorScheme.primary : null,
        ),
        iconSize: size,
        onPressed: () => context.push('/health/focus'),
      ),
    );
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final focusBlock = context.watch<FocusBlock>();
    final projectBlock = context.watch<ProjectBlock>();
    final growthBlock = context.watch<GrowthBlock>();

    final timeStr = formatTime(focusBlock.remainingTime.watch(context));
    final isRunning = focusBlock.isRunning.watch(context);
    final sessionType = focusBlock.currentSessionType.watch(context);
    final totalStudyTime = focusBlock.totalStudyTimeToday.watch(context);
    final sessionsCount = focusBlock.sessionsCompletedToday.watch(context);
    final selectedProjId = focusBlock.selectedProjectId.watch(context);
    final selectedTaskId = focusBlock.selectedTaskId.watch(context);

    // Dynamic Colors based on mode
    final modeColor = sessionType == 'Focus'
        ? colorScheme.primary
        : Colors.teal;
    final modeBg = sessionType == 'Focus'
        ? colorScheme.primaryContainer.withOpacity(0.1)
        : Colors.teal.withOpacity(0.1);

    final focusMin = focusBlock.focusDuration.watch(context);
    final shortMin = focusBlock.shortBreakDuration.watch(context);
    final longMin = focusBlock.longBreakDuration.watch(context);

    int totalDuration = focusMin * 60;
    if (sessionType == 'Short Break') totalDuration = shortMin * 60;
    if (sessionType == 'Long Break') totalDuration = longMin * 60;

    double progress = totalDuration > 0
        ? (totalDuration - focusBlock.remainingTime.value) / totalDuration
        : 1.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // 1. Dynamic Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.surface, modeBg, colorScheme.surface],
              ),
            ),
          ),

          Positioned(
            top: -50,
            left: -50,
            child: _BlurCircle(color: modeColor.withOpacity(0.15), size: 300),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: _BlurCircle(color: modeColor.withOpacity(0.1), size: 400),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Focus Space",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        _SessionTypeToggle(focusBlock: focusBlock),
                      ],
                    ),
                  ),
                ),

                // Selection Area (Project & Task)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        _ProjectSelector(
                          focusBlock: focusBlock,
                          projectBlock: projectBlock,
                          selectedProjId: selectedProjId,
                        ),
                        const SizedBox(height: 12),
                        _TaskSelector(
                          focusBlock: focusBlock,
                          growthBlock: growthBlock,
                          selectedProjId: selectedProjId,
                          selectedTaskId: selectedTaskId,
                        ),
                      ],
                    ),
                  ),
                ),

                // Timer Main Component
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const Spacer(),
                      _TimerCircle(
                        progress: progress,
                        timeStr: timeStr,
                        modeColor: modeColor,
                        sessionType: sessionType,
                        isRunning: isRunning,
                        focusBlock: focusBlock,
                        totalDuration: totalDuration,
                      ),
                      const Spacer(),

                      // Detailed Controls Consolidated into Circle
                      const SizedBox(height: 40),
                      const SizedBox(height: 40),

                      // Stats & History Preview
                      _StatsGrid(
                        sessionsCount: sessionsCount,
                        totalStudyTime: totalStudyTime,
                        modeColor: modeColor,
                      ),

                      const SizedBox(height: 24),

                      _RecentHistoryHeader(),
                    ],
                  ),
                ),

                // History List
                StreamBuilder<List<FocusSessionData>>(
                  stream: context
                      .read<FocusSessionsDAO>()
                      .watchSessionsByPerson(1),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    final sessions = snapshot.data!.reversed.take(5).toList();
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _HistoryItem(
                            session: sessions[index],
                            modeColor: modeColor,
                          ),
                          childCount: sessions.length,
                        ),
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _TimerControls extends StatelessWidget {
  final FocusBlock focusBlock;
  final bool isRunning;
  final int totalDuration;
  final Color modeColor;

  const _TimerControls({
    required this.focusBlock,
    required this.isRunning,
    required this.totalDuration,
    required this.modeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () => focusBlock.resetTimer(),
          icon: const Icon(Icons.refresh_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        const SizedBox(width: 24),
        FloatingActionButton.large(
          onPressed: () =>
              isRunning ? focusBlock.pauseTimer() : focusBlock.startTimer(),
          backgroundColor: modeColor,
          foregroundColor: Colors.white,
          elevation: 8,
          child: Icon(
            isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 40,
          ),
        ),
        const SizedBox(width: 24),
        IconButton.filled(
          onPressed: () => _showSettings(context),
          icon: const Icon(Icons.settings_suggest_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TimerSettingsSheet(focusBlock: focusBlock),
    );
  }
}

class _SessionTypeToggle extends StatelessWidget {
  final FocusBlock focusBlock;
  const _SessionTypeToggle({required this.focusBlock});

  @override
  Widget build(BuildContext context) {
    final type = focusBlock.currentSessionType.watch(context);
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'Focus',
          icon: Icon(Icons.bolt, size: 16),
          label: Text('Focus'),
        ),
        ButtonSegment(
          value: 'Short Break',
          icon: Icon(Icons.coffee, size: 16),
          label: Text('Break'),
        ),
      ],
      selected: {type == 'Long Break' ? 'Short Break' : type},
      onSelectionChanged: (val) => focusBlock.setSessionType(val.first),
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _ProjectSelector extends StatelessWidget {
  final FocusBlock focusBlock;
  final ProjectBlock projectBlock;
  final int? selectedProjId;

  const _ProjectSelector({
    required this.focusBlock,
    required this.projectBlock,
    required this.selectedProjId,
  });

  @override
  Widget build(BuildContext context) {
    final projects = projectBlock.projects.watch(context);
    final selectedProject = projects
        .where((p) => p.projectID == selectedProjId)
        .firstOrNull;

    return GestureDetector(
      onTap: () => _showProjectPicker(context, projects),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selectedProject?.color != null
                    ? Color(int.parse(selectedProject!.color!))
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedProject?.name ?? "Select Project",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  void _showProjectPicker(BuildContext context, List<dynamic> projects) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choose Project",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final p = projects[index];
                  return ListTile(
                    leading: Icon(
                      Icons.folder,
                      color: p.color != null
                          ? Color(int.parse(p.color!))
                          : Colors.grey,
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: selectedProjId == p.projectID
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      focusBlock.setProject(p.projectID);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskSelector extends StatelessWidget {
  final FocusBlock focusBlock;
  final GrowthBlock growthBlock;
  final int? selectedProjId;
  final int? selectedTaskId;

  const _TaskSelector({
    required this.focusBlock,
    required this.growthBlock,
    required this.selectedProjId,
    required this.selectedTaskId,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedProjId == null) return const SizedBox.shrink();

    final tasks = growthBlock.goals
        .watch(context)
        .where((g) => g.projectID == selectedProjId && g.status != 'done')
        .toList();

    final selectedTask = tasks
        .where((t) => t.goalID == selectedTaskId)
        .firstOrNull;

    return GestureDetector(
      onTap: () => _showTaskPicker(context, tasks),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.checklist_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedTask?.title ?? "Select Active Task",
                style: TextStyle(
                  fontWeight: selectedTask != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedTask != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  void _showTaskPicker(BuildContext context, List<dynamic> tasks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Ongoing Task",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No active tasks for this project"),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final t = tasks[index];
                    return ListTile(
                      leading: const Icon(Icons.task_alt_rounded),
                      title: Text(
                        t.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: t.description != null
                          ? Text(
                              t.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: selectedTaskId == t.goalID
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        focusBlock.setTask(t.goalID);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.add_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text(
                "Create New Task",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _showCreateTaskDialog(
                  context,
                  focusBlock,
                  growthBlock,
                  selectedProjId,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTaskDialog(
    BuildContext context,
    FocusBlock focusBlock,
    GrowthBlock growthBlock,
    int? projectId,
  ) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Task Title",
                hintText: "What are you focusing on?",
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description (Optional)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await growthBlock.createNewTask(
                  titleController.text,
                  descController.text,
                  projectID: projectId,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}

class _TimerCircle extends StatelessWidget {
  final double progress;
  final String timeStr;
  final Color modeColor;
  final String sessionType;
  final bool isRunning;
  final FocusBlock focusBlock;
  final int totalDuration;

  const _TimerCircle({
    required this.progress,
    required this.timeStr,
    required this.modeColor,
    required this.sessionType,
    required this.isRunning,
    required this.focusBlock,
    required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated Ring
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, _) => SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: 1.0 - value,
              strokeWidth: 12,
              backgroundColor: modeColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(modeColor),
              strokeCap: StrokeCap.round,
            ),
          ),
        ),

        // Pulsing & Breathing Effect
        if (isRunning) ...[
          _PulsingRing(color: modeColor),
          _BreathingCircle(color: modeColor),
        ],

        // Content
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeStr,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                fontFeatures: [const FontFeature.tabularFigures()],
                color: modeColor,
              ),
            ),
            const SizedBox(height: 12),
            _TimerControls(
              focusBlock: focusBlock,
              isRunning: isRunning,
              totalDuration: totalDuration,
              modeColor: modeColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _PulsingRing extends StatefulWidget {
  final Color color;
  const _PulsingRing({required this.color});

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: 280 + (40 * _controller.value),
        height: 280 + (40 * _controller.value),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withOpacity(1.0 - _controller.value),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _TimerSettingsSheet extends StatelessWidget {
  final FocusBlock focusBlock;
  const _TimerSettingsSheet({required this.focusBlock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusMin = focusBlock.focusDuration.watch(context);
    final shortMin = focusBlock.shortBreakDuration.watch(context);
    final longMin = focusBlock.longBreakDuration.watch(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings_suggest_rounded, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Timer Settings",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DurationSlider(
                label: "Focus Duration",
                value: focusMin,
                max: 60,
                min: 1,
                color: theme.colorScheme.primary,
                onChanged: (val) => focusBlock.setDurations(focus: val.toInt()),
              ),
              const SizedBox(height: 16),
              _DurationSlider(
                label: "Short Break",
                value: shortMin,
                max: 30,
                min: 1,
                color: Colors.teal,
                onChanged: (val) => focusBlock.setDurations(short: val.toInt()),
              ),
              const SizedBox(height: 16),
              _DurationSlider(
                label: "Long Break",
                value: longMin,
                max: 45,
                min: 5,
                color: Colors.blue,
                onChanged: (val) => focusBlock.setDurations(long: val.toInt()),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  final String label;
  final int value;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;

  const _DurationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              "$value min",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color.withOpacity(0.5),
            inactiveTrackColor: color.withOpacity(0.1),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int sessionsCount;
  final int totalStudyTime;
  final Color modeColor;

  const _StatsGrid({
    required this.sessionsCount,
    required this.totalStudyTime,
    required this.modeColor,
  });

  @override
  Widget build(BuildContext context) {
    final hrs = totalStudyTime ~/ 3600;
    final mins = (totalStudyTime % 3600) ~/ 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatBox(
                label: "Sessions",
                value: "$sessionsCount",
                icon: Icons.bolt_rounded,
                color: modeColor,
              ),
            ),
            const VerticalDivider(width: 32, indent: 10, endIndent: 10),
            Expanded(
              child: _StatBox(
                label: "Focus Time",
                value: hrs > 0 ? "${hrs}h ${mins}m" : "${mins}m",
                icon: Icons.schedule_rounded,
                color: modeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _RecentHistoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("View All", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final FocusSessionData session;
  final Color modeColor;
  const _HistoryItem({required this.session, required this.modeColor});

  @override
  Widget build(BuildContext context) {
    final mins = session.durationSeconds ~/ 60;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: modeColor, size: 18),
          const SizedBox(width: 12),
          Text(
            DateFormat('HH:mm').format(session.startTime),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Text("${mins}m Focus Session"),
          const Spacer(),
          Text(
            DateFormat('MMM d').format(session.startTime),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathingCircle extends StatefulWidget {
  final Color color;
  const _BreathingCircle({required this.color});

  @override
  State<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<_BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(0.05),
        ),
      ),
    );
  }
}
