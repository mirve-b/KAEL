import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';

class PortfolioProjectGrid extends StatelessWidget {
  final ProjectProvider projectsProvider;
  final Function(String?) onProjectSelect;

  const PortfolioProjectGrid({
    super.key,
    required this.projectsProvider,
    required this.onProjectSelect,
  });

  @override
  Widget build(BuildContext context) {
    final savedCaseStudies = projectsProvider.projects
        .where((project) => project.isSaved == true)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: const Text(
            "MY WORK",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        savedCaseStudies.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text("NO COMPLETED CASE STUDIES SAVED", style: TextStyle(color: Colors.white12, fontSize: 10))),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color.fromARGB(60, 150, 143, 132), width: 1),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1000 ? 4 : 3;
                    double spacing = 30;
                    double cardWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1)) - 50) / crossAxisCount;
                    double cardHeight = cardWidth * 0.8;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: 20,
                      children: savedCaseStudies.map((project) {
                        return SizedBox(
                          width: cardWidth,
                          height: cardHeight + 30, // Extra space for title
                          child: HoverableProjectCard(
                            project: project,
                            targetHeight: cardHeight,
                            onTap: onProjectSelect,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
      ],
    );
  }
}

class HoverableProjectCard extends StatefulWidget {
  final ProjectPage project;
  final double targetHeight;
  final Function(String?) onTap;

  const HoverableProjectCard({super.key, required this.project, required this.targetHeight, required this.onTap});

  @override
  State<HoverableProjectCard> createState() => _HoverableProjectCardState();
}

class _HoverableProjectCardState extends State<HoverableProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final imageCells = widget.project.cells.where((c) => c.type == "image").toList();
    final String? firstImagePath = imageCells.isNotEmpty ? imageCells.first.content : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.project.id),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack, // This creates the "bouncy" effect
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: widget.targetHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 25, 25, 25),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: firstImagePath != null
                    ? Image.file(File(firstImagePath), fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildTextThumbnail())
                    : _buildTextThumbnail(),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  widget.project.title.toUpperCase(),
                  style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextThumbnail() {
    return Center(
      child: Text(
        widget.project.title.toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color.fromARGB(140, 214, 195, 163), fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}