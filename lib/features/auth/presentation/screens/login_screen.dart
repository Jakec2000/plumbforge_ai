import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@plumbforge.ai');
  final _passCtrl = TextEditingController(text: 'password123');
  bool _isObscured = true;

  void _submit() {
    ref.read(authStateProvider.notifier).login(_emailCtrl.text, _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AsyncValue>(authStateProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString()), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text('PlumbForge AI', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              const Text('Secure Trade Portal'),
              const SizedBox(height: 48),
              
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passCtrl,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Log In', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _emailCtrl.text = 'apprentice@plumbforge.ai';
                  });
                },
                child: const Text('Use Apprentice Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
