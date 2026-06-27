import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:kael/SCREENS/LANDING%20PAGE/welcome_screen.dart';

class MiffyLoadingScreen extends StatefulWidget {
  const MiffyLoadingScreen({super.key});

  @override
  State<MiffyLoadingScreen> createState() => _MiffyLoadingScreenState();
}

class _MiffyLoadingScreenState extends State<MiffyLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Bunny scaling animations
  late Animation<double> _bunnyScaleIn;
  late Animation<double> _bunnyWindUp;  // Shrinks away into the screen
  late Animation<double> _bunnyLaunch;  // Pops dynamically toward the camera
  
  // Star drift progress mapping
  late Animation<double> _starDrift;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Slightly prolonged for maximum fluidity
    );

    // 1. Bunny enters with a dramatic, super jumpy elastic bounce
    _bunnyScaleIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.25, curve: Curves.elasticOut),
      ),
    );

    // 2. Stars float away from behind while bunny stands still
    _starDrift = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.25, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    // 3. WIND UP: Bunny shrinks down into the screen (from 72% to 85%)
    _bunnyWindUp = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.72, 0.85, curve: Curves.easeInOutBack),
      ),
    );

    // 4. LAUNCH: Bunny explodes into the camera view with an elastic overview snap! (from 85% to 100%)
    _bunnyLaunch = Tween<double>(begin: 0.5, end: 6.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.85, 1.00, curve: Curves.slowMiddle),
      ),
    );

    // Launch animation engine
    _controller.forward();

    // Route cleanly onto WelcomeScreen2 once the sequence wraps up
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const WelcomeScreen2(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //5 Big Stars
    final List<Map<String, dynamic>> bigStars = [
      {'angle': -math.pi / 2, 'filled': true},    
      {'angle': -math.pi / 6, 'filled': false},   
      {'angle': math.pi / 4, 'filled': true},     
      {'angle': 3 * math.pi / 4, 'filled': false}, 
      {'angle': 7 * math.pi / 6, 'filled': true},   
    ];

    // New 4 Small Stars positioned offset to fill the gaps cleanly
    final List<Map<String, dynamic>> smallStars = [
      {'angle': -math.pi / 3, 'filled': true},    // Upper Right gap
      {'angle': math.pi / 12, 'filled': false},   // Center Right gap
      {'angle': 4 * math.pi / 5, 'filled': true},  // Lower Left gap
      {'angle': -math.pi / 1.2, 'filled': false}, // Upper Left gap
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Calculate the interactive timeline states for the bunny
            double currentBunnyScale = _bunnyScaleIn.value;
            
            if (_controller.value >= 0.72 && _controller.value < 0.85) {
              currentBunnyScale = _bunnyWindUp.value;
            } else if (_controller.value >= 0.85) {
              currentBunnyScale = _bunnyLaunch.value;
            }

            // Calculations for fading the whole scene out at the final peak of the launch jump
            double entireSceneOpacity = 1.0;
            if (_controller.value > 0.94) {
              entireSceneOpacity = ((1.0 - _controller.value) / 0.06).clamp(0.0, 1.0);
            }

            return Opacity(
              opacity: entireSceneOpacity,
              child: SizedBox(
                width: 500,
                height: 500,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    
                    // --- THE 5 BIG DRIFTING STARS ---
                    ...bigStars.map((meta) {
                      double angle = meta['angle'];
                      bool isFilled = meta['filled'];
                      
                      double maxDriftRadius = 150.0;
                      double currentRadius = _starDrift.value * maxDriftRadius;
                      
                      double xOffset = math.cos(angle) * currentRadius;
                      double yOffset = math.sin(angle) * currentRadius;

                      return Transform.translate(
                        offset: Offset(xOffset, yOffset),
                        child: Opacity(
                          opacity: _starDrift.value < 0.1 
                              ? (_starDrift.value / 0.1).clamp(0.0, 1.0)
                              : (1.0 - _starDrift.value).clamp(0.0, 1.0),
                          child: Icon(
                            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color(0xFFD4C3A3),
                            size: 26,
                          ),
                        ),
                      );
                    }),

                    // --- THE 4 SMALL DRIFTING STARS---
                    ...smallStars.map((meta) {
                      double angle = meta['angle'];
                      bool isFilled = meta['filled'];
                      
                      // Shoots much further away to create depth scale!
                      double maxDriftRadius = 240.0; 
                      double currentRadius = _starDrift.value * maxDriftRadius;
                      
                      double xOffset = math.cos(angle) * currentRadius;
                      double yOffset = math.sin(angle) * currentRadius;

                      return Transform.translate(
                        offset: Offset(xOffset, yOffset),
                        child: Opacity(
                          opacity: _starDrift.value < 0.1 
                              ? (_starDrift.value / 0.1).clamp(0.0, 1.0)
                              : (1.0 - _starDrift.value).clamp(0.0, 1.0),
                          child: Icon(
                            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color.fromARGB(160, 212, 195, 163), // Slightly softer alpha tint
                            size: 15, // Dainty/small star sizing
                          ),
                        ),
                      );
                    }),

                    // --- THE BUNNY ---
                    Transform.scale(
                      scale: currentBunnyScale,
                      child: Image.asset(
                        'assets/IMAGES/miffy.png',
                        width: 110,
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}