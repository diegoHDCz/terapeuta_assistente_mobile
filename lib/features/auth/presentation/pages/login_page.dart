import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';
import 'package:terapeuta_assistente_mobile/core/utils/show_toast.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/pages/signup_page.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/widgets/auth_field.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/widgets/google_logo.dart';
import 'package:terapeuta_assistente_mobile/features/home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthLogin(email: _emailController.text.trim(), password: _passwordController.text),
    );
  }

  void _handleGoogleLogin() {
    context.read<AuthBloc>().add(AuthLoginWithGoogle());
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          showErrorToast(state.message);
        } else if (state is AuthSuccess) {
          showSuccessToast('Bem-vindo(a) de volta, ${state.user.name}!');
          _goToHome();
        }
      },
      builder: (context, state) {
        final isSubmitting = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppPalette.whiteIce,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppPalette.glassShadow,
                            ),
                            child: Image.asset('assets/logo.png'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Bem-vindo de volta',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Entre para continuar seu acompanhamento',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppPalette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AuthField(
                          hintText: 'E-mail',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.mail_outline,
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          hintText: 'Senha',
                          controller: _passwordController,
                          isPassword: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            color: AppPalette.textSecondary,
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppPalette.terracottaDark,
                            ),
                            child: const Text('Esqueceu sua senha?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _handleLogin,
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppPalette.textOnBrand,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppPalette.textSecondary.withValues(alpha: 0.25),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('ou continue com', style: textTheme.bodySmall),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppPalette.textSecondary.withValues(alpha: 0.25),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: isSubmitting ? null : _handleGoogleLogin,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: AppPalette.textSecondary.withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const GoogleLogo(),
                            label: Text(
                              'Continuar com Google',
                              style: textTheme.titleSmall?.copyWith(
                                color: AppPalette.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Não tem uma conta?', style: textTheme.bodyMedium),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SignupPage()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppPalette.terracottaDark,
                              ),
                              child: const Text('Criar conta'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
