class ApiConstants {
  ApiConstants._();

  // URL de la API. En produccion: --dart-define=API_URL=https://tu-api.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Endpoints
  static const String login = '/api/auth/login';
  static const String forgotPassword = '/api/auth/olvide-contrasena';
  static const String resetPassword = '/api/auth/restablecer-contrasena';
  static const String register = '/api/auth/register';
  static const String users = '/api/users';
  static const String materials = '/api/materials';
  static const String categories = '/api/categories';
  static const String loans = '/api/loans';
  static const String returns = '/api/returns';
  static const String dashboard = '/api/dashboard';

  // Timeouts
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
