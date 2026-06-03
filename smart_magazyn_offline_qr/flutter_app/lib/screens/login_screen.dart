import 'package:flutter/material.dart';
import '../main.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController(text: 'admin');
  final password = TextEditingController(text: 'admin123');
  bool loading = false;

  Future<void> doLogin() async {
    setState(() => loading = true);
    try {
      final user = await db.login(username.text.trim(), password.text);
      await session.login(user);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Smart Magazyn Offline', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Baza SQLite działa lokalnie na tablecie. Backend i internet nie są potrzebne.'),
                  const SizedBox(height: 20),
                  TextField(controller: username, decoration: const InputDecoration(labelText: 'Login')),
                  const SizedBox(height: 12),
                  TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Hasło')),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: loading ? null : doLogin,
                    child: Text(loading ? 'Logowanie...' : 'Zaloguj'),
                  ),
                  const SizedBox(height: 8),
                  const Text('Domyślnie: admin / admin123 albo pracownik / pracownik123'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
