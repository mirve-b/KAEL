class ExperienceEntry {
  final String id;
  String jobTitle;
  String company;
  String location;
  String startDate;
  String endDate;
  bool isCurrent;
  String description;

  ExperienceEntry({
    required this.id,
    this.jobTitle = '',
    this.company = '',
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.isCurrent = false,
    this.description = '',
  });

  ExperienceEntry copyWith({
    String? jobTitle,
    String? company,
    String? location,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    String? description,
  }) {
    return ExperienceEntry(
      id: id,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
    );
  }

  String get dateRange {
    final end = isCurrent ? 'Present' : endDate;
    if (startDate.isEmpty && end.isEmpty) return '';
    if (startDate.isEmpty) return end;
    if (end.isEmpty) return startDate;
    return '$startDate – $end';
  }
}

class CvProjectEntry {
  final String id;
  String name;
  String role;
  String technologies;
  String description;
  String url;

  CvProjectEntry({
    required this.id,
    this.name = '',
    this.role = '',
    this.technologies = '',
    this.description = '',
    this.url = '',
  });

  CvProjectEntry copyWith({
    String? name,
    String? role,
    String? technologies,
    String? description,
    String? url,
  }) {
    return CvProjectEntry(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      technologies: technologies ?? this.technologies,
      description: description ?? this.description,
      url: url ?? this.url,
    );
  }
}

class EducationEntry {
  final String id;
  String level;
  String fieldOfStudy;
  String institution;
  String gradYear;
  String gpa;
  String honors;

  EducationEntry({
    required this.id,
    this.level = '',
    this.fieldOfStudy = '',
    this.institution = '',
    this.gradYear = '',
    this.gpa = '',
    this.honors = '',
  });

  EducationEntry copyWith({
    String? level,
    String? fieldOfStudy,
    String? institution,
    String? gradYear,
    String? gpa,
    String? honors,
  }) {
    return EducationEntry(
      id: id,
      level: level ?? this.level,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      institution: institution ?? this.institution,
      gradYear: gradYear ?? this.gradYear,
      gpa: gpa ?? this.gpa,
      honors: honors ?? this.honors,
    );
  }
}

class CertificationEntry {
  final String id;
  String name;
  String issuer;
  String date;
  String credentialId;
  String url;

  CertificationEntry({
    required this.id,
    this.name = '',
    this.issuer = '',
    this.date = '',
    this.credentialId = '',
    this.url = '',
  });

  CertificationEntry copyWith({
    String? name,
    String? issuer,
    String? date,
    String? credentialId,
    String? url,
  }) {
    return CertificationEntry(
      id: id,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      date: date ?? this.date,
      credentialId: credentialId ?? this.credentialId,
      url: url ?? this.url,
    );
  }
}

String newCvEntryId() => DateTime.now().microsecondsSinceEpoch.toString();
