import 'package:kael/API/case_study/creative_field.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';

class FieldDetector {
  static const _rules = <CreativeField, List<String>>{
    CreativeField.interiorDesign: [
      'interior', 'spatial', 'furniture', 'decor', 'ff&e', 'room', 'residential', 'commercial space',
      'lighting design', 'home staging', 'kitchen', 'bedroom',
    ],
    CreativeField.uiUxDesign: [
      'ui', 'ux', 'user experience', 'user interface', 'figma', 'wireframe', 'prototype', 'usability',
      'onboarding', 'dashboard', 'mobile app', 'web app', 'product design',
    ],
    CreativeField.graphicDesign: [
      'graphic', 'brand identity', 'logo', 'typography', 'poster', 'brochure', 'visual identity',
      'campaign', 'packaging design', 'layout design',
    ],
    CreativeField.photography: [
      'photography', 'photographer', 'photo shoot', 'portrait', 'editorial photo', 'lightroom',
      'exposure', 'lens', 'color grade',
    ],
    CreativeField.fashionDesign: [
      'fashion', 'garment', 'collection', 'runway', 'textile', 'lookbook', 'couture', 'apparel',
    ],
    CreativeField.architecture: [
      'architecture', 'architectural', 'building', 'facade', 'urban', 'structural', 'massing', 'zoning',
    ],
    CreativeField.illustration: [
      'illustration', 'illustrator', 'editorial illustration', 'character design', 'storybook',
    ],
    CreativeField.motionDesign: [
      'motion design', 'motion graphics', 'animation', 'after effects', 'keyframes', 'animatic',
    ],
    CreativeField.filmVideo: [
      'film', 'video', 'cinematography', 'director', 'documentary', 'short film', 'editing', 'color grade',
    ],
    CreativeField.productDesign: [
      'industrial design', 'product design', 'ergonomic', 'prototype', 'manufacturing', 'cmf',
    ],
    CreativeField.fineArt: [
      'fine art', 'gallery', 'exhibition', 'studio practice', 'painting', 'sculpture', 'installation art',
    ],
  };

  static CreativeField detect(UserDataModel user, List<ProjectCell> cells, {String? projectTitle}) {
    final corpus = _buildCorpus(user, cells, projectTitle);
    var best = CreativeField.generalCreative;
    var bestScore = 0;

    for (final entry in _rules.entries) {
      var score = 0;
      for (final keyword in entry.value) {
        if (corpus.contains(keyword)) score += keyword.contains(' ') ? 3 : 1;
      }
      if (score > bestScore) {
        bestScore = score;
        best = entry.key;
      }
    }

    return bestScore == 0 ? CreativeField.generalCreative : best;
  }

  static String _buildCorpus(UserDataModel user, List<ProjectCell> cells, String? projectTitle) {
    final parts = <String>[
      user.title,
      user.bio,
      user.fieldOfStudy,
      user.educationLevel ?? '',
      projectTitle ?? '',
      ...user.skills,
      ...user.interests,
      ...user.experiences.map((e) => '${e.jobTitle} ${e.description}'),
      ...user.cvProjects.map((p) => '${p.name} ${p.role} ${p.description}'),
      ...cells.where((c) => c.type == 'text').map((c) => '${c.title} ${c.content}'),
    ];
    return parts.join(' ').toLowerCase();
  }
}
