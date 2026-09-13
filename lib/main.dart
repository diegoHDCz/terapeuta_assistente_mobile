import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:terapeuta_assistente_mobile/core/common/widgets/cubits/app_user_cubit.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:terapeuta_assistente_mobile/features/home/presentation/pages/home_page.dart';

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

/// Decides the initial screen: checks for a signed-in Supabase session via
/// [AuthBloc] and mirrors the result into [AppUserCubit], then shows
/// [HomePage] or [LoginPage] accordingly.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppUserCubit, AppUserState, bool>(
      selector: (state) => state is AppUserLoggedIn,
      builder: (context, isLoggedIn) {
        if (isLoggedIn) return const HomePage();

        return BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) => !isLoggedIn,
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                backgroundColor: AppPalette.whiteIce,
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const LoginPage();
          },
        );
      },
    );
  }
}
