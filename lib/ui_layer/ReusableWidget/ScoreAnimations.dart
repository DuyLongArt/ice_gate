import 'package:flutter/material.dart';

class RollingScoreText extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final int decimalPlaces;

  const RollingScoreText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
    this.prefix = '',
    this.decimalPlaces = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (context, animatedValue, child) {
        return Text(
          "$prefix${animatedValue.toStringAsFixed(decimalPlaces)}",
          style: style,
        );
      },
    );
  }
}

class ScorePulseWrapper extends StatefulWidget {
  final Widget child;
  final num value;

  const ScorePulseWrapper({
    super.key,
    required this.child,
    required this.value,
  });

  @override
  State<ScorePulseWrapper> createState() => _ScorePulseWrapperState();
}

class _ScorePulseWrapperState extends State<ScorePulseWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  num? _previousValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticIn)),
        weight: 70,
      ),
    ]).animate(_controller);

    _glowAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(ScorePulseWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value > (_previousValue ?? 0)) {
      _controller.forward(from: 0.0);
    }
    _previousValue = widget.value;
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
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                if (_controller.isAnimating)
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(
                      0.5 * (1.0 - _controller.value),
                    ),
                    blurRadius: _glowAnimation.value,
                    spreadRadius: _glowAnimation.value / 2,
                  ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class LevelUpCelebration extends StatefulWidget {
  final int level;
  final VoidCallback onFinished;

  const LevelUpCelebration({
    super.key,
    required this.level,
    required this.onFinished,
  });

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(1.2), weight: 60),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInBack)),
        weight: 20,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: colorScheme.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: Color.fromARGB(255, 250, 233, 182),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "LEVEL UP!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    "Level ${widget.level}",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
