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
    final charcoal = theme.canvasBackground;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: charcoal,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (heroImagePath != null)
            LayoutBuilder(
              builder: (context, constraints) {
                final imageHeight = constraints.maxHeight * 0.30;
                final fadeHeight = constraints.maxHeight * 0.28;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: charcoal),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: imageHeight + fadeHeight,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                        child: Image.file(
                          File(heroImagePath),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: imageHeight + fadeHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              charcoal.withValues(alpha: 0.15),
                              charcoal.withValues(alpha: 0.42),
                              charcoal.withValues(alpha: 0.72),
                              charcoal.withValues(alpha: 0.92),
                              charcoal,
                            ],
                            stops: const [0.0, 0.35, 0.50, 0.65, 0.78, 0.90, 1.0],
                          ),
                        ),
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
