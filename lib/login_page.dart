import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';

import 'pin_setup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  bool _isPinLogin = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
    // Clear error message when user starts typing
    _emailCtrl.addListener(() => setState(() => _errorMessage = null));
    _passwordCtrl.addListener(() => setState(() => _errorMessage = null));
    _pinCtrl.addListener(() => setState(() => _errorMessage = null));
  }

  Future<void> _checkPinStatus() async {
    final pin = await _storage.read(key: 'pin');
    setState(() {
      _isPinLogin = pin != null;
      _isLoading = false;
    });
    if (_isPinLogin) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      if (canAuth) {
        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to login',
          options: const AuthenticationOptions(biometricOnly: true),
        );
        if (didAuthenticate) {
          _navigateToHome();
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loginWithEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      _navigateToPinSetup();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message ?? 'Login failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithPin() async {
    final storedPin = await _storage.read(key: 'pin');
    if (storedPin == _pinCtrl.text.trim()) {
      _navigateToHome();
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN';
      });
    }
  }

  Future<void> _forgotPin() async {
    await _storage.deleteAll();
    await FirebaseAuth.instance.signOut();
    setState(() {
      _isPinLogin = false;
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _navigateToPinSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PinSetupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B2C82), Color(0xFF6A4BC7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isPinLogin ? _buildPinLogin() : _buildEmailLogin(),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmailLogin() {
    return Column(
      key: const ValueKey('emailLogin'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: 20),
        Text(
          'Welcome Back',
          style: GoogleFonts.lato(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Sign in to continue',
          style: GoogleFonts.lato(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 40),
        _buildTextField(controller: _emailCtrl, hint: 'Email', icon: Icons.email),
        const SizedBox(height: 20),
        _buildTextField(controller: _passwordCtrl, hint: 'Password', icon: Icons.lock, obscureText: true),
        if (_errorMessage != null) _buildErrorWidget(),
        const SizedBox(height: 40),
        _buildLoginButton(onPressed: _loginWithEmail, text: 'LOGIN'),
      ],
    );
  }

  Widget _buildPinLogin() {
    return Column(
      key: const ValueKey('pinLogin'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: 20),
        Text(
          'Enter PIN',
          style: GoogleFonts.lato(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        _buildTextField(controller: _pinCtrl, hint: 'PIN', icon: Icons.pin, obscureText: true, isPin: true),
        if (_errorMessage != null) _buildErrorWidget(),
        const SizedBox(height: 40),
        _buildLoginButton(onPressed: _loginWithPin, text: 'UNLOCK'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _forgotPin,
              child: Text('Forgot PIN?', style: GoogleFonts.lato(color: Colors.white70)),
            ),
            IconButton(
              onPressed: _authenticateWithBiometrics,
              icon: const Icon(Icons.fingerprint, size: 40, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLogo() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white.withOpacity(0.1),
      child: Text(
        'AF',
        style: GoogleFonts.lato(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
  
  Widget _buildErrorWidget() {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          _errorMessage!,
          style: GoogleFonts.lato(color: Colors.yellow.shade300, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    bool isPin = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: isPin ? TextInputType.number : TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton({required VoidCallback onPressed, required String text}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4B2C82),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
