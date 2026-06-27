import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/login.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/signup.dart';

class WelcomeScreen2 extends StatelessWidget {
  const WelcomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF11111), Colors.black],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                'assets/IMAGES/ipad.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            left: MediaQuery.of(context).size.width * 0.4,
            child: _ContentOverlay(),
          ),
        ],
      ),
    );
  }
}

class _ContentOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // FIX: RepaintBoundary "freezes" the blur so it doesn't lag during sliding
    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: const Color.fromARGB(125, 0, 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "CREATIVE INNOVATION\nFOR REGENERATIVE\nFUTURE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF11111),
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _HoverButton(text: "LOG IN", destination: const Login()),
                    const SizedBox(width: 20),
                    _HoverButton(text: "SIGN UP", destination: const Signup()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final String text;
  final Widget destination;
  const _HoverButton({required this.text, required this.destination});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  void _handleTap() {
    // FIX: Standard Navigator.push uses the default smooth slide animation
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => widget.destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          padding: EdgeInsets.symmetric(
            horizontal: _isHovered ? 45 : 35,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF11111) : Colors.transparent,
            border: Border.all(color: const Color(0xFFF11111), width: 1.5),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: _isHovered ? Colors.white : const Color(0xFFF11111),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}