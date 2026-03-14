import 'package:flutter/material.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';

class CaseStudyView extends StatelessWidget {
  final ProjectPage project;
  final VoidCallback onBack;

  const CaseStudyView({
    super.key, 
    required this.project, 
    required this.onBack
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Back Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onBack,
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios, color: Colors.white24, size: 14),
                  const SizedBox(width: 8),
                  Text("EDIT MODE", style: TextStyle(color: const Color.fromARGB(69, 255, 255, 255), fontSize: 10, letterSpacing: 1.2)),
                ],
              ),
            ),
            const Text("PREVIEW MODE", style: TextStyle(color: Color(0xFFD4C3A3), fontSize: 10, letterSpacing: 1.2)),
          ],
        ),
        const SizedBox(height: 30),
        
        // Project Title
        Text(
          project.title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFDF9ED), 
            fontSize: 32, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 2.0
          ),
        ),
        const SizedBox(height: 40),

        // Scrollable Case Study Content
        Expanded(
  child: ListView(
    physics: const BouncingScrollPhysics(),
    children: [
      // If project.caseStudy is null, we show a friendly message
      if (project.caseStudy == null)
        _buildSection("NOTICE", "No case study generated yet. Go back and click NEXT to let the AI curate your work.")
      else ...[
        _buildSection("PROBLEM", project.caseStudy!.problem),
        _buildSection("OBJECTIVES", project.caseStudy!.objectives),
        _buildSection("METHODOLOGY", project.caseStudy!.methodology),
        _buildSection("DESIGN DECISIONS", project.caseStudy!.designDecisions),
        
        // This is where your REAL Gemini text is stored!
        _buildSection("AI ANALYSIS & SOLUTION", project.caseStudy!.solution), 
        
        _buildSection("RESULTS", project.caseStudy!.results),
      ],
      const SizedBox(height: 100), 
    ],
  ),
),
      ],
    );
  }

  Widget _buildSection(String title, String placeholderContent) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A), 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromARGB(110, 255, 255, 255)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD4C3A3), 
              fontSize: 14, 
              fontWeight: FontWeight.w600, 
              letterSpacing: 1.5
            ),
          ),
          const SizedBox(height: 20),
          Text(
            placeholderContent,
            style: TextStyle(
              color: const Color.fromARGB(137, 255, 255, 255), 
              fontSize: 14, 
              height: 1.6,
              fontFamily: 'Avenir'
            ),
          ),
        ],
      ),
    );
  }
}