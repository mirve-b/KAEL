import 'package:kael/API/gemini_service.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/PROFILE/DATA%20MODEL/job_match_result.dart';

class JobMatchService {
  final GeminiService _gemini;

  JobMatchService({GeminiService? gemini}) : _gemini = gemini ?? GeminiService();

  Future<JobMatchResult> analyze({
    required UserDataModel user,
    required String jobDescription,
  }) async {
    user.ensureEducationSeeded();

    final prompt = '''
You are Kael's ATS job-match engine. Compare a candidate profile to a job description.

Return ONLY valid JSON (no markdown fences, no commentary) with this exact shape:
{
  "compatibilityPercent": <integer 0-100>,
  "tailoredSummary": "<2-4 sentence professional summary tailored to THIS job>",
  "matchNotes": ["<strength>", "<gap or tip>", "<optional third note>"],
  "skillIndices": [<indices of relevant skills from list below>],
  "experienceIndices": [<indices of relevant experience entries>],
  "projectIndices": [<indices of relevant projects>],
  "certificationIndices": [<indices of relevant certifications>],
  "educationIndices": [<indices of relevant education entries>],
  "languageIndices": [<indices of relevant languages>]
}

Rules:
- compatibilityPercent must reflect honest overlap between candidate and job requirements.
- Only include indices that exist in the candidate data. Omit irrelevant entries entirely.
- Prefer quality over quantity — a tight, job-targeted CV beats listing everything.
- tailoredSummary should sound like a CV summary for this specific role.
- matchNotes: 2-3 short bullets explaining the score (strengths + gaps).

=== JOB DESCRIPTION ===
$jobDescription

=== CANDIDATE PROFILE ===
${user.buildFullCvContextForAi()}
''';

    final raw = await _gemini.generateText(prompt, timeout: const Duration(seconds: 90));
    final parsed = JobMatchResult.tryParse(raw, user);
    if (parsed == null) {
      throw FormatException('Could not parse job match response from AI.');
    }
    return parsed;
  }
}
