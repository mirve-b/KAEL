import 'package:kael/API/case_study/creative_field.dart';
import 'package:kael/API/case_study/field_detector.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';

class CaseStudyPromptBuilder {
  static String build({
    required UserDataModel user,
    required List<ProjectCell> cells,
    required String projectTitle,
    required int totalImages,
    required int imageGroupCount,
  }) {
    final field = FieldDetector.detect(user, cells, projectTitle: projectTitle);
    final profile = FieldProfile.forField(field);
    final creatorContext = user.buildCreativeContextSummary();
    final textAssets = cells
        .where((c) => c.type == 'text')
        .map((c) => 'Title: ${c.title}\nContent: ${c.content}')
        .join('\n\n');

    return """
You are Kael's Case Study Engine — a senior creative writer who produces portfolio-grade case studies.

=== CREATOR PROFILE ===
$creatorContext

=== DETECTED CREATIVE FIELD ===
${profile.displayName}
${profile.disciplineBrief}

Use discipline-specific language: ${profile.vocabulary.join(', ')}.
Do NOT write generic UX copy if the field is ${profile.displayName}. Reflect the creator's title, skills, and experience.

=== UNIVERSAL CREATIVE PIPELINE (translate into section content) ===
1. RESEARCH — ${profile.researchLens}
2. IDEATION — ${profile.ideationLens}
3. CREATION — ${profile.creationLens}
4. REFINEMENT — ${profile.refinementLens}
5. DELIVERY — ${profile.deliveryLens}

Map pipeline phases into the section skeleton below. METHODOLOGY should trace Research→Ideation→Creation→Refinement. RESULTS should reflect Delivery.

=== PROJECT ===
Title: $projectTitle

PROJECT RAW NOTES & ASSETS:
$textAssets

${totalImages > 0 ? 'You have been given $totalImages project image(s) across $imageGroupCount visual group(s). Study them through a ${profile.displayName} lens. Reference specific visual observations in DESIGN DECISIONS and SOLUTION.' : 'No project images were supplied. Infer discipline-appropriate decisions from notes and creator profile.'}

=== KAEL WRITING STYLE ===
- Confident, analytical, first-person plural or first-person singular ("I" / "we")
- Specific over generic — name constraints, materials, tools, and decisions
- **Bold** key terms, metrics, and outcomes in Markdown
- Bullet lists with "-" where appropriate
- No filler phrases like "in today's world" or "leveraging synergies"
- Frame PROBLEM around: ${profile.problemFraming}
- Frame DESIGN DECISIONS around: ${profile.decisionFocus}
- Frame RESULTS around: ${profile.resultsFocus}

=== OUTPUT FORMAT (exact headers for parsing) ===

OVERVIEW:
(2-3 paragraphs — executive summary tying creator background to this ${profile.displayName} project)

PROBLEM:
(Discipline-specific problem framing)

OBJECTIVES:
(Bulleted measurable goals)

METHODOLOGY:
(Research → Ideation → Creation → Refinement mapped to ${profile.displayName})

DESIGN DECISIONS:
(${profile.decisionFocus} — reference visuals if provided)

SOLUTION:
(Final creative deliverable and how it resolves the problem)

RESULTS:
(${profile.resultsFocus} — **bold** standout outcomes; use plausible specifics grounded in project notes)
""";
  }
}
