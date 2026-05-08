import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/home/home_shell.dart';
import '../../features/training/test_workout_page.dart';
import '../../features/unity_bridge/native_unity_bridge_service.dart';
import '../../features/unity_bridge/unity_avatar_view.dart';
import '../../features/unity_bridge/unity_bridge_service.dart';
import '../../api/api_config.dart';
import '../../models/avatar_models.dart';
import '../../models/onboarding_models.dart';
import '../../services/auth_service.dart';
import '../../services/avatar_service.dart';
import '../../services/profile_service.dart';
import '../../services/workout_service.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final UnityBridgeService _unity = kUseNativeUnityView
      ? NativeUnityBridgeService()
      : MockUnityBridgeService();
  final AuthService _authService = createAuthService();
  AvatarState _avatar = const AvatarState();
  BodyProfileDraft _bodyProfile = const BodyProfileDraft();
  StreamSubscription? _unityEventsSubscription;
  String? _accessToken;
  String? _error;
  String? _unityStatus;
  bool _isBusy = false;
  int _step = 0;
  String _goal = '减脂';
  String _experience = 'beginner';

  @override
  void initState() {
    super.initState();
    _unityEventsSubscription = _unity.events.listen((event) {
      if (!mounted) {
        return;
      }
      setState(() {
        _unityStatus = event.success
            ? 'Unity: ${event.type}'
            : 'Unity: ${event.type} ${event.error ?? ''}';
      });
    });
    _unity.setAvatarState(_avatar);
  }

  @override
  void dispose() {
    _unityEventsSubscription?.cancel();
    _unity.dispose();
    super.dispose();
  }

  void _next() => setState(() => _step += 1);

  Future<void> _submitAuth(AuthCredentials credentials, bool login) async {
    await _runStep(() async {
      final session = login
          ? await _authService.login(credentials)
          : await _authService.register(credentials);
      if (!mounted) {
        return;
      }
      setState(() {
        _accessToken = session.accessToken;
        _step += 1;
      });
    });
  }

  Future<void> _createAvatar(CreateAvatarDraft draft) async {
    await _runStep(() async {
      final service = createAvatarService(accessToken: _accessToken);
      final avatar = await service.createAvatar(draft, current: _avatar);
      await _unity.setAvatarState(avatar);
      if (!mounted) {
        return;
      }
      setState(() {
        _avatar = avatar;
        _step += 1;
      });
    });
  }

  Future<void> _submitProfileForGoal(String goal) async {
    await _runStep(() async {
      _goal = goal;
      _bodyProfile = _bodyProfile.copyWith(
        fitnessGoal: goal,
        trainingExperience: _experience,
      );
      final service = createProfileService(accessToken: _accessToken);
      final profile = await service.saveProfile(_bodyProfile);
      if (!mounted) {
        return;
      }
      setState(() {
        _bodyProfile = profile;
        _step += 1;
      });
    });
  }

  Future<void> _runStep(Future<void> Function() action) async {
    if (_isBusy) {
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = '$error');
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      0 => _SplashStep(onStart: _next, avatar: _avatar),
      1 => _AuthStep(
          isBusy: _isBusy,
          error: _error,
          onSubmit: _submitAuth,
        ),
      2 => _BodyProfileStep(
          profile: _bodyProfile,
          error: _error,
          experience: _experience,
          onChanged: (profile) => setState(() => _bodyProfile = profile),
          onExperienceChanged: (value) => setState(() {
            _experience = value;
            _bodyProfile = _bodyProfile.copyWith(trainingExperience: value);
          }),
          onNext: _next,
        ),
      3 => _GoalStep(
          goal: _goal,
          onGoalChanged: (value) => setState(() => _goal = value),
          isBusy: _isBusy,
          error: _error,
          onNext: () => _submitProfileForGoal(_goal),
        ),
      4 => _CreateAvatarStep(
          avatar: _avatar,
          isBusy: _isBusy,
          error: _error,
          onPreviewChanged: (draft) => setState(
            () => _avatar = draft.toLocalAvatar(_avatar),
          ),
          onNext: _createAvatar,
        ),
      5 => _InitialAvatarStep(
          avatar: _avatar,
          goal: _goal,
          unityStatus: _unityStatus,
          onStartWorkout: _next,
        ),
      6 => TestWorkoutPage(
          avatar: _avatar,
          unity: _unity,
          workoutService: createWorkoutService(
            initialAvatar: _avatar,
            accessToken: _accessToken,
          ),
          onCompleted: (updatedAvatar) {
            setState(() {
              _avatar = updatedAvatar;
              _step = 7;
            });
          },
        ),
      7 => _GrowthResultStep(
          avatar: _avatar,
          onEnterHome: _next,
        ),
      _ => HomeShell(avatar: _avatar, unity: _unity),
    };
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _SplashStep extends StatelessWidget {
  const _SplashStep({required this.onStart, required this.avatar});

  final VoidCallback onStart;
  final AvatarState avatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: UnityAvatarView(
              avatar: avatar,
              animationKey: 'intro_hero',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'FitGame',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '完成真实训练，让你的 3D 角色当场变强。',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onStart,
                  child: const Text('开始创建角色'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthStep extends StatefulWidget {
  const _AuthStep({
    required this.onSubmit,
    required this.isBusy,
    this.error,
  });

  final Future<void> Function(AuthCredentials credentials, bool login) onSubmit;
  final bool isBusy;
  final String? error;

  @override
  State<_AuthStep> createState() => _AuthStepState();
}

class _AuthStepState extends State<_AuthStep> {
  final _emailController = TextEditingController(text: 'demo@fitgame.local');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool login) {
    return widget.onSubmit(
      AuthCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
      login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: '登录 / 注册',
      subtitle: 'MVP 使用邮箱账户，后续接入 Apple、Google、手机号和微信。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: '邮箱'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: '密码'),
          ),
          if (widget.error != null) ...[
            const SizedBox(height: 14),
            _ErrorText(widget.error!),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: widget.isBusy ? null : () => _submit(false),
            icon: widget.isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('注册并继续'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: widget.isBusy ? null : () => _submit(true),
            child: const Text('已有账号，登录'),
          ),
        ],
      ),
    );
  }
}

class _CreateAvatarStep extends StatefulWidget {
  const _CreateAvatarStep({
    required this.avatar,
    required this.onPreviewChanged,
    required this.onNext,
    required this.isBusy,
    this.error,
  });

  final AvatarState avatar;
  final ValueChanged<CreateAvatarDraft> onPreviewChanged;
  final Future<void> Function(CreateAvatarDraft draft) onNext;
  final bool isBusy;
  final String? error;

  @override
  State<_CreateAvatarStep> createState() => _CreateAvatarStepState();
}

class _CreateAvatarStepState extends State<_CreateAvatarStep> {
  final _controller = TextEditingController(text: 'Rex');
  String _baseType = 'neutral';
  String _styleType = 'balanced';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CreateAvatarDraft get _draft => CreateAvatarDraft(
        name: _controller.text.trim().isEmpty ? 'Rex' : _controller.text.trim(),
        baseType: _baseType,
        styleType: _styleType,
      );

  void _updatePreview() {
    widget.onPreviewChanged(_draft);
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: '创建你的训练角色',
      subtitle: '先选择一个基础 Avatar，训练完成后会开始成长。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UnityAvatarView(avatar: widget.avatar, compact: true),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: '角色名称'),
            onChanged: (_) => _updatePreview(),
          ),
          const SizedBox(height: 14),
          _Segmented<String>(
            label: '基础类型',
            value: _baseType,
            options: const {
              'male': '男性',
              'female': '女性',
              'neutral': '中性',
            },
            onChanged: (value) {
              setState(() => _baseType = value);
              _updatePreview();
            },
          ),
          const SizedBox(height: 14),
          _Segmented<String>(
            label: '角色风格',
            value: _styleType,
            options: const {
              'strength': '力量型',
              'fat_burn': '燃脂型',
              'agility': '敏捷型',
              'balanced': '平衡型',
            },
            onChanged: (value) => setState(() => _styleType = value),
          ),
          if (widget.error != null) ...[
            const SizedBox(height: 14),
            _ErrorText(widget.error!),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: widget.isBusy ? null : () => widget.onNext(_draft),
            child: Text(widget.isBusy ? '创建中...' : '下一步'),
          ),
        ],
      ),
    );
  }
}

class _BodyProfileStep extends StatefulWidget {
  const _BodyProfileStep({
    required this.profile,
    required this.experience,
    required this.onChanged,
    required this.onExperienceChanged,
    required this.onNext,
    this.error,
  });

  final BodyProfileDraft profile;
  final String experience;
  final ValueChanged<BodyProfileDraft> onChanged;
  final ValueChanged<String> onExperienceChanged;
  final VoidCallback onNext;
  final String? error;

  @override
  State<_BodyProfileStep> createState() => _BodyProfileStepState();
}

class _BodyProfileStepState extends State<_BodyProfileStep> {
  late final TextEditingController _ageController;
  late final TextEditingController _weeklyDaysController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: '${widget.profile.age}');
    _weeklyDaysController = TextEditingController(
      text: '${widget.profile.weeklyTrainingDays}',
    );
    _heightController = TextEditingController(
      text: widget.profile.heightCm.toStringAsFixed(0),
    );
    _weightController = TextEditingController(
      text: widget.profile.weightKg.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weeklyDaysController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  BodyProfileDraft get _profile => widget.profile.copyWith(
        age: int.tryParse(_ageController.text.trim()) ?? widget.profile.age,
        weeklyTrainingDays: int.tryParse(_weeklyDaysController.text.trim()) ??
            widget.profile.weeklyTrainingDays,
        heightCm: double.tryParse(_heightController.text.trim()) ??
            widget.profile.heightCm,
        weightKg: double.tryParse(_weightController.text.trim()) ??
            widget.profile.weightKg,
        trainingExperience: widget.experience,
      );

  void _emitChanged() => widget.onChanged(_profile);

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: '身体数据',
      subtitle: '这些数据用于生成初始角色和第一周训练计划。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '年龄'),
                  onChanged: (_) => _emitChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _weeklyDaysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '每周天数'),
                  onChanged: (_) => _emitChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '身高 cm'),
                  onChanged: (_) => _emitChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '体重 kg'),
                  onChanged: (_) => _emitChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Segmented<String>(
            label: '训练经验',
            value: widget.experience,
            options: const {
              'beginner': '新手',
              'intermediate': '有基础',
              'advanced': '进阶',
            },
            onChanged: widget.onExperienceChanged,
          ),
          if (widget.error != null) ...[
            const SizedBox(height: 14),
            _ErrorText(widget.error!),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () {
              widget.onChanged(_profile);
              widget.onNext();
            },
            child: const Text('继续选择目标'),
          ),
        ],
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({
    required this.goal,
    required this.onGoalChanged,
    required this.onNext,
    required this.isBusy,
    this.error,
  });

  final String goal;
  final ValueChanged<String> onGoalChanged;
  final VoidCallback onNext;
  final bool isBusy;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: '健身目标',
      subtitle: '目标会影响训练计划和角色成长方向。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Segmented<String>(
            label: '目标',
            value: goal,
            options: const {
              '减脂': '减脂',
              '增肌': '增肌',
              '塑形': '塑形',
              '提升体能': '提升体能',
              '保持健康': '保持健康',
            },
            onChanged: onGoalChanged,
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            _ErrorText(error!),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: isBusy ? null : onNext,
            child: Text(isBusy ? '保存中...' : '保存资料并继续'),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
    );
  }
}

class _InitialAvatarStep extends StatelessWidget {
  const _InitialAvatarStep({
    required this.avatar,
    required this.goal,
    required this.unityStatus,
    required this.onStartWorkout,
  });

  final AvatarState avatar;
  final String goal;
  final String? unityStatus;
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: '初始角色已生成',
      subtitle: '目标：$goal。完成测试训练后，系统会调整第一周计划。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UnityAvatarView(avatar: avatar),
          if (unityStatus != null) ...[
            const SizedBox(height: 12),
            _StatusLine(text: unityStatus!),
          ],
          const SizedBox(height: 18),
          _AttributeGrid(attributes: avatar.attributes),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onStartWorkout,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('开始 3 分钟测试训练'),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF10141B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF252B36)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.cable_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _GrowthResultStep extends StatelessWidget {
  const _GrowthResultStep({
    required this.avatar,
    required this.onEnterHome,
  });

  final AvatarState avatar;
  final VoidCallback onEnterHome;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: '训练完成',
      subtitle: '你的角色完成首次成长，已解锁新手手套。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UnityAvatarView(
            avatar: avatar,
            animationKey: 'result_level_up',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ResultMetric(label: '等级', value: 'Lv.${avatar.level}'),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _ResultMetric(label: '获得 XP', value: '+80'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _AttributeGrid(attributes: avatar.attributes),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onEnterHome,
            icon: const Icon(Icons.home_rounded),
            label: const Text('进入角色主页'),
          ),
        ],
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value});

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

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries
              .map(
                (entry) => ChoiceChip(
                  label: Text(entry.value),
                  selected: entry.key == value,
                  onSelected: (_) => onChanged(entry.key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AttributeGrid extends StatelessWidget {
  const _AttributeGrid({required this.attributes});

  final AvatarAttributes attributes;

  @override
  Widget build(BuildContext context) {
    final data = {
      '力量': attributes.strength,
      '耐力': attributes.endurance,
      '核心': attributes.core,
      '柔韧': attributes.flexibility,
      '燃脂': attributes.fatBurn,
      '恢复': attributes.recovery,
    };
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: data.entries
          .map(
            (entry) => SizedBox(
              width: 104,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: entry.value / 20),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
