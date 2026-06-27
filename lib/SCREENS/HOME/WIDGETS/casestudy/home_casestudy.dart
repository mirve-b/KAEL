import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';

class CaseStudyView extends StatelessWidget {
  final ProjectPage project;
  final VoidCallback onBackToEdit;
  final VoidCallback onDonePressed;

  const CaseStudyView({
    super.key,
    required this.project,
    required this.onBackToEdit,
    required this.onDonePressed,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = project.allImagePaths;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!project.isSaved)
              GestureDetector(
                onTap: onBackToEdit,
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back_ios, color: Colors.white24, size: 14),
                    SizedBox(width: 8),
                    Text(
                      'EDIT WORKSPACE',
                      style: TextStyle(
                        color: Color.fromARGB(120, 255, 255, 255),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),
            GestureDetector(
              onTap: project.isSaved ? onBackToEdit : onDonePressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: project.isSaved ? Colors.transparent : Colors.red.shade900,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade900),
                ),
                child: Text(
                  project.isSaved ? 'ENTER EDIT MODE' : 'DONE & SAVE',
                  style: TextStyle(
                    color: project.isSaved ? Colors.red.shade200 : Colors.white,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          project.title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFDF9ED),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              if (project.caseStudy == null)
                _buildSection(
                  'NOTICE',
                  'No case study generated yet. Go back and click NEXT to let the AI curate your work.',
                )
              else ...[
                if (project.caseStudy!.overview.isNotEmpty)
                  _buildSection('OVERVIEW', project.caseStudy!.overview),
                _buildSection('PROBLEM', project.caseStudy!.problem),
                _buildSection('OBJECTIVES', project.caseStudy!.objectives),
                _buildSection('METHODOLOGY', project.caseStudy!.methodology),
                _buildSection(
                  'DESIGN DECISIONS',
                  project.caseStudy!.designDecisions,
                  trailingVisualGrid: imagePaths.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: _buildImageGrid(imagePaths),
                        )
                      : null,
                ),
                _buildSection('SOLUTION', project.caseStudy!.solution),
                _buildSection('RESULTS', project.caseStudy!.results),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(List<String> paths) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paths.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: paths.length == 1 ? 1 : (paths.length <= 4 ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 16 / 10,
      ),
      itemBuilder: (context, idx) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(paths[idx]),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.white10,
            child: const Icon(Icons.broken_image, color: Colors.white24),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String markdownContent, {Widget? trailingVisualGrid}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(24, 255, 255, 255)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.red.shade300,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          MarkdownBody(
            data: markdownContent,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                color: Color.fromARGB(220, 255, 255, 255),
                fontSize: 14,
                height: 1.7,
                fontFamily: 'Inter',
              ),
              strong: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              em: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
              ),
              listBullet: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
              ),
              blockSpacing: 14,
              listIndent: 20,
            ),
          ),
          if (trailingVisualGrid != null) trailingVisualGrid,
        ],
      ),
    );
  }
}
