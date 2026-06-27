import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/HOME/home_screen.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isBackHovered = false;
  bool _isLoginHovered = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _trySubmit() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/IMAGES/land.png',
              fit: BoxFit.cover,
            ),
          ),

          // BACK BUTTON
          Positioned(
            top: 40,
            left: 20,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isBackHovered = true),
              onExit: (_) => setState(() => _isBackHovered = false),
              cursor: SystemMouseCursors.click,
              child: AnimatedScale(
                scale: _isBackHovered ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFFD4C3A3),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // MAIN CONTENT
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 900),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
                  decoration: BoxDecoration(
                    // Gradient fill as requested
                    gradient: const RadialGradient(
                      center: Alignment.topLeft,
                      radius: 2,
                      colors: [
                        Color(0xFF8B0000), // Dark red
                        Colors.black,       // Fading to black
                      ],
                    ),
                    border: Border.all(color: const Color.fromARGB(80, 244, 67, 54), width: 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      // "01." text in top left
                      const Positioned(
                        top: 0,
                        left: 0,
                        child: Text(
                          "01.",
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("WELCOME BACK", style: TextStyle(fontSize: 32, fontFamily: 'Inter', color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                            const Text("LOGIN TO CONTINUE", style: TextStyle(fontSize: 14, fontFamily: 'Inter', color: Colors.white70, letterSpacing: 1.2)),
                            const SizedBox(height: 50),
                            _buildTextField(_emailController, "EMAIL"),
                            const SizedBox(height: 15),
                            _buildTextField(_passwordController, "PASSWORD", obscure: true),
                            const SizedBox(height: 30),
                            _buildLoginButton(),
                            const SizedBox(height: 20),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.white60, fontFamily: "Avenir Next", fontSize: 12),
                                children: [
                                  const TextSpan(text: "Don't have an account? "),
                                  TextSpan(
                                    text: "CREATE ACCOUNT",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Signup())),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
      ),
      validator: (v) => v!.isEmpty ? "$hint CANNOT BE EMPTY" : null,
    );
  }

  Widget _buildLoginButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isLoginHovered = true),
      onExit: (_) => setState(() => _isLoginHovered = false),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          onPressed: _trySubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}