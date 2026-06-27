import 'dart:ui';
import 'package:flutter/material.dart';

class PortfolioEmptyState extends StatelessWidget {
  final VoidCallback onGenerateTap;

  const PortfolioEmptyState({super.key, required this.onGenerateTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: const ValueKey("EmptyPortfolioState"),
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(95, 12, 12, 12),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white10),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.art_track_rounded,
                  color: Color.fromARGB(15, 212, 195, 163),
                  size: 90,
                ),
                const SizedBox(height: 25),
                const Text(
                  "NO PORTFOLIO ACTIVATED",
                  style: TextStyle(
                    color: Color.fromARGB(80, 158, 143, 103),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Compile your generated case studies into an opulent showcase layout.",
                  style: TextStyle(color: Colors.white10, fontSize: 11, letterSpacing: 0.5),
                ),
                const SizedBox(height: 35),
                GestureDetector(
                  onTap: onGenerateTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4C3A3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "GENERATE YOUR PORTFOLIO",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}