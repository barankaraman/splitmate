import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/user_provider.dart';

enum AuthMode { login, signUp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  AuthMode _authMode = AuthMode.login;
  bool _obscure = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Check if session is already restored by initialize()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService.instance.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    bool success;
    if (_authMode == AuthMode.login) {
      success = await AuthService.instance.login(
        _userController.text.trim(),
        _passController.text,
      );
    } else {
      success = await AuthService.instance.signUp(
        _userController.text.trim(),
        _passController.text,
      );
    }

    if (!mounted) return;

    if (success) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.refresh(); // Signal providers that user changed

      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() {
        _loading = false;
        _errorMessage = _authMode == AuthMode.login 
            ? 'Invalid username or password.' 
            : 'Username already exists.';
      });
    }
  }

  void _switchMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.signUp : AuthMode.login;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined,
                        size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SplitMate',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _authMode == AuthMode.login ? 'Welcome back' : 'Create an account',
                    style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white70 : AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _userController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    textInputAction: _authMode == AuthMode.signUp ? TextInputAction.next : TextInputAction.done,
                    onFieldSubmitted: _authMode == AuthMode.login ? (_) => _submit() : null,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (_authMode == AuthMode.signUp && v.length < 3) return 'At least 3 characters';
                      return null;
                    },
                  ),
                  
                  if (_authMode == AuthMode.signUp) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPassController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_reset_outlined,
                            color: AppColors.primary),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v != _passController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 12),

                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(_authMode == AuthMode.login ? 'Login' : 'Sign Up',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  TextButton(
                    onPressed: _loading ? null : _switchMode,
                    child: Text(_authMode == AuthMode.login 
                        ? "Don't have an account? Sign Up" 
                        : "Already have an account? Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
