import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';
import 'package:terapeuta_assistente_mobile/core/utils/show_toast.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/widgets/auth_field.dart';
import 'package:terapeuta_assistente_mobile/features/auth/presentation/widgets/google_logo.dart';
import 'package:terapeuta_assistente_mobile/features/navigation/presentation/pages/main_shell_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthSignUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _handleGoogleSignup() {
    context.read<AuthBloc>().add(AuthSignUpWithGoogle());
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellPage()),
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
          showSuccessToast('Conta criada com sucesso, ${state.user.name}!');
          _goToHome();
        }
      },
      builder: (context, state) {
        final isSubmitting = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppPalette.whiteIce,
          appBar: AppBar(),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppPalette.glassShadow,
                            ),
                            child: Image.asset('assets/logo.png'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Crie sua conta',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Leva menos de um minuto para começar',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppPalette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AuthField(
                          hintText: 'Nome',
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _handleSignup,
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppPalette.textOnBrand,
                                    ),
                                  )
                                : const Text('Criar conta'),
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
                            onPressed: isSubmitting ? null : _handleGoogleSignup,
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
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Já tem uma conta?', style: textTheme.bodyMedium),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppPalette.terracottaDark,
                              ),
                              child: const Text('Entrar'),
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
