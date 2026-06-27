import 'dart:io';
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      color: theme.canvasBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (heroImagePath != null)
            LayoutBuilder(
              builder: (context, constraints) {
                final imageHeight = constraints.maxHeight * 0.48;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: theme.canvasBackground),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Stack(
                        key: ValueKey(heroImagePath),
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: imageHeight,
                            child: Image.file(
                              File(heroImagePath),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: imageHeight + 80,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    theme.canvasBackground.withValues(alpha: 0.35),
                                    theme.canvasBackground,
                                  ],
                                  stops: const [0.35, 0.72, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    theme.canvasBackground.withValues(alpha: 0.85),
                                    theme.canvasBackground,
                                  ],
                                  stops: const [0.42, 0.58, 1.0],
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
