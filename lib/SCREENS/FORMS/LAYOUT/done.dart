import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/HOME/home_screen.dart';

class Done extends StatefulWidget {
  const Done({super.key});

  @override
  State<Done> createState() => _DoneState(); 
}

class _DoneState extends State<Done> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0; 
        });
      }
    });

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
        });
      }
    });

    Timer(const Duration(seconds: 8), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matching your aesthetic
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          curve: Curves.easeIn,
          child: const Text(
            "ALL SET!",
            style: TextStyle(
              fontSize: 24,
              letterSpacing: 2.0,
              fontFamily: 'Serif',
              color: Color.fromARGB(255, 219, 202, 172),
            ),
          ),
        ),
      ),
    );
  }
}