
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_app/src/features/auth/presentation/state/login_state.dart';
import 'package:guardian_app/src/shared/widgets/app_logo.dart';
import 'package:guardian_app/src/shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    ref.listen<AsyncValue<void>>(
      loginControllerProvider,
      (previous, next) {
        if (next.hasError && !next.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error.toString())),
          );
        }
        if (next.hasValue) {
          GoRouter.of(context).go('/');
        }
      },
    );

    final loginState = ref.watch(loginControllerProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLogo(size: 64),
                const SizedBox(height: 48),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Login',
                  isLoading: loginState.isLoading,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      ref
                          .read(loginControllerProvider.notifier)
                          .login(usernameController.text, passwordController.text);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => GoRouter.of(context).go('/signup'),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
