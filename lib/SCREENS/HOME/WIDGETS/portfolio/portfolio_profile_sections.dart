import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/PROFILE/DATA%20MODEL/cv_models.dart';

class PortfolioProfileSections extends StatelessWidget {
  final UserDataModel userData;
  final KaelTheme theme;

  const PortfolioProfileSections({
    super.key,
    required this.userData,
    required this.theme,
  });

  TextStyle get _heading => TextStyle(
        color: userData.resolveHeadingColor(theme),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      );

  TextStyle get _body => TextStyle(
        color: theme.textSecondary,
        fontSize: 13,
        height: 1.6,
        fontWeight: FontWeight.w300,
        fontFamily: userData.fontFamily,
      );

  @override
  Widget build(BuildContext context) {
    userData.ensureEducationSeeded();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userData.skills.isNotEmpty) ...[
          _sectionTitle('SKILLS'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: userData.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.portfolioSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.portfolioSurfaceBorder),
                ),
                child: Text(skill, style: _body.copyWith(fontSize: 12)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (userData.experiences.any((e) => e.jobTitle.isNotEmpty || e.company.isNotEmpty)) ...[
          _sectionTitle('EXPERIENCE'),
          const SizedBox(height: 8),
          ...userData.experiences.where((e) => e.jobTitle.isNotEmpty || e.company.isNotEmpty).map(_experienceTile),
          const SizedBox(height: 24),
        ],
        if (userData.educationEntries.any((e) => e.institution.isNotEmpty || e.fieldOfStudy.isNotEmpty)) ...[
          _sectionTitle('EDUCATION'),
          const SizedBox(height: 8),
          ...userData.educationEntries
              .where((e) => e.institution.isNotEmpty || e.fieldOfStudy.isNotEmpty)
              .map(_educationTile),
          const SizedBox(height: 24),
        ],
        _buildConnectSection(),
      ],
    );
  }

  Widget _sectionTitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Text(label, style: _heading),
    );
  }

  Widget _experienceTile(ExperienceEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.jobTitle.isEmpty ? 'Role' : entry.jobTitle,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: userData.fontFamily,
            ),
          ),
          if (entry.company.isNotEmpty || entry.dateRange.isNotEmpty)
            Text(
              [
                if (entry.company.isNotEmpty) entry.company,
                if (entry.dateRange.isNotEmpty) entry.dateRange,
              ].join(' · '),
              style: _body.copyWith(fontSize: 12),
            ),
          if (entry.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(entry.description, style: _body),
            ),
        ],
      ),
    );
  }

  Widget _educationTile(EducationEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.institution.isEmpty ? 'Institution' : entry.institution,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: userData.fontFamily,
            ),
          ),
          Text(
            [
              if (entry.level.isNotEmpty) entry.level,
              if (entry.fieldOfStudy.isNotEmpty) entry.fieldOfStudy,
              if (entry.gradYear.isNotEmpty) entry.gradYear,
            ].join(' · '),
            style: _body.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectSection() {
    final items = <Map<String, String>>[
      if (userData.linkedinUrl.isNotEmpty) {'label': 'Linkedin', 'value': userData.linkedinUrl},
      if (userData.phone.isNotEmpty) {'label': 'Phone', 'value': userData.phone},
      if (userData.email.isNotEmpty) {'label': 'Email', 'value': userData.email},
      if (userData.websiteUrl.isNotEmpty) {'label': 'Website', 'value': userData.websiteUrl},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text("LET'S CONNECT", style: _heading),
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text('Add contact details in your profile.', style: _body.copyWith(fontSize: 12)),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 30, bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(item['label']!, style: _body.copyWith(fontSize: 12)),
                  ),
                  Expanded(
                    child: Text(
                      item['value']!,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 13,
                        fontFamily: userData.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
