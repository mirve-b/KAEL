import 'package:flutter/material.dart';
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

  // --- VISUALS ---
  String? uploadedImagePath;   
  String? finalPfpPath;        

  // --- BACKGROUND ---
  String? educationLevel;
  String fieldOfStudy = "";
  String institution = "";
  String gradYear = "";
  List<String> languages = [];

  // --- SKILLS & INTERESTS ---
  List<String> skills = [];
  Set<String> interests = {};
  String hobbies = "";

  // --- METHODS TO UPDATE DATA ---

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
    required List<String> langs
  }) {
    educationLevel = edu;
    fieldOfStudy = field;
    institution = inst;
    gradYear = year;
    languages = langs;
    notifyListeners();
  }

  void updateForm4({
    required List<String> skillList, 
    required Set<String> interestSet, 
    required String hobbyText
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
  required String b
}) {
  name = n;
  title = t;
  country = c;
  phone = p;
  email = e;
  bio = b;
  notifyListeners();
}

void deletePfp() {
  finalPfpPath = null;
  uploadedImagePath = null;
  notifyListeners();
}
}