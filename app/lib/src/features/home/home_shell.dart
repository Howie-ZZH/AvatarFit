import 'package:flutter/material.dart';

import '../../models/avatar_models.dart';
import '../../models/workout_models.dart';
import '../training/test_workout_page.dart';
import '../unity_bridge/unity_avatar_view.dart';
import '../unity_bridge/unity_bridge_service.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.avatar,
    required this.unity,
    required this.onRestartDemo,
  });

  final AvatarState avatar;
  final UnityBridgeService unity;
  final VoidCallback onRestartDemo;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _index = 0;
  late AvatarState _avatar;
  bool _showWorkout = false;
  bool _workoutCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _avatar = widget.avatar;
  }

  @override
  Widget build(BuildContext context) {
    if (_showWorkout) {
      return TestWorkoutPage(
        avatar: _avatar,
        unity: widget.unity,
        onCompleted: (updatedAvatar) {
          setState(() {
            _avatar = updatedAvatar;
            _showWorkout = false;
            _index = 0;
            _workoutCompletedToday = true;
          });
        },
      );
    }

    final pages = [
      _AvatarTab(
        avatar: _avatar,
        unity: widget.unity,
        workoutCompletedToday: _workoutCompletedToday,
      ),
      _TrainingTab(
        unity: widget.unity,
        workoutCompletedToday: _workoutCompletedToday,
        onStartWorkout: () => setState(() => _showWorkout = true),
      ),
      const _CourseTab(),
      const _CoachTab(),
      _MineTab(onRestartDemo: widget.onRestartDemo),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.accessibility_new_rounded),
            label: '角色',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_rounded),
            label: '训练',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_rounded),
            label: '课程',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_alt_rounded),
            label: '教练',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class _AvatarTab extends StatelessWidget {
  const _AvatarTab({
    required this.avatar,
    required this.unity,
    required this.workoutCompletedToday,
  });

  final AvatarState avatar;
  final UnityBridgeService unity;
  final bool workoutCompletedToday;

  @override
  Widget build(BuildContext context) {
    final attributes = {
      '力量': avatar.attributes.strength,
      '耐力': avatar.attributes.endurance,
      '核心': avatar.attributes.core,
      '柔韧': avatar.attributes.flexibility,
      '燃脂': avatar.attributes.fatBurn,
      '恢复': avatar.attributes.recovery,
    };

    final xpProgress =
        avatar.xpToNextLevel <= 0 ? 0.0 : avatar.xp / avatar.xpToNextLevel;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                avatar.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            IconButton(
              tooltip: '分享',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('分享图功能将在 Demo 打磨阶段接入')),
                );
              },
              icon: const Icon(Icons.ios_share_rounded),
            ),
          ],
        ),
        const SizedBox(height: 14),
        UnityAvatarView(
          avatar: avatar,
          animationKey: 'idle_confident',
        ),
        const SizedBox(height: 16),
        _WorkoutStatusLine(completed: workoutCompletedToday),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricLine(
                label: '等级',
                value: 'Lv.${avatar.level}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricLine(
                label: '状态',
                value: _energyLabel(avatar.energyState),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _XpProgressLine(
          xp: avatar.xp,
          xpToNextLevel: avatar.xpToNextLevel,
          progress: xpProgress.clamp(0, 1),
        ),
        const SizedBox(height: 18),
        Text('属性成长', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...attributes.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(width: 44, child: Text(entry.key)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (entry.value / 20).clamp(0, 1),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${entry.value}',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => unity.changeOutfit('outfit_starter_gloves'),
          icon: const Icon(Icons.checkroom_rounded),
          label: const Text('装备新手手套'),
        ),
      ],
    );
  }
}

class _TrainingTab extends StatelessWidget {
  const _TrainingTab({
    required this.unity,
    required this.workoutCompletedToday,
    required this.onStartWorkout,
  });

  final UnityBridgeService unity;
  final bool workoutCompletedToday;
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
      children: [
        Text('今日训练', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          workoutCompletedToday
              ? '今日训练已完成，可以再次演示训练流程。'
              : '预计 3 分钟，完成后获得 XP 和属性成长。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onStartWorkout,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('开始今日训练'),
        ),
        const SizedBox(height: 20),
        ...testWorkout.map(
          (exercise) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              tileColor: const Color(0xFF10141B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.play_circle_fill_rounded),
              title: Text(exercise.name),
              subtitle:
                  Text('${exercise.durationSeconds} 秒 · ${exercise.sets} 组'),
              trailing: IconButton(
                tooltip: '播放动作',
                onPressed: () => unity.playAnimation(exercise.animationKey),
                icon: const Icon(Icons.view_in_ar_rounded),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _energyLabel(String value) {
  return switch (value) {
    'confident' => '自信',
    'energized' => '活力充沛',
    'tired' => '疲劳',
    'normal' => '正常',
    _ => value,
  };
}

class _WorkoutStatusLine extends StatelessWidget {
  const _WorkoutStatusLine({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFFFFC857);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF10141B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF252B36)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              completed
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                completed ? '今日训练已完成' : '今日训练待完成',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _XpProgressLine extends StatelessWidget {
  const _XpProgressLine({
    required this.xp,
    required this.xpToNextLevel,
    required this.progress,
  });

  final int xp;
  final int xpToNextLevel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF10141B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF252B36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '升级进度',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text('$xp / $xpToNextLevel XP'),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}

class _CourseTab extends StatelessWidget {
  const _CourseTab();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderTab(
      title: '课程',
      body: '课程 API 接入后，这里展示减脂、增肌、塑形和体能课程。',
      icon: Icons.video_library_rounded,
    );
  }
}

class _CoachTab extends StatelessWidget {
  const _CoachTab();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderTab(
      title: 'AI 教练',
      body: '下一步接入后端 /api/ai/chat，根据目标和训练记录给建议。',
      icon: Icons.psychology_alt_rounded,
    );
  }
}

class _MineTab extends StatelessWidget {
  const _MineTab({required this.onRestartDemo});

  final VoidCallback onRestartDemo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_rounded,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text('我的', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              '个人资料、身体数据、成就、订阅和隐私设置预留在这里。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: onRestartDemo,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('重新开始 Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 18),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF10141B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF252B36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
