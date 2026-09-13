import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:terapeuta_assistente_mobile/core/common/widgets/cubits/app_user_cubit.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:terapeuta_assistente_mobile/features/navigation/presentation/pages/main_shell_page.dart';

import 'core/di/service_locator.dart';
import 'core/supabase/supabase_service.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await SupabaseService.initialize();
  await setupServiceLocator();
  _configureEasyLoading();

  runApp(const MyApp());
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(seconds: 2)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorColor = AppPalette.terracotta
    ..backgroundColor = Colors.white
    ..textColor = AppPalette.textPrimary
    ..toastPosition = EasyLoadingToastPosition.bottom
    ..radius = 12
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AppUserCubit>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: EasyLoading.init(),
        home: const AuthGate(),
      ),
    );
  }
}

/// Decides the initial screen once, by checking for a signed-in Supabase
/// session via [AuthBloc]. The decision is cached after the first check and
/// never revisited: once [LoginPage] is showing, further auth outcomes
/// (a user logging in) are navigated explicitly via [MaterialPageRoute]
/// rather than by this widget reacting to the same [AuthBloc] stream —
/// otherwise both would race to swap the screen at once.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Widget? _resolved;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    if (_resolved case final resolved?) return resolved;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          setState(() => _resolved = const MainShellPage());
        } else if (state is AuthFailure) {
          setState(() => _resolved = const LoginPage());
        }
      },
      child: const Scaffold(
        backgroundColor: AppPalette.whiteIce,
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
