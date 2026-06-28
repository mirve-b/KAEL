import 'package:flutter/material.dart';
import 'package:kael/SCREENS/PROFILE/DATA%20MODEL/cv_models.dart';
import 'dart:math';

class UserDataModel extends ChangeNotifier {
  // --- IDENTITY ---
  String fullName = "";
  String email = "";
  String name = "";
  String uid = "";
  String title = "";
  String country = "";
  String phone = "";
  String bio = "UI/UX Designer with experience creating intuitive, user-centered digital products. Passionate about translating complex problems into simple, meaningful experiences.";
  String linkedinUrl = "";
  String websiteUrl = "";

  // --- VISUALS ---
  String? uploadedImagePath;
  String? finalPfpPath;
  String? bannerPath;
  String? aboutImagePath;

  // --- BACKGROUND (onboarding legacy + CV education list) ---
  String? educationLevel;
  String fieldOfStudy = "";
  String institution = "";
  String gradYear = "";
  List<String> languages = [];

  // --- SKILLS & INTERESTS ---
  List<String> skills = [];
  Set<String> interests = {};
  String hobbies = "";

  // --- CV SECTIONS ---
  List<ExperienceEntry> experiences = [];
  List<CvProjectEntry> cvProjects = [];
  List<EducationEntry> educationEntries = [];
  List<CertificationEntry> certifications = [];

  UserDataModel({
    this.bannerPath,
    this.aboutImagePath,
  });

  void updateBanner(String? path) {
    bannerPath = path;
    notifyListeners();
  }

  void updateAboutImage(String? path) {
    aboutImagePath = path;
    notifyListeners();
  }

  Color portfolioBgColor = const Color.fromARGB(255, 23, 23, 23);
  Color textColor = Colors.white;
  String fontFamily = 'Inter';

  void updatePortfolioTheme({Color? bg, Color? text, String? font}) {
    if (bg != null) portfolioBgColor = bg;
    if (text != null) textColor = text;
    if (font != null) fontFamily = font;
    notifyListeners();
  }

  void updatePortfolioIdentity({String? name, String? title, String? bio}) {
    if (name != null) this.name = name;
    if (title != null) this.title = title;
    if (bio != null) this.bio = bio;
    notifyListeners();
  }

  void signupUser({required String full, required String mail}) {
    fullName = full;
    email = mail;
    name = full;

    if (uid.isEmpty && full.isNotEmpty) {
      int randomSuffix = Random().nextInt(900) + 100;
      uid = "@${full.toLowerCase().replaceAll(' ', '')}.$randomSuffix";
    }
    notifyListeners();
  }

  void updateForm1({required String n, required String t, required String c, required String p}) {
    name = n;
    title = t;
    country = c;
    phone = p;
    notifyListeners();
  }

  void updateUploadedPath(String path) {
    uploadedImagePath = path;
    notifyListeners();
  }

  void setFinalPfp(String? path) {
    finalPfpPath = path;
    notifyListeners();
  }

  void updateForm3({
    String? edu,
    required String field,
    required String inst,
    required String year,
    required List<String> langs,
  }) {
    educationLevel = edu;
    fieldOfStudy = field;
    institution = inst;
    gradYear = year;
    languages = langs;
    _syncLegacyEducationToList();
    notifyListeners();
  }

  void updateForm4({
    required List<String> skillList,
    required Set<String> interestSet,
    required String hobbyText,
  }) {
    skills = skillList;
    interests = interestSet;
    hobbies = hobbyText;
    notifyListeners();
  }

  void updateProfile({
    required String n,
    required String t,
    required String c,
    required String p,
    required String e,
    required String b,
    String? linkedin,
    String? website,
  }) {
    name = n;
    title = t;
    country = c;
    phone = p;
    email = e;
    bio = b;
    if (linkedin != null) linkedinUrl = linkedin;
    if (website != null) websiteUrl = website;
    notifyListeners();
  }

  void deletePfp() {
    finalPfpPath = null;
    uploadedImagePath = null;
    notifyListeners();
  }

  /// Seeds CV education from onboarding fields when the list is empty.
  void ensureEducationSeeded() {
    if (educationEntries.isEmpty &&
        (institution.isNotEmpty || fieldOfStudy.isNotEmpty || gradYear.isNotEmpty)) {
      _syncLegacyEducationToList();
    }
  }

  void _syncLegacyEducationToList() {
    if (institution.isEmpty && fieldOfStudy.isEmpty && gradYear.isEmpty) return;
    educationEntries = [
      EducationEntry(
        id: 'legacy-education',
        level: educationLevel ?? '',
        fieldOfStudy: fieldOfStudy,
        institution: institution,
        gradYear: gradYear,
      ),
    ];
  }

  // --- EXPERIENCE ---
  void addExperience() {
    experiences.add(ExperienceEntry(id: newCvEntryId()));
    notifyListeners();
  }

  void updateExperience(int index, ExperienceEntry entry) {
    if (index < 0 || index >= experiences.length) return;
    experiences[index] = entry;
    notifyListeners();
  }

  void removeExperience(int index) {
    if (index < 0 || index >= experiences.length) return;
    experiences.removeAt(index);
    notifyListeners();
  }

  // --- CV PROJECTS ---
  void addCvProject() {
    cvProjects.add(CvProjectEntry(id: newCvEntryId()));
    notifyListeners();
  }

  void updateCvProject(int index, CvProjectEntry entry) {
    if (index < 0 || index >= cvProjects.length) return;
    cvProjects[index] = entry;
    notifyListeners();
  }

  void removeCvProject(int index) {
    if (index < 0 || index >= cvProjects.length) return;
    cvProjects.removeAt(index);
    notifyListeners();
  }

  // --- SKILLS ---
  void addSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty || skills.contains(trimmed)) return;
    skills.add(trimmed);
    notifyListeners();
  }

  void updateSkill(int index, String skill) {
    if (index < 0 || index >= skills.length) return;
    skills[index] = skill.trim();
    notifyListeners();
  }

  void removeSkill(int index) {
    if (index < 0 || index >= skills.length) return;
    skills.removeAt(index);
    notifyListeners();
  }

  // --- EDUCATION ---
  void addEducation() {
    educationEntries.add(EducationEntry(id: newCvEntryId()));
    notifyListeners();
  }

  void updateEducation(int index, EducationEntry entry) {
    if (index < 0 || index >= educationEntries.length) return;
    educationEntries[index] = entry;
    notifyListeners();
  }

  void removeEducation(int index) {
    if (index < 0 || index >= educationEntries.length) return;
    educationEntries.removeAt(index);
    notifyListeners();
  }

  // --- CERTIFICATIONS ---
  void addCertification() {
    certifications.add(CertificationEntry(id: newCvEntryId()));
    notifyListeners();
  }

  void updateCertification(int index, CertificationEntry entry) {
    if (index < 0 || index >= certifications.length) return;
    certifications[index] = entry;
    notifyListeners();
  }

  void removeCertification(int index) {
    if (index < 0 || index >= certifications.length) return;
    certifications.removeAt(index);
    notifyListeners();
  }

  // --- LANGUAGES ---
  void addLanguage(String language) {
    final trimmed = language.trim();
    if (trimmed.isEmpty || languages.contains(trimmed)) return;
    languages.add(trimmed);
    notifyListeners();
  }

  void updateLanguage(int index, String language) {
    if (index < 0 || index >= languages.length) return;
    languages[index] = language.trim();
    notifyListeners();
  }

  void removeLanguage(int index) {
    if (index < 0 || index >= languages.length) return;
    languages.removeAt(index);
    notifyListeners();
  }

  void setSkillsList(List<String> items) {
    skills = items;
    notifyListeners();
  }

  void setLanguagesList(List<String> items) {
    languages = items;
    notifyListeners();
  }

  /// Profile snapshot sent to the case study engine for field-aware generation.
  String buildCreativeContextSummary() {
    final buffer = StringBuffer();
    if (name.isNotEmpty) buffer.writeln('Name: $name');
    if (title.isNotEmpty) buffer.writeln('Professional title: $title');
    if (bio.isNotEmpty) buffer.writeln('Bio: $bio');
    if (fieldOfStudy.isNotEmpty) buffer.writeln('Field of study: $fieldOfStudy');
    if (educationLevel != null && educationLevel!.isNotEmpty) {
      buffer.writeln('Education level: $educationLevel');
    }
    if (institution.isNotEmpty) buffer.writeln('Institution: $institution');
    if (skills.isNotEmpty) buffer.writeln('Skills: ${skills.join(', ')}');
    if (interests.isNotEmpty) buffer.writeln('Interests: ${interests.join(', ')}');
    if (hobbies.isNotEmpty) buffer.writeln('Hobbies: $hobbies');
    if (experiences.isNotEmpty) {
      buffer.writeln('Experience:');
      for (final e in experiences) {
        if (e.jobTitle.isEmpty && e.description.isEmpty) continue;
        buffer.writeln('- ${e.jobTitle}${e.company.isNotEmpty ? ' at ${e.company}' : ''}: ${e.description}');
      }
    }
    if (cvProjects.isNotEmpty) {
      buffer.writeln('Past projects:');
      for (final p in cvProjects) {
        if (p.name.isEmpty && p.description.isEmpty) continue;
        buffer.writeln('- ${p.name}${p.role.isNotEmpty ? ' (${p.role})' : ''}: ${p.description}');
      }
    }
    return buffer.toString().trim().isEmpty
        ? 'No profile details added yet — infer discipline from project content only.'
        : buffer.toString().trim();
  }
}
