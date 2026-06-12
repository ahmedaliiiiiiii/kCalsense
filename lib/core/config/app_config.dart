/// ✅ API keys من --dart-define — مش hardcoded في الكود
/// 
/// طريقة الاستخدام عند الـ run:
///   flutter run --dart-define=GEMINI_API_KEY=your_key_here
/// 
/// أو في الـ launch.json:
///   "args": ["--dart-define=GEMINI_API_KEY=your_key_here"]
class AppConfig {
  AppConfig._();

  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '', // فاضي في production — lazim تحط الـ key في الـ CI/CD
  );

  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://foodrecognitionapp.runasp.net/api',
  );
}
