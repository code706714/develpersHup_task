import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
    this.isLoading = false,
    this.errorMessage,
  });

  final void Function(String email, String password) onSignIn;
  final void Function(String username, String email, String password)
      onSignUp;

  final bool isLoading;
  final String? errorMessage;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUpMode = true;
  bool _obscurePassword = true;
  String? _localError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUpMode &&
        _usernameController.text.trim().isEmpty) {
      setState(() {
        _localError = "Please enter username";
      });
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _localError = "Please enter a valid email";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _localError =
            "Password must be at least 6 characters";
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    if (_isSignUpMode) {
      widget.onSignUp(_usernameController.text.trim(), email, password);
    } else {
      widget.onSignIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.errorMessage ?? _localError;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUpMode = true;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _isSignUpMode
                                  ? Colors.indigo
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            color: _isSignUpMode
                                ? Colors.indigo
                                : Colors.transparent,
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUpMode = false;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: !_isSignUpMode
                                  ? Colors.indigo
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            color: !_isSignUpMode
                                ? Colors.indigo
                                : Colors.transparent,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              if (_isSignUpMode) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Enter your username",
                    prefixIcon:
                        const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                  prefixIcon:
                      const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  prefixIcon:
                      const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed:
                      widget.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: widget.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          _isSignUpMode
                              ? "Create Account"
                              : "Sign In",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSignUpMode = !_isSignUpMode;
                  });
                },
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: _isSignUpMode
                            ? "Already have an account? "
                            : "Don't have an account? ",
                      ),
                      TextSpan(
                        text: _isSignUpMode
                            ? "Sign In"
                            : "Sign Up",
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}