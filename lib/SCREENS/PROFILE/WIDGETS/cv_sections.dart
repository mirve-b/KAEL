import 'package:flutter/material.dart';
import 'package:kael/API/bio_generator_service.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/PROFILE/DATA%20MODEL/cv_models.dart';
import 'package:kael/SCREENS/PROFILE/WIDGETS/cv_ui_helpers.dart';
import 'package:material_symbols_icons/symbols.dart';

class CvProfileSection extends StatefulWidget {
  final UserDataModel user;

  const CvProfileSection({super.key, required this.user});

  @override
  State<CvProfileSection> createState() => _CvProfileSectionState();
}

class _CvProfileSectionState extends State<CvProfileSection> {
  late TextEditingController _name;
  late TextEditingController _title;
  late TextEditingController _country;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _bio;
  late TextEditingController _linkedin;
  late TextEditingController _website;
  bool _isRegeneratingBio = false;
  final BioGeneratorService _bioGenerator = BioGeneratorService();

  @override
  void initState() {
    super.initState();
    _syncFromUser();
  }

  void _syncFromUser() {
    final u = widget.user;
    _name = TextEditingController(text: u.name);
    _title = TextEditingController(text: u.title);
    _country = TextEditingController(text: u.country);
    _phone = TextEditingController(text: u.phone);
    _email = TextEditingController(text: u.email);
    _bio = TextEditingController(text: u.bio);
    _linkedin = TextEditingController(text: u.linkedinUrl);
    _website = TextEditingController(text: u.websiteUrl);
  }

  @override
  void dispose() {
    for (final c in [_name, _title, _country, _phone, _email, _bio, _linkedin, _website]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    widget.user.updateProfile(
      n: _name.text.trim(),
      t: _title.text.trim(),
      c: _country.text.trim(),
      p: _phone.text.trim(),
      e: _email.text.trim(),
      b: _bio.text.trim(),
      linkedin: _linkedin.text.trim(),
      website: _website.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved'), duration: Duration(seconds: 2)),
    );
  }

  void _syncFormToUser() {
    widget.user.updateProfile(
      n: _name.text.trim(),
      t: _title.text.trim(),
      c: _country.text.trim(),
      p: _phone.text.trim(),
      e: _email.text.trim(),
      b: _bio.text.trim(),
      linkedin: _linkedin.text.trim(),
      website: _website.text.trim(),
    );
  }

  Future<void> _regenerateBio() async {
    if (_isRegeneratingBio) return;

    setState(() => _isRegeneratingBio = true);
    _syncFormToUser();

    try {
      final summary = await _bioGenerator.generate(widget.user);
      if (!mounted) return;

      setState(() {
        _bio.text = summary;
        _isRegeneratingBio = false;
      });
      widget.user.updatePortfolioIdentity(bio: summary);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Professional summary regenerated'), duration: Duration(seconds: 2)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isRegeneratingBio = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not regenerate summary. Try again.'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CvSectionHeader(
          title: 'PROFILE',
          subtitle: 'Your contact details and professional summary appear at the top of your CV.',
        ),
        const SizedBox(height: 20),
        _field('Full Name', _name),
        _field('Professional Title', _title),
        Row(
          children: [
            Expanded(child: _field('Country / Location', _country)),
            const SizedBox(width: 20),
            Expanded(child: _field('Phone', _phone)),
          ],
        ),
        _field('Email', _email),
        _field('LinkedIn URL', _linkedin),
        _field('Website / Portfolio URL', _website),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Professional Summary',
                style: CvThemeScope.of(context).body(size: 12).copyWith(color: CvThemeScope.of(context).textColor.withValues(alpha: 0.7)),
              ),
            ),
            TextButton.icon(
              onPressed: _isRegeneratingBio ? null : _regenerateBio,
              icon: _isRegeneratingBio
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CvThemeScope.of(context).textColor.withValues(alpha: 0.7),
                      ),
                    )
                  : Icon(Symbols.auto_awesome, size: 14, color: CvThemeScope.of(context).textColor),
              label: Text(
                _isRegeneratingBio ? 'GENERATING...' : 'REGENERATE BIO',
                style: CvThemeScope.of(context).body(size: 10).copyWith(letterSpacing: 1.1),
              ),
              style: TextButton.styleFrom(
                side: BorderSide(color: CvThemeScope.of(context).textColor.withValues(alpha: 0.35)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bio,
          maxLines: 6,
          style: CvThemeScope.of(context).body(size: 14).copyWith(height: 1.6),
          decoration: CvThemeScope.of(context).fieldDecoration('Write a brief ATS-friendly summary'),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            onPressed: _save,
            icon: Icon(Symbols.save, size: 16, color: CvThemeScope.of(context).textColor),
            label: Text('SAVE PROFILE', style: CvThemeScope.of(context).body(size: 11).copyWith(letterSpacing: 1.2)),
            style: TextButton.styleFrom(
              side: BorderSide(color: CvThemeScope.of(context).textColor.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        style: CvThemeScope.of(context).body(size: 14),
        decoration: CvThemeScope.of(context).fieldDecoration(label),
      ),
    );
  }
}

class CvExperienceSection extends StatelessWidget {
  final UserDataModel user;

  const CvExperienceSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CvSectionHeader(
          title: 'EXPERIENCE',
          subtitle: 'Add work history with dates and bullet-style descriptions.',
          onAdd: user.addExperience,
        ),
        if (user.experiences.isEmpty)
          CvEmptyState(message: 'No experience added yet.', onAdd: user.addExperience)
        else
          ...user.experiences.asMap().entries.map(
            (entry) => _ExperienceCard(
              index: entry.key,
              entry: entry.value,
              user: user,
            ),
          ),
      ],
    );
  }
}

class _ExperienceCard extends StatefulWidget {
  final int index;
  final ExperienceEntry entry;
  final UserDataModel user;

  const _ExperienceCard({required this.index, required this.entry, required this.user});

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  late TextEditingController _title;
  late TextEditingController _company;
  late TextEditingController _location;
  late TextEditingController _start;
  late TextEditingController _end;
  late TextEditingController _description;
  late bool _isCurrent;

  @override
  void initState() {
    super.initState();
    _bind(widget.entry);
  }

  void _bind(ExperienceEntry e) {
    _title = TextEditingController(text: e.jobTitle);
    _company = TextEditingController(text: e.company);
    _location = TextEditingController(text: e.location);
    _start = TextEditingController(text: e.startDate);
    _end = TextEditingController(text: e.endDate);
    _description = TextEditingController(text: e.description);
    _isCurrent = e.isCurrent;
  }

  @override
  void dispose() {
    for (final c in [_title, _company, _location, _start, _end, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    widget.user.updateExperience(
      widget.index,
      widget.entry.copyWith(
        jobTitle: _title.text.trim(),
        company: _company.text.trim(),
        location: _location.text.trim(),
        startDate: _start.text.trim(),
        endDate: _end.text.trim(),
        isCurrent: _isCurrent,
        description: _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CvEntryCard(
      label: 'EXPERIENCE ${widget.index + 1}',
      onRemove: () => widget.user.removeExperience(widget.index),
      child: Column(
        children: [
          _rowField('Job Title', _title),
          _rowField('Company', _company),
          _rowField('Location', _location),
          Row(
            children: [
              Expanded(child: _rowField('Start (e.g. Jan 2022)', _start)),
              const SizedBox(width: 16),
              Expanded(child: _rowField('End (e.g. Dec 2024)', _end, enabled: !_isCurrent)),
            ],
          ),
          CheckboxListTile(
            value: _isCurrent,
            onChanged: (v) => setState(() => _isCurrent = v ?? false),
            title: Text('I currently work here', style: CvThemeScope.of(context).body(size: 12)),
            activeColor: CvThemeScope.of(context).textColor,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          TextField(
            controller: _description,
            maxLines: 5,
            style: CvThemeScope.of(context).body(size: 13).copyWith(height: 1.5),
            decoration: CvThemeScope.of(context).fieldDecoration('Description / achievements'),
            onChanged: (_) => _save(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: _save, child: Text('SAVE', style: CvThemeScope.of(context).body(size: 11))),
          ),
        ],
      ),
    );
  }

  Widget _rowField(String label, TextEditingController c, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        enabled: enabled,
        style: CvThemeScope.of(context).body(size: 13),
        decoration: CvThemeScope.of(context).fieldDecoration(label),
        onChanged: (_) => _save(),
      ),
    );
  }
}

class CvProjectsSection extends StatelessWidget {
  final UserDataModel user;

  const CvProjectsSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CvSectionHeader(
          title: 'PROJECTS',
          subtitle: 'Saved catalog projects sync here automatically with AI-filled role, tools, and summary.',
          onAdd: user.addCvProject,
        ),
        if (user.cvProjects.isEmpty)
          CvEmptyState(message: 'No projects added yet.', onAdd: user.addCvProject)
        else
          ...user.cvProjects.asMap().entries.map(
            (entry) => _ProjectCard(index: entry.key, entry: entry.value, user: user),
          ),
      ],
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final int index;
  final CvProjectEntry entry;
  final UserDataModel user;

  const _ProjectCard({required this.index, required this.entry, required this.user});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  late TextEditingController _name;
  late TextEditingController _role;
  late TextEditingController _tech;
  late TextEditingController _desc;
  late TextEditingController _url;

  @override
  void didUpdateWidget(covariant _ProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _syncControllers(widget.entry);
      return;
    }
    if (oldWidget.entry.name != widget.entry.name && widget.entry.name != _name.text) {
      _name.text = widget.entry.name;
    }
    if (oldWidget.entry.role != widget.entry.role && widget.entry.role != _role.text) {
      _role.text = widget.entry.role;
    }
    if (oldWidget.entry.technologies != widget.entry.technologies &&
        widget.entry.technologies != _tech.text) {
      _tech.text = widget.entry.technologies;
    }
    if (oldWidget.entry.description != widget.entry.description &&
        widget.entry.description != _desc.text) {
      _desc.text = widget.entry.description;
    }
    if (oldWidget.entry.url != widget.entry.url && widget.entry.url != _url.text) {
      _url.text = widget.entry.url;
    }
  }

  void _syncControllers(CvProjectEntry entry) {
    if (_name.text != entry.name) _name.text = entry.name;
    if (_role.text != entry.role) _role.text = entry.role;
    if (_tech.text != entry.technologies) _tech.text = entry.technologies;
    if (_desc.text != entry.description) _desc.text = entry.description;
    if (_url.text != entry.url) _url.text = entry.url;
  }

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _name = TextEditingController();
    _role = TextEditingController();
    _tech = TextEditingController();
    _desc = TextEditingController();
    _url = TextEditingController();
    _syncControllers(e);
  }

  @override
  void dispose() {
    for (final c in [_name, _role, _tech, _desc, _url]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    widget.user.updateCvProject(
      widget.index,
      widget.entry.copyWith(
        name: _name.text,
        role: _role.text,
        technologies: _tech.text,
        description: _desc.text,
        url: _url.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CvEntryCard(
      label: 'PROJECT ${widget.index + 1}',
      onRemove: () => widget.user.removeCvProject(widget.index),
      child: Column(
        children: [
          _f('Project Name', _name),
          _f('Your Role', _role),
          _f('Technologies (comma separated)', _tech),
          _f('Description', _desc, maxLines: 4),
          _f('Project URL', _url),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: CvThemeScope.of(context).body(size: 13),
        decoration: CvThemeScope.of(context).fieldDecoration(label),
        onChanged: (_) => _save(),
      ),
    );
  }
}

class CvSkillsSection extends StatelessWidget {
  final UserDataModel user;

  const CvSkillsSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CvSectionHeader(
          title: 'SKILLS',
          subtitle: 'Skills from onboarding are loaded here. Add or remove as needed.',
        ),
        const SizedBox(height: 20),
        CvChipField(
          label: 'Technical & Professional Skills',
          items: user.skills,
          onChanged: user.setSkillsList,
        ),
        const SizedBox(height: 32),
        CvChipField(
          label: 'Languages',
          items: user.languages,
          onChanged: user.setLanguagesList,
        ),
        if (user.hobbies.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Hobbies / Interests', style: CvThemeScope.of(context).body(size: 12).copyWith(color: CvThemeScope.of(context).textColor.withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          Text(user.hobbies, style: CvThemeScope.of(context).body(size: 13).copyWith(height: 1.5)),
        ],
      ],
    );
  }
}

class CvEducationSection extends StatefulWidget {
  final UserDataModel user;

  const CvEducationSection({super.key, required this.user});

  @override
  State<CvEducationSection> createState() => _CvEducationSectionState();
}

class _CvEducationSectionState extends State<CvEducationSection> {
  @override
  void initState() {
    super.initState();
    widget.user.ensureEducationSeeded();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CvSectionHeader(
          title: 'EDUCATION',
          subtitle: 'Onboarding education data is imported automatically.',
          onAdd: user.addEducation,
        ),
        if (user.educationEntries.isEmpty)
          CvEmptyState(message: 'No education added yet.', onAdd: user.addEducation)
        else
          ...user.educationEntries.asMap().entries.map(
            (entry) => _EducationCard(index: entry.key, entry: entry.value, user: user),
          ),
      ],
    );
  }
}

class _EducationCard extends StatefulWidget {
  final int index;
  final EducationEntry entry;
  final UserDataModel user;

  const _EducationCard({required this.index, required this.entry, required this.user});

  @override
  State<_EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<_EducationCard> {
  late TextEditingController _level;
  late TextEditingController _field;
  late TextEditingController _institution;
  late TextEditingController _year;
  late TextEditingController _gpa;
  late TextEditingController _honors;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _level = TextEditingController(text: e.level);
    _field = TextEditingController(text: e.fieldOfStudy);
    _institution = TextEditingController(text: e.institution);
    _year = TextEditingController(text: e.gradYear);
    _gpa = TextEditingController(text: e.gpa);
    _honors = TextEditingController(text: e.honors);
  }

  @override
  void dispose() {
    for (final c in [_level, _field, _institution, _year, _gpa, _honors]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    widget.user.updateEducation(
      widget.index,
      widget.entry.copyWith(
        level: _level.text.trim(),
        fieldOfStudy: _field.text.trim(),
        institution: _institution.text.trim(),
        gradYear: _year.text.trim(),
        gpa: _gpa.text.trim(),
        honors: _honors.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CvEntryCard(
      label: 'EDUCATION ${widget.index + 1}',
      onRemove: () => widget.user.removeEducation(widget.index),
      child: Column(
        children: [
          _f('Level (e.g. Undergraduate)', _level),
          _f('Field of Study', _field),
          _f('Institution', _institution),
          Row(
            children: [
              Expanded(child: _f('Graduation Year', _year)),
              const SizedBox(width: 16),
              Expanded(child: _f('GPA (optional)', _gpa)),
            ],
          ),
          _f('Honors / Awards (optional)', _honors),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        style: CvThemeScope.of(context).body(size: 13),
        decoration: CvThemeScope.of(context).fieldDecoration(label),
        onChanged: (_) => _save(),
      ),
    );
  }
}

class CvCertificationsSection extends StatelessWidget {
  final UserDataModel user;

  const CvCertificationsSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CvSectionHeader(
          title: 'CERTIFICATIONS',
          subtitle: 'Add professional certifications and credentials.',
          onAdd: user.addCertification,
        ),
        if (user.certifications.isEmpty)
          CvEmptyState(message: 'No certifications added yet.', onAdd: user.addCertification)
        else
          ...user.certifications.asMap().entries.map(
            (entry) => _CertCard(index: entry.key, entry: entry.value, user: user),
          ),
      ],
    );
  }
}

class _CertCard extends StatefulWidget {
  final int index;
  final CertificationEntry entry;
  final UserDataModel user;

  const _CertCard({required this.index, required this.entry, required this.user});

  @override
  State<_CertCard> createState() => _CertCardState();
}

class _CertCardState extends State<_CertCard> {
  late TextEditingController _name;
  late TextEditingController _issuer;
  late TextEditingController _date;
  late TextEditingController _id;
  late TextEditingController _url;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _name = TextEditingController(text: e.name);
    _issuer = TextEditingController(text: e.issuer);
    _date = TextEditingController(text: e.date);
    _id = TextEditingController(text: e.credentialId);
    _url = TextEditingController(text: e.url);
  }

  @override
  void dispose() {
    for (final c in [_name, _issuer, _date, _id, _url]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    widget.user.updateCertification(
      widget.index,
      widget.entry.copyWith(
        name: _name.text.trim(),
        issuer: _issuer.text.trim(),
        date: _date.text.trim(),
        credentialId: _id.text.trim(),
        url: _url.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CvEntryCard(
      label: 'CERTIFICATION ${widget.index + 1}',
      onRemove: () => widget.user.removeCertification(widget.index),
      child: Column(
        children: [
          _f('Certification Name', _name),
          _f('Issuing Organization', _issuer),
          _f('Date Obtained', _date),
          _f('Credential ID (optional)', _id),
          _f('Verification URL (optional)', _url),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        style: CvThemeScope.of(context).body(size: 13),
        decoration: CvThemeScope.of(context).fieldDecoration(label),
        onChanged: (_) => _save(),
      ),
    );
  }
}
