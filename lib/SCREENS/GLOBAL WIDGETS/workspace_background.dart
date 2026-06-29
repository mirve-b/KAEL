import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class WorkspaceBackground extends StatelessWidget {
  final Widget child;

  const WorkspaceBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataModel>();
    final theme = KaelTheme.of(context.watch<ProjectProvider>().isLightMode);

    final String? heroImagePath = userData.bannerPath ?? userData.finalPfpPath;
    final fadeTarget = theme.isLightMode
        ? Colors.white
        : const Color(0xFF121212);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      color: fadeTarget,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (heroImagePath != null)
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: fadeTarget),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Stack(
                        key: ValueKey(heroImagePath),
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Image.file(
                                File(heroImagePath),
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                          // 0–6% pure image · 6–46% fade (40%) · 46–100% solid.
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    fadeTarget.withValues(alpha: 0.05),
                                    fadeTarget.withValues(alpha: 0.12),
                                    fadeTarget.withValues(alpha: 0.22),
                                    fadeTarget.withValues(alpha: 0.35),
                                    fadeTarget.withValues(alpha: 0.50),
                                    fadeTarget.withValues(alpha: 0.66),
                                    fadeTarget.withValues(alpha: 0.82),
                                    fadeTarget.withValues(alpha: 0.94),
                                    fadeTarget,
                                    fadeTarget,
                                  ],
                                  stops: const [
                                    0.0,
                                    0.06,
                                    0.12,
                                    0.18,
                                    0.24,
                                    0.30,
                                    0.36,
                                    0.40,
                                    0.44,
                                    0.46,
                                    0.49,
                                    1.0,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          child,
        ],
      ),
    );
  }
}
