import '../models/health_models.dart';

class DummyApiService {
  const DummyApiService();

  Future<Map<String, dynamic>> login() => _delayed({
        'status': true,
        'message': 'Login Successful',
        'user': 'John',
      });

  Future<Map<String, dynamic>> signUp() => _delayed({'status': true, 'userId': '1001'});
  Future<Map<String, dynamic>> saveProfile() => _delayed({'status': true, 'message': 'Profile Saved'});

  Future<DashboardData> dashboard() async => DashboardData.fromJson(await _delayed({
        'healthScore': 91,
        'bmi': 22.4,
        'bioAge': 23,
        'bp': '120/80',
        'heartRate': 74,
        'sleep': 7.8,
        'steps': 8230,
        'water': '2.5L',
        'calories': 640,
      }));

  Future<Map<String, dynamic>> gameResult() => _delayed({'score': 88, 'status': 'Good'});
  Future<Map<String, dynamic>> reportAnalysis() => _delayed({
        'bloodSugar': 'Normal',
        'cholesterol': 'Slightly High',
        'bp': '120/80',
        'summary': 'Healthy',
      });
  Future<Map<String, dynamic>> analysis() => _delayed({
        'healthScore': 92,
        'risk': 'Low',
        'bioAge': 24,
        'bmi': 21.9,
        'stress': 'Medium',
      });
  Future<Map<String, dynamic>> futureHealth() => _delayed({
        'futureHealthScore': 97,
        'bioAge': 21,
        'risk': 'Very Low',
      });
  Future<Map<String, dynamic>> diet() => _delayed({'calories': 2200, 'protein': '110g', 'water': '3L'});
  Future<String> chat(String message) => _delayed(
        'Based on your current data, your Health Score is 91/100. Your BMI is normal. Continue daily walking and drink more water.',
      );

  Future<T> _delayed<T>(T value) => Future<T>.delayed(const Duration(milliseconds: 900), () => value);
}
