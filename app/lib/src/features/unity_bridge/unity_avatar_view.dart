import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api/api_config.dart';
import '../../models/avatar_models.dart';

const _useHeroArtworkPreview = bool.fromEnvironment(
  'FITGAME_USE_HERO_ARTWORK_PREVIEW',
  defaultValue: true,
);

class UnityAvatarView extends StatefulWidget {
  const UnityAvatarView({
    super.key,
    required this.avatar,
    this.animationKey = 'idle_default',
    this.compact = false,
    this.showDebugBadge = false,
  });

  final AvatarState avatar;
  final String animationKey;
  final bool compact;
  final bool showDebugBadge;

  @override
  State<UnityAvatarView> createState() => _UnityAvatarViewState();
}

class _UnityAvatarViewState extends State<UnityAvatarView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.compact ? 230.0 : 360.0;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: _useHeroArtworkPreview
          ? _HeroArtworkSurface(
              avatar: widget.avatar,
              animationKey: widget.animationKey,
              compact: widget.compact,
              controller: _controller,
              showDebugBadge: widget.showDebugBadge,
            )
          : (kUseNativeUnityView && (Platform.isAndroid || Platform.isIOS)
              ? _NativeUnitySurface(
                  avatar: widget.avatar,
                  animationKey: widget.animationKey,
                  showDebugBadge: widget.showDebugBadge,
                )
              : _MockUnitySurface(
                  avatar: widget.avatar,
                  animationKey: widget.animationKey,
                  compact: widget.compact,
                  controller: _controller,
                  showDebugBadge: widget.showDebugBadge,
                )),
    );
  }
}

class _HeroArtworkSurface extends StatelessWidget {
  const _HeroArtworkSurface({
    required this.avatar,
    required this.animationKey,
    required this.compact,
    required this.controller,
    required this.showDebugBadge,
  });

  final AvatarState avatar;
  final String animationKey;
  final bool compact;
  final AnimationController controller;
  final bool showDebugBadge;

  @override
  Widget build(BuildContext context) {
    final isIntro = animationKey == 'intro_hero';
    final isWorkout =
        animationKey.startsWith('workout') || animationKey == 'START_EXERCISE';
    final avatarName = avatar.name.trim().isEmpty ? 'Rex' : avatar.name.trim();
    final avatarLevel = avatar.level <= 0 ? 1 : avatar.level;
    final imageHeight = compact
        ? 218.0
        : isIntro
            ? 500.0
            : 342.0;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF05080B),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TrainingSpacePainter(),
            ),
          ),
          Positioned(
            top: compact
                ? 12
                : isIntro
                    ? 76
                    : 16,
            child: Text(
              'Lv.$avatarLevel $avatarName',
              style: (isIntro
                      ? Theme.of(context).textTheme.headlineMedium
                      : Theme.of(context).textTheme.titleMedium)
                  ?.copyWith(
                color: Colors.white,
                letterSpacing: 0,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final wave = math.sin(controller.value * math.pi);
              final lift = wave * (isWorkout ? 14 : 7);
              final scale = 1 + wave * (isWorkout ? 0.018 : 0.01);
              return Transform.translate(
                offset: Offset(0, -lift),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: compact ? 4 : 0),
                child: Image.asset(
                  'assets/images/avatar_hero_fitgame.png',
                  height: imageHeight,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          if (showDebugBadge)
            Positioned(
              left: 18,
              top: 18,
              child: _UnityBadge(animationKey: animationKey),
            ),
        ],
      ),
    );
  }
}

class _NativeUnitySurface extends StatelessWidget {
  const _NativeUnitySurface({
    required this.avatar,
    required this.animationKey,
    required this.showDebugBadge,
  });

  final AvatarState avatar;
  final String animationKey;
  final bool showDebugBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (Platform.isAndroid)
          AndroidView(
            viewType: 'fitgame/unity_view',
            creationParams: _creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
        else
          UiKitView(
            viewType: 'fitgame/unity_view',
            creationParams: _creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          ),
        if (showDebugBadge)
          Positioned(
            left: 18,
            top: 18,
            child: _UnityBadge(animationKey: animationKey),
          ),
      ],
    );
  }

  Map<String, Object?> get _creationParams => {
        'avatar': avatar.toUnityPayload(),
        'animationKey': animationKey,
      };
}

class _MockUnitySurface extends StatelessWidget {
  const _MockUnitySurface({
    required this.avatar,
    required this.animationKey,
    required this.compact,
    required this.controller,
    required this.showDebugBadge,
  });

  final AvatarState avatar;
  final String animationKey;
  final bool compact;
  final AnimationController controller;
  final bool showDebugBadge;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF080A0D),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TrainingSpacePainter(),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final lift = math.sin(controller.value * math.pi) * 10;
              return Transform.translate(
                offset: Offset(0, -lift),
                child: child,
              );
            },
            child: _AvatarSilhouette(
              energyState: avatar.energyState,
              animationKey: animationKey,
              compact: compact,
            ),
          ),
          if (showDebugBadge)
            Positioned(
              left: 18,
              top: 18,
              child: _UnityBadge(animationKey: animationKey),
            ),
          Positioned(
            right: 18,
            bottom: 18,
            child: Text(
              'Lv.${avatar.level}  ${avatar.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarSilhouette extends StatelessWidget {
  const _AvatarSilhouette({
    required this.energyState,
    required this.animationKey,
    required this.compact,
  });

  final String energyState;
  final String animationKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = energyState == 'confident'
        ? const Color(0xFFFFC857)
        : Theme.of(context).colorScheme.primary;
    final scale = compact ? 0.82 : 1.0;
    final isWorkout =
        animationKey.startsWith('workout') || animationKey == 'START_EXERCISE';

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 180,
        height: 292,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 118,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(88),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withValues(alpha: 0.85),
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.34),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF111827),
                  border: Border.all(color: accent, width: 3),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: isWorkout ? 4 : 20,
              child: _Limb(
                width: 30,
                height: 118,
                angle: isWorkout ? -0.72 : -0.22,
                color: accent,
              ),
            ),
            Positioned(
              top: 100,
              right: isWorkout ? 2 : 20,
              child: _Limb(
                width: 30,
                height: 118,
                angle: isWorkout ? 0.82 : 0.22,
                color: accent,
              ),
            ),
            Positioned(
              bottom: 6,
              left: 48,
              child: _Limb(
                width: 34,
                height: 120,
                angle: isWorkout ? 0.24 : 0.08,
                color: const Color(0xFF334155),
              ),
            ),
            Positioned(
              bottom: 6,
              right: 48,
              child: _Limb(
                width: 34,
                height: 120,
                angle: isWorkout ? -0.3 : -0.08,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Limb extends StatelessWidget {
  const _Limb({
    required this.width,
    required this.height,
    required this.angle,
    required this.color,
  });

  final double width;
  final double height;
  final double angle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width),
          color: color.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}

class _UnityBadge extends StatelessWidget {
  const _UnityBadge({required this.animationKey});

  final String animationKey;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC10141B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF293241)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.view_in_ar_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              animationKey,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingSpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF1F2937);
    final floorY = size.height * 0.78;
    canvas.drawLine(Offset(0, floorY), Offset(size.width, floorY), paint);

    for (var i = 0; i < 7; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(
        Offset(x, floorY),
        Offset(size.width / 2, size.height),
        paint,
      );
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF22D3A6).withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.56),
          radius: size.width * 0.46,
        ),
      );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.56),
      size.width * 0.46,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
