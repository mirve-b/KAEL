import 'package:kael/API/gemini_service.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class BioGeneratorService {
  final GeminiService _gemini;

  BioGeneratorService({GeminiService? gemini}) : _gemini = gemini ?? GeminiService();

  Future<String> generate(UserDataModel user) async {
    try {
      final prompt = '''
Write a professional summary (2-3 sentences) for this person's CV and portfolio.

Rules:
- First person is OK ("I am..." or neutral third person)
- Mention their title and strongest skills naturally
- Confident, specific, ATS-friendly — no buzzword stuffing
- No markdown, bullet points, or labels
- Return ONLY the summary paragraph

Name: ${user.name.isEmpty ? 'Not provided' : user.name}
Title: ${user.title.isEmpty ? 'Not provided' : user.title}
Country: ${user.country.isEmpty ? 'Not provided' : user.country}
Education: ${user.educationLevel ?? ''} ${user.fieldOfStudy} ${user.institution}
Skills: ${user.skills.isEmpty ? 'Not provided' : user.skills.join(', ')}
Interests: ${user.interests.isEmpty ? 'Not provided' : user.interests.join(', ')}
Hobbies: ${user.hobbies.isEmpty ? 'Not provided' : user.hobbies}
Languages: ${user.languages.isEmpty ? 'Not provided' : user.languages.join(', ')}
''';

    final raw = await _gemini.generateText(prompt, timeout: const Duration(seconds: 60));
    final cleaned = raw.trim().replaceAll(RegExp(r'^["\x27]|["\x27]$'), '');
    if (cleaned.isNotEmpty) return cleaned;
    return fallback(user);
    } catch (_) {
      return fallback(user);
    }
  }

  String fallback(UserDataModel user) {
    if (user.title.isNotEmpty && user.skills.isNotEmpty) {
      return '${user.title} with expertise in ${user.skills.take(4).join(', ')}. Passionate about creating thoughtful, high-quality work across ${user.interests.isNotEmpty ? user.interests.first.toLowerCase() : 'creative projects'}.';
    }
    if (user.title.isNotEmpty) {
      return '${user.title} focused on delivering polished, user-centered creative work.';
    }
    return 'Creative professional building portfolio-ready work across design and visual projects.';
  }
}
