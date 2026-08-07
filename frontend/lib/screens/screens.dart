import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../core/constants.dart';
import '../models/health_models.dart';
import '../services/dummy_api.dart';
import '../widgets/common_widgets.dart';

const _api = DummyApiService();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: Tween<double>(begin: .55, end: 1).animate(_controller),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'logo',
                child: SizedBox(
                  width: 132,
                  height: 132,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset('assets/animations/health_pulse.json', repeat: true),
                      Icon(Icons.health_and_safety, size: 54, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(AppConstants.appName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(AppConstants.tagline),
              const SizedBox(height: 28),
              const SizedBox(width: 42, height: 42, child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    final response = await _api.login();
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] as String)));
    context.go('/personal-details');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Welcome back',
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Hero(tag: 'logo', child: Icon(Icons.health_and_safety, size: 62)),
          const SizedBox(height: 28),
          const AppTextField(label: 'Email', icon: Icons.mail_outline),
          const SizedBox(height: 14),
          const AppTextField(label: 'Password', icon: Icons.lock_outline, obscure: true),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot Password'))),
          PrimaryButton(label: _loading ? 'Signing in...' : 'Login', icon: Icons.arrow_forward, onPressed: _loading ? null : _login),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: _login, icon: const Icon(Icons.g_mobiledata), label: const Text('Continue with Google')),
          const SizedBox(height: 10),
          TextButton(onPressed: () => context.go('/signup'), child: const Text('Create a new account')),
        ],
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    await _api.signUp();
    if (mounted) context.go('/personal-details');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create account',
      child: Column(
        children: [
          for (final field in const [
            ('Name', Icons.person_outline, false),
            ('Email', Icons.mail_outline, false),
            ('Phone', Icons.call_outlined, false),
            ('Password', Icons.lock_outline, true),
            ('Confirm Password', Icons.verified_user_outlined, true),
          ]) ...[
            AppTextField(label: field.$1, icon: field.$2, obscure: field.$3),
            const SizedBox(height: 14),
          ],
          PrimaryButton(label: _loading ? 'Creating...' : 'Sign Up', icon: Icons.check_circle_outline, onPressed: _loading ? null : _submit),
        ],
      ),
    );
  }
}

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  bool _loading = false;

  Future<void> _save() async {
    setState(() => _loading = true);
    await _api.saveProfile();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      'Name',
      'Age',
      'Gender',
      'Height',
      'Weight',
      'Blood Pressure',
      'Heart Rate',
      'Blood Group',
      'Family History',
      'Allergies',
      'Diabetes',
      'Smoking',
      'Alcohol',
      'Exercise',
      'Sleep Hours',
      'Water Intake',
      'Emergency Contact',
    ];
    return AppScaffold(
      title: 'Personal Details',
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 720 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fields.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: columns == 1 ? 5.6 : 4.8,
                ),
                itemBuilder: (_, index) => AppTextField(label: fields[index], icon: Icons.monitor_heart_outlined),
              );
            },
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: _loading ? 'Saving...' : 'Save Profile', icon: Icons.save_outlined, onPressed: _loading ? null : _save),
        ],
      ),
    );
  }
}

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/home'),
      body: AppScaffold(
        title: 'Hello John',
        showBack: false,
        actions: [IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings_outlined))],
        child: AsyncView<DashboardData>(
          load: _api.dashboard,
          builder: (context, data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Health score', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 8),
                        Text('Excellent balance', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        Text('Keep walking and hydrate today', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    CircularScore(score: data.healthScore, label: 'Score'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _MetricGrid(cards: [
                HealthCard(title: 'BMI', value: '${data.bmi}', subtitle: 'Normal', icon: Icons.scale_outlined),
                HealthCard(title: 'Biological Age', value: '${data.bioAge}', subtitle: '2 years younger', icon: Icons.hourglass_bottom),
                HealthCard(title: 'Heart Rate', value: '${data.heartRate}', subtitle: 'bpm', icon: Icons.favorite_outline),
                HealthCard(title: 'Blood Pressure', value: data.bp, subtitle: 'Healthy', icon: Icons.bloodtype_outlined),
                HealthCard(title: 'Sleep', value: '${data.sleep}h', subtitle: 'Good', icon: Icons.bedtime_outlined),
                HealthCard(title: 'Water', value: data.water, subtitle: 'Goal 3L', icon: Icons.water_drop_outlined),
                HealthCard(title: 'Steps', value: '${data.steps}', subtitle: 'Daily', icon: Icons.directions_walk),
                HealthCard(title: 'Calories', value: '${data.calories}', subtitle: 'Burned', icon: Icons.local_fire_department_outlined),
              ]),
              const SizedBox(height: 18),
              const _FeatureGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniGamesScreen extends StatefulWidget {
  const MiniGamesScreen({super.key});

  @override
  State<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends State<MiniGamesScreen> {
  Future<Map<String, dynamic>>? _result;

  @override
  Widget build(BuildContext context) {
    final games = ['Eye Test', 'Memory Test', 'Brain Speed', 'Reaction Test', 'Color Blind Test', 'Hearing Test', 'Lung Breathing', 'Heart Fitness'];
    return AppScaffold(
      title: 'Mini Games',
      child: Column(
        children: [
          _SimpleGrid(
            items: games,
            icon: Icons.sports_esports_outlined,
            onTap: (_) => setState(() => _result = _api.gameResult()),
          ),
          if (_result != null) ...[
            const SizedBox(height: 18),
            AsyncView<Map<String, dynamic>>(
              load: () => _result!,
              builder: (_, data) => GradientCard(
                child: Text('Result: ${data['score']} - ${data['status']}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MedicalReportUploadScreen extends StatelessWidget {
  const MedicalReportUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Medical Report Upload',
      child: Column(
        children: [
          const _UploadBox(label: 'Upload PDF', icon: Icons.picture_as_pdf_outlined),
          const SizedBox(height: 14),
          const _UploadBox(label: 'Upload Image', icon: Icons.image_outlined),
          const SizedBox(height: 18),
          AsyncView<Map<String, dynamic>>(
            load: _api.reportAnalysis,
            builder: (_, data) => _InfoList(title: 'Dummy AI Report', items: data),
          ),
        ],
      ),
    );
  }
}

class HealthAnalysisScreen extends StatelessWidget {
  const HealthAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/analysis'),
      body: AppScaffold(
        title: 'Health Analysis',
        child: AsyncView<Map<String, dynamic>>(
          load: _api.analysis,
          builder: (_, data) => Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [CircularScore(score: data['healthScore'] as int, label: 'Health'), CircularScore(score: 84, label: 'Sleep')]),
              const SizedBox(height: 18),
              _InfoList(title: 'Vitals', items: data),
              const SizedBox(height: 18),
              const MiniChart(values: [68, 72, 80, 76, 86, 91, 92]),
              const SizedBox(height: 18),
              PrimaryButton(label: 'Open AI Health Report', icon: Icons.auto_awesome, onPressed: () => context.go('/ai-report')),
            ],
          ),
        ),
      ),
    );
  }
}

class AiHealthReportScreen extends StatelessWidget {
  const AiHealthReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = {
      'Health Summary': 'Your core markers are stable with strong activity consistency.',
      'Detected Risks': 'Low cardiovascular risk. Cholesterol needs light attention.',
      'Lifestyle Suggestions': 'Add two strength sessions and keep sleep above seven hours.',
      'Priority Level': 'Medium priority: nutrition optimization.',
      'Healthy Habits': 'Walking, hydration, and steady sleep are working well.',
      'Doctor Recommendation': 'Routine annual checkup is enough unless symptoms change.',
    };
    return AppScaffold(
      title: 'AI Health Report',
      child: Column(
        children: [
          _InfoList(title: 'Heal Gui AI Analysis', items: sections),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined), label: const Text('Share Report'))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: const Text('Download PDF'))),
          ]),
        ],
      ),
    );
  }
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _messages = <({String text, bool user})>[
    (text: 'Hi John, I can explain your health score, reports, diet, and sleep.', user: false),
  ];
  bool _typing = false;

  Future<void> _send([String? preset]) async {
    final text = preset ?? _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add((text: text, user: true));
      _typing = true;
      _controller.clear();
    });
    final reply = await _api.chat(text);
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add((text: reply, user: false));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ['What is my BMI?', 'Analyze my report', 'Suggest healthy food', "Today's workout", 'Can I improve my sleep?'];
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/chat'),
      appBar: AppBar(
        title: const Text('Heal Gui AI Assistant'),
        actions: [IconButton(onPressed: () => setState(_messages.clear), icon: const Icon(Icons.delete_outline))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => ActionChip(label: Text(suggestions[i]), onPressed: () => _send(suggestions[i])),
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemCount: suggestions.length,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_typing ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_typing && i == _messages.length) return const _ChatBubble(text: 'Typing...', user: false);
                  final message = _messages[i];
                  return _ChatBubble(text: '${message.text}\n${TimeOfDay.now().format(context)}', user: message.user);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(labelText: 'Ask about your health', prefixIcon: Icon(Icons.auto_awesome)),
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none)),
                  IconButton(onPressed: () => _send(), icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FutureHealthScreen extends StatefulWidget {
  const FutureHealthScreen({super.key});

  @override
  State<FutureHealthScreen> createState() => _FutureHealthScreenState();
}

class _FutureHealthScreenState extends State<FutureHealthScreen> {
  double weight = 72, walking = 45, sleep = 7.5, water = 2.5, exercise = 4, smoking = 0, alcohol = 1;
  Future<Map<String, dynamic>>? prediction;

  @override
  Widget build(BuildContext context) {
    final sliders = {'Weight': weight, 'Walking': walking, 'Sleep': sleep, 'Water': water, 'Exercise': exercise, 'Smoking': smoking, 'Alcohol': alcohol};
    return AppScaffold(
      title: 'Future Health',
      child: Column(
        children: [
          for (final item in sliders.entries)
            ListTile(
              title: Text(item.key),
              subtitle: Slider(value: item.value, max: item.key == 'Weight' ? 140 : 10, onChanged: (value) => setState(() => _setSlider(item.key, value))),
              trailing: Text(item.value.toStringAsFixed(1)),
            ),
          PrimaryButton(label: 'Predict', icon: Icons.insights_outlined, onPressed: () => setState(() => prediction = _api.futureHealth())),
          if (prediction != null) ...[
            const SizedBox(height: 18),
            AsyncView<Map<String, dynamic>>(load: () => prediction!, builder: (_, data) => _InfoList(title: 'Prediction', items: data)),
            const MiniChart(values: [91, 92, 94, 95, 97]),
          ],
        ],
      ),
    );
  }

  void _setSlider(String key, double value) {
    switch (key) {
      case 'Weight':
        weight = value;
      case 'Walking':
        walking = value;
      case 'Sleep':
        sleep = value;
      case 'Water':
        water = value;
      case 'Exercise':
        exercise = value;
      case 'Smoking':
        smoking = value;
      case 'Alcohol':
        alcohol = value;
    }
  }
}

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Personalized Diet',
      child: AsyncView<Map<String, dynamic>>(
        load: _api.diet,
        builder: (_, data) => Column(
          children: [
            _InfoList(title: 'Targets', items: data),
            const SizedBox(height: 16),
            _InfoList(title: 'Daily Plan', items: const {
              'Breakfast': 'Greek yogurt, berries, oats',
              'Lunch': 'Quinoa bowl with paneer and greens',
              'Dinner': 'Grilled protein, vegetables, lentil soup',
              'Snacks': 'Fruit, nuts, coconut water',
              'BMI Advice': 'Maintain current range with strength work',
              'Exercise Tips': 'Walk 8k steps and add mobility',
              'Shopping List': 'Leafy greens, eggs, pulses, curd, citrus',
            }),
          ],
        ),
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/progress'),
      body: AppScaffold(
        title: 'Progress',
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: [ButtonSegment(value: 'W', label: Text('Weekly')), ButtonSegment(value: 'M', label: Text('Monthly')), ButtonSegment(value: 'Y', label: Text('Yearly'))],
              selected: {'W'},
              onSelectionChanged: (_) {},
            ),
            const SizedBox(height: 18),
            const MiniChart(values: [72, 71.8, 71.5, 71.6, 71.2, 70.9, 70.6]),
            const SizedBox(height: 18),
            _SimpleGrid(items: const ['Weight', 'BMI', 'Health Score', 'Water Intake', 'Steps', 'Sleep', 'Heart Rate', 'Achievements'], icon: Icons.trending_up, onTap: (_) {}),
            const SizedBox(height: 18),
            _InfoList(title: 'Medical Timeline', items: const {'Today': 'AI report generated', 'Last week': 'Blood report analyzed', 'Last month': 'New walking streak achieved'}),
          ],
        ),
      ),
    );
  }
}

class ReportHistoryScreen extends StatelessWidget {
  const ReportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Report History',
      child: Column(
        children: [
          const AppTextField(label: 'Search reports', icon: Icons.search),
          const SizedBox(height: 16),
          for (final report in ['Blood Work - Aug', 'AI Health Report', 'Lipid Profile', 'Sleep Summary'])
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(report),
                subtitle: const Text('Previous AI and medical report'),
                trailing: Wrap(spacing: 4, children: const [Icon(Icons.visibility_outlined), Icon(Icons.download_outlined), Icon(Icons.delete_outline)]),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/profile'),
      body: AppScaffold(
        title: 'Profile',
        child: Column(
          children: [
            const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 10),
            const Text('John', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            for (final item in const ['Edit', 'Medical Details', 'Emergency Contact', 'Notifications', 'Privacy', 'Language', 'About'])
              Card(child: ListTile(title: Text(item), trailing: const Icon(Icons.chevron_right))),
            PrimaryButton(label: 'Logout', icon: Icons.logout, onPressed: () => context.go('/login')),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      child: Column(
        children: const [
          SwitchListTile(value: true, onChanged: null, title: Text('Dark Mode')),
          SwitchListTile(value: true, onChanged: null, title: Text('Notifications')),
          ListTile(title: Text('Units'), trailing: Text('Metric')),
          ListTile(title: Text('Font Size'), trailing: Text('Default')),
          ListTile(title: Text('Language'), trailing: Text('English')),
          ListTile(title: Text('Terms')),
          ListTile(title: Text('Privacy')),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.cards});
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final count = constraints.maxWidth > 720 ? 4 : 2;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: count == 4 ? 1.05 : .95,
          children: cards,
        );
      },
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    const features = [
      ('Mini Games', Icons.sports_esports_outlined, '/games'),
      ('Medical Reports', Icons.upload_file_outlined, '/upload'),
      ('Health Analysis', Icons.monitor_heart_outlined, '/analysis'),
      ('AI Chat', Icons.chat_bubble_outline, '/chat'),
      ('Future Health', Icons.insights_outlined, '/future'),
      ('Diet', Icons.restaurant_menu, '/diet'),
      ('Progress', Icons.trending_up, '/progress'),
      ('Reports', Icons.folder_copy_outlined, '/reports'),
      ('Profile', Icons.person_outline, '/profile'),
    ];
    return LayoutBuilder(
      builder: (_, constraints) {
        final count = constraints.maxWidth > 720 ? 3 : 2;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [for (final item in features) FeatureTile(label: item.$1, icon: item.$2, route: item.$3)],
        );
      },
    );
  }
}

class _SimpleGrid extends StatelessWidget {
  const _SimpleGrid({required this.items, required this.icon, required this.onTap});
  final List<String> items;
  final IconData icon;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final count = constraints.maxWidth > 720 ? 4 : 2;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            for (final item in items)
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onTap(item),
                child: Card(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon), const SizedBox(height: 8), Text(item, textAlign: TextAlign.center)]))),
              ),
          ],
        );
      },
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(children: [Icon(icon, size: 42), const SizedBox(height: 10), Text(label, style: const TextStyle(fontWeight: FontWeight.w800)), const Text('Preview ready for dummy analysis')]),
      ),
    );
  }
}

class _InfoList extends StatelessWidget {
  const _InfoList({required this.title, required this.items});
  final String title;
  final Map<dynamic, dynamic> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            for (final item in items.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text('${item.key}', style: const TextStyle(fontWeight: FontWeight.w700))),
                    const SizedBox(width: 16),
                    Expanded(child: Text('${item.value}', textAlign: TextAlign.right)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.user});
  final String text;
  final bool user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: user ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: TextStyle(color: user ? Colors.white : null)),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    const destinations = [
      ('/home', Icons.home_outlined, 'Home'),
      ('/analysis', Icons.monitor_heart_outlined, 'Analysis'),
      ('/chat', Icons.chat_bubble_outline, 'AI Chat'),
      ('/progress', Icons.trending_up, 'Progress'),
      ('/profile', Icons.person_outline, 'Profile'),
    ];
    final index = destinations.indexWhere((item) => item.$1 == current);
    return NavigationBar(
      selectedIndex: index < 0 ? 0 : index,
      onDestinationSelected: (i) => context.go(destinations[i].$1),
      destinations: [
        for (final item in destinations) NavigationDestination(icon: Icon(item.$2), label: item.$3),
      ],
    );
  }
}
