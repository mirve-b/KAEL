import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/LAYOUT/form1.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/login.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isBackHovered = false;
  bool _isSignupHovered = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _trySignup() {
    if (_formKey.currentState!.validate()) {
      final userModel = Provider.of<UserDataModel>(context, listen: false);
      userModel.signupUser(
        full: _nameController.text.trim(),
        mail: _emailController.text.trim(),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Form1()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset('assets/IMAGES/LAND.png', fit: BoxFit.cover),
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
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4C3A3), size: 20),
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
                    gradient: const RadialGradient(
                      center: Alignment.topLeft,
                      radius: 2,
                      colors: [Color(0xFF8B0000), Colors.black],
                    ),
                    border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        top: 0,
                        left: 0,
                        child: Text("01.", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("CREATE AN ACCOUNT", style: TextStyle(fontSize: 32, fontFamily: 'Inter', color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                            const Text("SIGN UP TO START", style: TextStyle(fontSize: 14, fontFamily: 'Inter', color: Colors.white70, letterSpacing: 1.2)),
                            const SizedBox(height: 50),
                            _buildTextField(_nameController, "FULL NAME"),
                            const SizedBox(height: 15),
                            _buildTextField(_emailController, "EMAIL"),
                            const SizedBox(height: 15),
                            _buildTextField(_passwordController, "PASSWORD", obscure: true),
                            const SizedBox(height: 30),
                            _buildSignupButton(),
                            const SizedBox(height: 20),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.white60, fontFamily: "Avenir Next", fontSize: 12),
                                children: [
                                  const TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    text: "LOG IN",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Login())),
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

  Widget _buildSignupButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isSignupHovered = true),
      onExit: (_) => setState(() => _isSignupHovered = false),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          onPressed: _trySignup,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("SIGN UP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}