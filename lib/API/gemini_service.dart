import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:kael/API/api_config.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService() : _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: ApiConfig.geminiKey,
  );

 Future<String> getCaseStudy(List<ProjectCell> cells) async {
  final projectDescription = cells
      .where((c) => c.type == "text")
      .map((c) => c.content)
      .join("\n");

  // This prompt forces Gemini to format the text so we can read it easily
  final prompt = """
    Analyze these project assets: $projectDescription.
    Write a professional case study. 
    Format it exactly like this:
    PROBLEM: [Write the problem here]
    OBJECTIVES: [Write objectives here]
    METHODOLOGY: [Write the process here]
    SOLUTION: [Write the detailed analysis here]
  """;

  final response = await _model.generateContent([Content.text(prompt)]);
  return response.text ?? "AI failed to generate.";
}
}