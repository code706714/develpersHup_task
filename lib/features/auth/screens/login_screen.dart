import 'package:flutter/material.dart';
import '../server/auth_surver.dart';
import '../widgets/login_form.dart';
import '../../home/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithEmail(
    String email,
    String password,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = _authService.messageForError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithEmail(
    String username,
    String email,
    String password,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = _authService.messageForError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LoginForm(
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onSignIn: _signInWithEmail,
            onSignUp: _signUpWithEmail,
          ),
        ),
      ),
    );
  }
}