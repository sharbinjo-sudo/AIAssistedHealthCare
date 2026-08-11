import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/health_models.dart';
import '../services/api_service.dart';
import '../services/dummy_api.dart';
import '../widgets/common_widgets.dart';

final _api = ApiService();
const _dummyApi = DummyApiService();
final _digitsOnly = [FilteringTextInputFormatter.digitsOnly];
final _decimalOnly = [
  TextInputFormatter.withFunction((oldValue, newValue) {
    return RegExp(r'^\d*\.?\d{0,1}$').hasMatch(newValue.text) ? newValue : oldValue;
  }),
];
final _nameFormatters = [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s.'-]"))];
final _emailFormatters = [FilteringTextInputFormatter.deny(RegExp(r'\s'))];

bool _isValidEmail(String value) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

bool _isValidPhone(String value) => RegExp(r'^\d{10}$').hasMatch(value.trim());

String? _passwordValidationError(String value) {
  if (value.length < 8) return 'Password must be at least 8 characters.';
  if (value.length > 10) return 'Password must be 10 characters or fewer.';
  if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password needs at least one uppercase letter.';
  if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password needs at least one lowercase letter.';
  if (!RegExp(r'\d').hasMatch(value)) return 'Password needs at least one number.';
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]').hasMatch(value)) return 'Password needs at least one symbol.';
  return null;
}

String? _rangeValidationError(String label, String value, {required double min, required double max}) {
  if (value.trim().isEmpty) return null;
  final number = double.tryParse(value.trim());
  if (number == null) return '$label must be a number.';
  if (number < min || number > max) return '$label must be between ${min.toStringAsFixed(0)} and ${max.toStringAsFixed(0)}.';
  return null;
}

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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppNavBar(title: l10n.appTitle, showBack: false),
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
              Text(l10n.appTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(l10n.tagline),
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final error = _loginValidationError();
    if (error != null) {
      _showMessage(error);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.login(email: _emailController.text.trim(), password: _passwordController.text);
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
      setState(() => _loading = false);
      return;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.loginSuccessful)));
    context.go('/personal-details');
  }

  String? _loginValidationError() {
    if (!_isValidEmail(_emailController.text)) return 'Enter a valid email address.';
    if (_passwordController.text.isEmpty) return 'Password is required.';
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _googleUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in is not configured for this local Django backend.')));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.welcomeBack,
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Hero(tag: 'logo', child: Icon(Icons.health_and_safety, size: 62)),
          const SizedBox(height: 28),
          AppTextField(
            label: l10n.email,
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            inputFormatters: _emailFormatters,
          ),
          const SizedBox(height: 14),
          AppTextField(label: l10n.password, icon: Icons.lock_outline, obscure: true, controller: _passwordController, maxLength: 10),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: Text(l10n.forgotPassword))),
          PrimaryButton(label: _loading ? l10n.signingIn : l10n.login, icon: Icons.arrow_forward, onPressed: _loading ? null : _login),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: _googleUnavailable, icon: const Icon(Icons.g_mobiledata), label: Text(l10n.continueWithGoogle)),
          const SizedBox(height: 10),
          TextButton(onPressed: () => context.go('/signup'), child: Text(l10n.createNewAccount)),
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final validationError = _signUpValidationError();
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Passwords do not match.');
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
      setState(() => _loading = false);
      return;
    }
    if (mounted) context.go('/personal-details');
  }

  String? _signUpValidationError() {
    if (_nameController.text.trim().length < 2) return 'Name must contain at least 2 letters.';
    if (!_isValidEmail(_emailController.text)) return 'Enter a valid email address.';
    if (!_isValidPhone(_phoneController.text)) return 'Phone number must contain exactly 10 digits.';
    return _passwordValidationError(_passwordController.text);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.createAccount,
      child: Column(
        children: [
          for (final field in [
            (l10n.name, Icons.person_outline, false, _nameController, TextInputType.name, _nameFormatters, 80, null),
            (l10n.email, Icons.mail_outline, false, _emailController, TextInputType.emailAddress, _emailFormatters, 120, null),
            (l10n.phone, Icons.call_outlined, false, _phoneController, TextInputType.phone, _digitsOnly, 10, '10 digits only'),
            (l10n.password, Icons.lock_outline, true, _passwordController, TextInputType.visiblePassword, null, 10, '8-10 chars: upper, lower, number, symbol'),
            (l10n.confirmPassword, Icons.verified_user_outlined, true, _confirmPasswordController, TextInputType.visiblePassword, null, 10, null),
          ]) ...[
            AppTextField(
              label: field.$1,
              icon: field.$2,
              obscure: field.$3,
              controller: field.$4,
              keyboardType: field.$5,
              inputFormatters: field.$6,
              maxLength: field.$7,
              helperText: field.$8,
            ),
            const SizedBox(height: 14),
          ],
          PrimaryButton(label: _loading ? l10n.creating : l10n.signUp, icon: Icons.check_circle_outline, onPressed: _loading ? null : _submit),
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
  late final Map<String, TextEditingController> _controllers = {
    for (final field in _personalDetailFields.whereType<String>())
      if (!_personalDetailDropdownOptions.containsKey(field)) field: TextEditingController(),
  };
  bool _loading = false;
  final Map<String, String?> _dropdownValues = {
    for (final field in _personalDetailDropdownOptions.keys) field: null,
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _api.profile();
      if (!mounted) return;
      setState(() {
        for (final entry in _profileFieldMap.entries) {
          final value = profile[entry.value];
          if (value == null) continue;
          final stringValue = '$value'.trim();
          if (stringValue.isEmpty) continue;
          if (_controllers.containsKey(entry.key)) {
            _controllers[entry.key]!.text = stringValue;
          } else if (_dropdownValues.containsKey(entry.key)) {
            final options = _personalDetailDropdownOptions[entry.key] ?? const <String>[];
            _dropdownValues[entry.key] = options.contains(stringValue) ? stringValue : null;
          }
        }
      });
    } on ApiException {
      // A first-time profile may not have meaningful values yet.
    }
  }

  Future<void> _save() async {
    final validationError = _profileValidationError(context.l10n);
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.saveProfile(_profilePayload());
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
      setState(() => _loading = false);
      return;
    }
    if (mounted) context.go('/home');
  }

  String? _profileValidationError(AppLocalizations l10n) {
    for (final entry in _profileFieldMap.entries) {
      final textValue = _controllers[entry.key]?.text.trim();
      final dropdownValue = _dropdownValues[entry.key];
      if ((textValue == null || textValue.isEmpty) && (dropdownValue == null || dropdownValue.isEmpty)) {
        return '${_personalDetailLabel(l10n, entry.key)} is required.';
      }
    }
    final checks = [
      _rangeValidationError(l10n.age, _controllers['age']?.text ?? '', min: 1, max: 120),
      _rangeValidationError(l10n.height, _controllers['height']?.text ?? '', min: 40, max: 260),
      _rangeValidationError(l10n.weight, _controllers['weight']?.text ?? '', min: 2, max: 300),
      _rangeValidationError(l10n.heartRate, _controllers['heartRate']?.text ?? '', min: 30, max: 220),
      _rangeValidationError(l10n.sleepHours, _controllers['sleepHours']?.text ?? '', min: 0, max: 24),
    ];
    for (final error in checks) {
      if (error != null) return error;
    }
    final emergencyContact = _controllers['emergencyContact']?.text.trim() ?? '';
    if (emergencyContact.isNotEmpty && !_isValidPhone(emergencyContact)) {
      return '${l10n.emergencyContact} must contain exactly 10 digits.';
    }
    final bloodPressure = _controllers['bloodPressure']?.text.trim() ?? '';
    if (bloodPressure.isNotEmpty && !RegExp(r'^\d{2,3}/\d{2,3}$').hasMatch(bloodPressure)) {
      return '${l10n.bloodPressure} must look like 120/80.';
    }
    final waterIntake = _controllers['waterIntake']?.text.trim() ?? '';
    if (waterIntake.isNotEmpty && !RegExp(r'^\d{1,2}(\.\d)?L?$').hasMatch(waterIntake)) {
      return '${l10n.waterIntake} must look like 2.5L.';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, dynamic> _profilePayload() {
    final payload = <String, dynamic>{};
    for (final entry in _profileFieldMap.entries) {
      final textValue = _controllers[entry.key]?.text.trim();
      final dropdownValue = _dropdownValues[entry.key];
      final value = textValue?.isNotEmpty == true ? textValue : dropdownValue;
      if (value != null && value.toString().trim().isNotEmpty) payload[entry.value] = value;
    }
    return payload;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.personalDetails,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 720 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _personalDetailFields.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: columns == 1 ? 5.6 : 4.8,
                ),
                itemBuilder: (_, index) {
                  final field = _personalDetailFields[index];
                  if (field == null) return const SizedBox.shrink();

                  final dropdownItems = _personalDetailDropdownOptions[field];
                  if (dropdownItems == null) {
                    return AppTextField(
                      label: _personalDetailLabel(l10n, field),
                      icon: Icons.monitor_heart_outlined,
                      controller: _controllers[field],
                      keyboardType: _numberFields.contains(field) ? TextInputType.number : TextInputType.text,
                      inputFormatters: _profileInputFormatters(field),
                      maxLength: _profileMaxLength(field),
                      helperText: _profileHelperText(field),
                    );
                  }

                  return AppDropdownField(
                    label: _personalDetailLabel(l10n, field),
                    icon: Icons.monitor_heart_outlined,
                    items: dropdownItems,
                    value: _dropdownValues[field],
                    itemLabel: (item) => _personalDetailOptionLabel(l10n, item),
                    onChanged: (value) => setState(() => _dropdownValues[field] = value),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: _loading ? l10n.saving : l10n.saveProfile, icon: Icons.save_outlined, onPressed: _loading ? null : _save),
        ],
      ),
    );
  }
}

const List<String?> _personalDetailFields = [
  'name',
  'age',
  'gender',
  'height',
  'weight',
  'bloodPressure',
  'heartRate',
  'bloodGroup',
  'familyHistory',
  'allergies',
  'diabetes',
  'smoking',
  'alcohol',
  'exercise',
  'sleepHours',
  'waterIntake',
  'emergencyContact',
  null,
];

const Map<String, List<String>> _personalDetailDropdownOptions = {
  'gender': ['male', 'female', 'other', 'preferNotToSay'],
  'bloodGroup': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
  'familyHistory': ['yes', 'no', 'unknown'],
  'allergies': ['yes', 'no'],
  'diabetes': ['yes', 'no'],
  'smoking': ['never', 'formerSmoker', 'currentSmoker'],
  'alcohol': ['never', 'occasionally', 'frequently'],
  'exercise': ['never', 'oneTwoDaysWeek', 'threeFiveDaysWeek', 'daily'],
};

const Map<String, String> _profileFieldMap = {
  'name': 'name',
  'age': 'age',
  'gender': 'gender',
  'height': 'height',
  'weight': 'weight',
  'bloodPressure': 'blood_pressure',
  'heartRate': 'heart_rate',
  'bloodGroup': 'blood_group',
  'familyHistory': 'family_history',
  'allergies': 'allergies',
  'diabetes': 'diabetes',
  'smoking': 'smoking',
  'alcohol': 'alcohol',
  'exercise': 'exercise',
  'sleepHours': 'sleep_hours',
  'waterIntake': 'water_intake',
  'emergencyContact': 'emergency_contact',
};

const Set<String> _numberFields = {'age', 'height', 'weight', 'heartRate', 'sleepHours'};

List<TextInputFormatter>? _profileInputFormatters(String field) {
  switch (field) {
    case 'age':
    case 'heartRate':
    case 'emergencyContact':
      return _digitsOnly;
    case 'height':
    case 'weight':
    case 'sleepHours':
      return _decimalOnly;
    case 'bloodPressure':
      return [FilteringTextInputFormatter.allow(RegExp(r'[\d/]'))];
    case 'waterIntake':
      return [FilteringTextInputFormatter.allow(RegExp(r'[\d.Ll]'))];
    case 'name':
      return _nameFormatters;
  }
  return null;
}

int? _profileMaxLength(String field) {
  switch (field) {
    case 'age':
      return 3;
    case 'height':
    case 'weight':
      return 5;
    case 'heartRate':
      return 3;
    case 'sleepHours':
      return 4;
    case 'bloodPressure':
      return 7;
    case 'emergencyContact':
      return 10;
    case 'waterIntake':
      return 5;
    case 'name':
      return 80;
  }
  return 255;
}

String? _profileHelperText(String field) {
  switch (field) {
    case 'bloodPressure':
      return 'Example: 120/80';
    case 'emergencyContact':
      return '10 digits only';
    case 'height':
      return 'Centimeters';
    case 'weight':
      return 'Kilograms';
    case 'sleepHours':
      return '0 to 24 hours';
    case 'waterIntake':
      return 'Example: 2.5L';
  }
  return null;
}

String _personalDetailLabel(AppLocalizations l10n, String field) {
  switch (field) {
    case 'name':
      return l10n.name;
    case 'age':
      return l10n.age;
    case 'gender':
      return l10n.gender;
    case 'height':
      return l10n.height;
    case 'weight':
      return l10n.weight;
    case 'bloodPressure':
      return l10n.bloodPressure;
    case 'heartRate':
      return l10n.heartRate;
    case 'bloodGroup':
      return l10n.bloodGroup;
    case 'familyHistory':
      return l10n.familyHistory;
    case 'allergies':
      return l10n.allergies;
    case 'diabetes':
      return l10n.diabetes;
    case 'smoking':
      return l10n.smoking;
    case 'alcohol':
      return l10n.alcohol;
    case 'exercise':
      return l10n.exercise;
    case 'sleepHours':
      return l10n.sleepHours;
    case 'waterIntake':
      return l10n.waterIntake;
    case 'emergencyContact':
      return l10n.emergencyContact;
  }
  return field;
}

String _personalDetailOptionLabel(AppLocalizations l10n, String item) {
  switch (item) {
    case 'male':
      return l10n.male;
    case 'female':
      return l10n.female;
    case 'other':
      return l10n.other;
    case 'preferNotToSay':
      return l10n.preferNotToSay;
    case 'yes':
      return l10n.yes;
    case 'no':
      return l10n.no;
    case 'unknown':
      return l10n.unknown;
    case 'never':
      return l10n.never;
    case 'formerSmoker':
      return l10n.formerSmoker;
    case 'currentSmoker':
      return l10n.currentSmoker;
    case 'occasionally':
      return l10n.occasionally;
    case 'frequently':
      return l10n.frequently;
    case 'oneTwoDaysWeek':
      return l10n.oneTwoDaysWeek;
    case 'threeFiveDaysWeek':
      return l10n.threeFiveDaysWeek;
    case 'daily':
      return l10n.daily;
  }
  return item;
}

Map<String, dynamic> _reportAnalysisItems(AppLocalizations l10n, Map<String, dynamic> data) => {
      l10n.bloodSugar: data['bloodSugar'] ?? l10n.normal,
      l10n.cholesterol: data['cholesterol'] ?? l10n.slightlyHigh,
      l10n.bloodPressure: data['bp'] ?? '120/80',
      l10n.summary: data['summary'] ?? l10n.healthy,
    };

Map<String, dynamic> _analysisItems(AppLocalizations l10n, Map<String, dynamic> data) => {
      l10n.healthScore: data['healthScore'] ?? '92',
      l10n.risk: data['risk'] ?? l10n.low,
      l10n.bioAge: data['bioAge'] ?? '24',
      l10n.bmi: data['bmi'] ?? '21.9',
      l10n.stress: data['stress'] ?? l10n.medium,
    };

Map<String, dynamic> _aiReportSections(AppLocalizations l10n, Map<String, dynamic> data) => {
      l10n.healthSummary: data['Health Summary'] ?? l10n.healthSummaryText,
      l10n.detectedRisks: data['Detected Risks'] ?? l10n.detectedRisksText,
      l10n.lifestyleSuggestions: data['Lifestyle Suggestions'] ?? l10n.lifestyleSuggestionsText,
      l10n.priorityLevel: data['Priority Level'] ?? l10n.priorityLevelText,
      l10n.healthyHabits: data['Healthy Habits'] ?? l10n.healthyHabitsText,
      l10n.doctorRecommendation: data['Doctor Recommendation'] ?? l10n.doctorRecommendationText,
    };

String _chatMessageText(AppLocalizations l10n, String key) {
  switch (key) {
    case 'chatGreeting':
      return l10n.chatGreeting;
    case 'chatReply':
      return l10n.chatReply;
  }
  return key;
}

String _sliderLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'weight':
      return l10n.weight;
    case 'walking':
      return l10n.walking;
    case 'sleep':
      return l10n.sleep;
    case 'water':
      return l10n.water;
    case 'exercise':
      return l10n.exercise;
    case 'smoking':
      return l10n.smoking;
    case 'alcohol':
      return l10n.alcohol;
  }
  return key;
}

Map<String, dynamic> _predictionItems(AppLocalizations l10n, Map<String, dynamic> data) => {
      l10n.futureHealthScore: data['futureHealthScore'] ?? '97',
      l10n.bioAge: data['bioAge'] ?? '21',
      l10n.risk: data['risk'] ?? l10n.veryLow,
    };

double _sliderMax(String key) => key == 'weight'
    ? 140
    : key == 'walking'
        ? 120
        : 10;

Map<String, dynamic> _dietTargets(AppLocalizations l10n, Map<String, dynamic> data) {
  final targets = data['targets'];
  return {
    l10n.calories: targets is Map ? targets['calories'] ?? '2200' : '2200',
    l10n.protein: targets is Map ? targets['protein'] ?? '110g' : '110g',
    l10n.water: targets is Map ? targets['water'] ?? '3L' : '3L',
  };
}

Map<String, dynamic> _dailyPlan(AppLocalizations l10n, Map<String, dynamic> data) {
  final plan = data['dailyPlan'];
  return {
    l10n.breakfast: plan is Map ? plan['Breakfast'] ?? l10n.breakfastText : l10n.breakfastText,
    l10n.lunch: plan is Map ? plan['Lunch'] ?? l10n.lunchText : l10n.lunchText,
    l10n.dinner: plan is Map ? plan['Dinner'] ?? l10n.dinnerText : l10n.dinnerText,
    l10n.snacks: plan is Map ? plan['Snacks'] ?? l10n.snacksText : l10n.snacksText,
    l10n.bmiAdvice: plan is Map ? plan['BMI Advice'] ?? l10n.bmiAdviceText : l10n.bmiAdviceText,
    l10n.exerciseTips: plan is Map ? plan['Exercise Tips'] ?? l10n.exerciseTipsText : l10n.exerciseTipsText,
    l10n.shoppingList: plan is Map ? plan['Shopping List'] ?? l10n.shoppingListText : l10n.shoppingListText,
  };
}

Map<String, dynamic> _progressItems(AppLocalizations l10n, List<Map<String, dynamic>> entries) {
  final latest = entries.isEmpty ? <String, dynamic>{} : entries.first;
  return {
    l10n.weight: latest['weight'] ?? '70.6',
    l10n.bmi: latest['bmi'] ?? '22.4',
    l10n.healthScore: latest['health_score'] ?? '91',
    l10n.waterIntake: latest['water_intake'] ?? '2.5L',
    l10n.steps: latest['steps'] ?? '8230',
    l10n.sleep: latest['sleep'] ?? '7.8',
    l10n.heartRate: latest['heart_rate'] ?? '74',
    l10n.achievements: latest['note'] ?? l10n.todayTimeline,
  };
}

Map<String, String> _medicalTimeline(AppLocalizations l10n) => {
      l10n.today: l10n.todayTimeline,
      l10n.lastWeek: l10n.lastWeekTimeline,
      l10n.lastMonth: l10n.lastMonthTimeline,
    };

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late Future<Map<String, dynamic>> _profileFuture = _api.profile();

  String _dashboardTitle(AppLocalizations l10n, AsyncSnapshot<Map<String, dynamic>> snapshot) {
    final name = '${snapshot.data?['name'] ?? ''}'.trim();
    return name.isEmpty ? l10n.helloJohn : 'Hello $name';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/home'),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, profileSnapshot) {
          return AppScaffold(
            title: _dashboardTitle(l10n, profileSnapshot),
            showBack: false,
            actions: [
              IconButton(
                onPressed: () => setState(() => _profileFuture = _api.profile()),
                icon: const Icon(Icons.refresh_outlined),
              ),
              IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings_outlined)),
            ],
            child: AsyncView<DashboardData>(
              load: _api.dashboard,
              builder: (context, data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.healthScore, style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(l10n.excellentBalance, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                            Text(l10n.keepWalkingHydrate, style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        CircularScore(score: data.healthScore, label: l10n.score),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MetricGrid(cards: [
                    HealthCard(title: l10n.bmi, value: '${data.bmi}', subtitle: l10n.normal, icon: Icons.scale_outlined),
                    HealthCard(title: l10n.biologicalAge, value: '${data.bioAge}', subtitle: l10n.twoYearsYounger, icon: Icons.hourglass_bottom),
                    HealthCard(title: l10n.heartRate, value: '${data.heartRate}', subtitle: l10n.bpm, icon: Icons.favorite_outline),
                    HealthCard(title: l10n.bloodPressure, value: data.bp, subtitle: l10n.healthy, icon: Icons.bloodtype_outlined),
                    HealthCard(title: l10n.sleep, value: '${data.sleep}h', subtitle: l10n.good, icon: Icons.bedtime_outlined),
                    HealthCard(title: l10n.water, value: data.water, subtitle: l10n.goalThreeL, icon: Icons.water_drop_outlined),
                    HealthCard(title: l10n.steps, value: '${data.steps}', subtitle: l10n.dailyLabel, icon: Icons.directions_walk),
                    HealthCard(title: l10n.calories, value: '${data.calories}', subtitle: l10n.burned, icon: Icons.local_fire_department_outlined),
                  ]),
                  const SizedBox(height: 18),
                  const _FeatureGrid(),
                ],
              ),
            ),
          );
        },
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
    final l10n = context.l10n;
    final games = [l10n.eyeTest, l10n.memoryTest, l10n.brainSpeed, l10n.reactionTest, l10n.colorBlindTest, l10n.hearingTest, l10n.lungBreathing, l10n.heartFitness];
    return AppScaffold(
      title: l10n.miniGames,
      child: Column(
        children: [
          _SimpleGrid(
            items: games,
            icon: Icons.sports_esports_outlined,
            onTap: (_) => setState(() => _result = _dummyApi.gameResult()),
          ),
          if (_result != null) ...[
            const SizedBox(height: 18),
            AsyncView<Map<String, dynamic>>(
              load: () => _result!,
              builder: (_, data) => GradientCard(
                child: Text('${l10n.result}: ${data['score']} - ${l10n.good}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MedicalReportUploadScreen extends StatefulWidget {
  const MedicalReportUploadScreen({super.key});

  @override
  State<MedicalReportUploadScreen> createState() => _MedicalReportUploadScreenState();
}

class _MedicalReportUploadScreenState extends State<MedicalReportUploadScreen> {
  var _analysisKey = 0;

  Future<void> _createReport(String title, String type) async {
    try {
      await _api.createReport(title: title, reportType: type);
      if (!mounted) return;
      setState(() => _analysisKey++);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.previewReady)));
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.medicalReportUpload,
      child: Column(
        children: [
          _UploadBox(label: l10n.uploadPdf, icon: Icons.picture_as_pdf_outlined, onTap: () => _createReport(l10n.uploadPdf, 'pdf')),
          const SizedBox(height: 14),
          _UploadBox(label: l10n.uploadImage, icon: Icons.image_outlined, onTap: () => _createReport(l10n.uploadImage, 'image')),
          const SizedBox(height: 18),
          AsyncView<Map<String, dynamic>>(
            key: ValueKey(_analysisKey),
            load: _api.reportAnalysis,
            builder: (_, data) => _InfoList(title: l10n.dummyAiReport, items: _reportAnalysisItems(l10n, data)),
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
    final l10n = context.l10n;
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/analysis'),
      body: AppScaffold(
        title: l10n.healthAnalysis,
        child: AsyncView<Map<String, dynamic>>(
          load: _api.analysis,
          builder: (_, data) => Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [CircularScore(score: data['healthScore'] as int, label: l10n.health), CircularScore(score: 84, label: l10n.sleep)]),
              const SizedBox(height: 18),
              _InfoList(title: l10n.vitals, items: _analysisItems(l10n, data)),
              const SizedBox(height: 18),
              const MiniChart(values: [68, 72, 80, 76, 86, 91, 92]),
              const SizedBox(height: 18),
              PrimaryButton(label: l10n.openAiHealthReport, icon: Icons.auto_awesome, onPressed: () => context.go('/ai-report')),
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
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.aiHealthReport,
      child: AsyncView<Map<String, dynamic>>(
        load: _api.aiReport,
        builder: (_, data) => Column(
          children: [
            _InfoList(title: l10n.healGuiAiAnalysis, items: _aiReportSections(l10n, data)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined), label: Text(l10n.shareReport))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: Text(l10n.downloadPdf))),
            ]),
          ],
        ),
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
  final _messages = <({String key, bool user})>[(key: 'chatGreeting', user: false)];
  bool _typing = false;

  Future<void> _send([String? preset]) async {
    final text = preset ?? _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add((key: text, user: true));
      _typing = true;
      _controller.clear();
    });
    await _dummyApi.chat(text);
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add((key: 'chatReply', user: false));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final suggestions = [l10n.whatIsMyBmi, l10n.analyzeMyReport, l10n.suggestHealthyFood, l10n.todaysWorkout, l10n.improveMySleep];
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/chat'),
      appBar: AppNavBar(
        title: l10n.healGuiAiAssistant,
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
                  if (_typing && i == _messages.length) return _ChatBubble(text: l10n.typing, user: false);
                  final message = _messages[i];
                  return _ChatBubble(text: '${_chatMessageText(l10n, message.key)}\n${TimeOfDay.now().format(context)}', user: message.user);
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
                      decoration: InputDecoration(labelText: l10n.askAboutHealth, prefixIcon: const Icon(Icons.auto_awesome)),
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
    final l10n = context.l10n;
    final sliders = {'weight': weight, 'walking': walking, 'sleep': sleep, 'water': water, 'exercise': exercise, 'smoking': smoking, 'alcohol': alcohol};
    return AppScaffold(
      title: l10n.futureHealth,
      child: Column(
        children: [
          for (final item in sliders.entries)
            ListTile(
              title: Text(_sliderLabel(l10n, item.key)),
              subtitle: Slider(value: item.value, max: _sliderMax(item.key), onChanged: (value) => setState(() => _setSlider(item.key, value))),
              trailing: Text(item.value.toStringAsFixed(1)),
            ),
          PrimaryButton(label: l10n.predict, icon: Icons.insights_outlined, onPressed: () => setState(() => prediction = _api.futureHealth(sliders))),
          if (prediction != null) ...[
            const SizedBox(height: 18),
            AsyncView<Map<String, dynamic>>(load: () => prediction!, builder: (_, data) => _InfoList(title: l10n.prediction, items: _predictionItems(l10n, data))),
            const MiniChart(values: [91, 92, 94, 95, 97]),
          ],
        ],
      ),
    );
  }

  void _setSlider(String key, double value) {
    switch (key) {
      case 'weight':
        weight = value;
        break;
      case 'walking':
        walking = value;
        break;
      case 'sleep':
        sleep = value;
        break;
      case 'water':
        water = value;
        break;
      case 'exercise':
        exercise = value;
        break;
      case 'smoking':
        smoking = value;
        break;
      case 'alcohol':
        alcohol = value;
        break;
    }
  }
}

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.personalizedDiet,
      child: AsyncView<Map<String, dynamic>>(
        load: _api.diet,
        builder: (_, data) => Column(
          children: [
            _InfoList(title: l10n.targets, items: _dietTargets(l10n, data)),
            const SizedBox(height: 16),
            _InfoList(title: l10n.dailyPlan, items: _dailyPlan(l10n, data)),
          ],
        ),
      ),
    );
  }
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  var _period = 'W';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/progress'),
      body: AppScaffold(
        title: l10n.progress,
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: [ButtonSegment(value: 'W', label: Text(l10n.weekly)), ButtonSegment(value: 'M', label: Text(l10n.monthly)), ButtonSegment(value: 'Y', label: Text(l10n.yearly))],
              selected: {_period},
              onSelectionChanged: (selection) => setState(() => _period = selection.first),
            ),
            const SizedBox(height: 18),
            const MiniChart(values: [72, 71.8, 71.5, 71.6, 71.2, 70.9, 70.6]),
            const SizedBox(height: 18),
            AsyncView<List<Map<String, dynamic>>>(
              key: ValueKey(_period),
              load: () => _api.progress(period: _period),
              builder: (_, entries) => _InfoList(title: l10n.progress, items: _progressItems(l10n, entries)),
            ),
            const SizedBox(height: 18),
            _InfoList(title: l10n.medicalTimeline, items: _medicalTimeline(l10n)),
          ],
        ),
      ),
    );
  }
}

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  var _query = '';
  late Future<List<Map<String, dynamic>>> _futureReports = _api.reports();

  Future<void> _deleteReport(int id) async {
    await _api.deleteReport(id);
    setState(() => _futureReports = _api.reports());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.reportHistory,
      child: Column(
        children: [
          AppTextField(label: l10n.searchReports, icon: Icons.search, onChanged: (value) => setState(() => _query = value.trim().toLowerCase())),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureReports,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) return const LoadingSkeleton();
              if (snapshot.hasError) return ErrorState(onRetry: () => setState(() => _futureReports = _api.reports()));
              final reports = (snapshot.data ?? const <Map<String, dynamic>>[])
                  .where((report) => _query.isEmpty || '${report['title'] ?? ''}'.toLowerCase().contains(_query))
                  .toList();
              if (reports.isEmpty) return EmptyState();
              return Column(
                children: [
                  for (final report in reports)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text('${report['title'] ?? l10n.previousReport}'),
                        subtitle: Text(l10n.previousReport),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(onPressed: () {}, icon: const Icon(Icons.visibility_outlined)),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.download_outlined)),
                            IconButton(onPressed: () => _deleteReport(report['id'] as int), icon: const Icon(Icons.delete_outline)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await _api.logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      bottomNavigationBar: _BottomNav(current: '/profile'),
      body: AppScaffold(
        title: l10n.profile,
        child: AsyncView<Map<String, dynamic>>(
          load: _api.profile,
          builder: (_, profile) => Column(
            children: [
              const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 50)),
              const SizedBox(height: 10),
              Text('${profile['name'] ?? l10n.profileName}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              for (final item in [l10n.edit, l10n.medicalDetails, l10n.emergencyContact, l10n.notifications, l10n.privacy, l10n.language, l10n.about])
                Card(child: ListTile(title: Text(item), trailing: const Icon(Icons.chevron_right))),
              PrimaryButton(label: l10n.logout, icon: Icons.logout, onPressed: () => _logout(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.settings,
      child: Column(
        children: [
          SwitchListTile(value: true, onChanged: null, title: Text(l10n.darkMode)),
          SwitchListTile(value: true, onChanged: null, title: Text(l10n.notifications)),
          ListTile(title: Text(l10n.units), trailing: Text(l10n.metric)),
          ListTile(title: Text(l10n.fontSize), trailing: Text(l10n.defaultLabel)),
          Card(
            child: Column(
              children: [
                ListTile(title: Text(l10n.language)),
                const LanguageRadioSelector(),
              ],
            ),
          ),
          ListTile(title: Text(l10n.terms)),
          ListTile(title: Text(l10n.privacy)),
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
    final l10n = context.l10n;
    final features = [
      (l10n.miniGames, Icons.sports_esports_outlined, '/games'),
      (l10n.medicalReports, Icons.upload_file_outlined, '/upload'),
      (l10n.healthAnalysis, Icons.monitor_heart_outlined, '/analysis'),
      (l10n.aiChat, Icons.chat_bubble_outline, '/chat'),
      (l10n.futureHealth, Icons.insights_outlined, '/future'),
      (l10n.diet, Icons.restaurant_menu, '/diet'),
      (l10n.progress, Icons.trending_up, '/progress'),
      (l10n.reports, Icons.folder_copy_outlined, '/reports'),
      (l10n.profile, Icons.person_outline, '/profile'),
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
  const _UploadBox({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(children: [Icon(icon, size: 42), const SizedBox(height: 10), Text(label, style: const TextStyle(fontWeight: FontWeight.w800)), Text(context.l10n.previewReady)]),
        ),
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
    final l10n = context.l10n;
    final destinations = [
      ('/home', Icons.home_outlined, l10n.home),
      ('/analysis', Icons.monitor_heart_outlined, l10n.analysis),
      ('/chat', Icons.chat_bubble_outline, l10n.aiChat),
      ('/progress', Icons.trending_up, l10n.progress),
      ('/profile', Icons.person_outline, l10n.profile),
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
