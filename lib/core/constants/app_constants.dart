import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central place to read `.env`-backed configuration.
class AppConstants {
  AppConstants._();

  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Deep link Supabase redirects back to after the Google OAuth flow.
  /// Matches the intent-filter in AndroidManifest.xml and the
  /// CFBundleURLTypes entry in Info.plist.
  static String get googleOAuthRedirectUrl =>
      dotenv.env['GOOGLE_OAUTH_REDIRECT_URL'] ?? 'br.com.terapeuta.assistente.mobile://login-callback';
}
