import 'package:flutter/material.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_tab_bar.dart';
import 'package:kael/SCREENS/PROFILE/cv_sidebar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';


class PfpCV extends StatefulWidget {
  const PfpCV({super.key});

  @override
  State<PfpCV> createState() => _PfpCVState();
}

class _PfpCVState extends State<PfpCV> {
  List<String> openTabs = ["PROFILE"];
  String activeSection = "PROFILE";
  bool isEditing = false;

  late TextEditingController _nameController, _titleController, _countryController, 
                             _phoneController, _emailController, _bioController;

  final List<String> sidebarSections = ["PROFILE", "EXPERIENCE", "PROJECTS", "SKILLS", "EDUCATION", "CERTIFICATIONS"];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserDataModel>(context, listen: false);
    _nameController = TextEditingController(text: user.name);
    _titleController = TextEditingController(text: user.title);
    _countryController = TextEditingController(text: user.country);
    _phoneController = TextEditingController(text: user.phone);
    _emailController = TextEditingController(text: user.email);
    _bioController = TextEditingController(text: user.bio);
  }

  String _toTitleCase(String text) => text.isEmpty ? text : text.split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');

  @override
  void dispose() {
    for (var c in [_nameController, _titleController, _countryController, _phoneController, _emailController, _bioController]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserDataModel>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Row(
          children: [
            CVSidebar(
              user: user, 
              activeSection: activeSection, 
              sections: sidebarSections, 
              onSectionClick: (s) => setState(() {
                activeSection = s;
                if (!openTabs.contains(s)) openTabs.add(s);
              }),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  KaelTabBar(
  leadingLabel: "CV",
  tabs: openTabs,
  activeTab: activeSection,
  onTabTap: (tab) => setState(() => activeSection = tab),
  onTabClose: (tab) {
    setState(() {
      int indexToRemove = openTabs.indexOf(tab);
      if (indexToRemove != -1) {
        openTabs.removeAt(indexToRemove);
        
        // If we closed the current active section
        if (activeSection == tab) {
          if (openTabs.isNotEmpty) {
            // Move to the previous tab, or the first one if we closed the 0th index
            activeSection = (indexToRemove > 0) 
                ? openTabs[indexToRemove - 1] 
                : openTabs[0];
          } else {
            activeSection = ""; // Shows the empty canvas state
          }
        }
      }
    });
  },
  onExit: () => Navigator.pop(context),
),
                  const SizedBox(height: 20),
                  Expanded(child: _buildCVCanvas(user)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCVCanvas(UserDataModel user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(100),
      child: SingleChildScrollView(
        child: activeSection == "PROFILE" ? _buildProfileContent(user) : Center(child: Text("$activeSection SECTION", style: const TextStyle(color: Colors.white24))),
      ),
    );
  }

  Widget _buildProfileContent(UserDataModel user) {
    final textColor = const Color.fromARGB(255, 171, 163, 153);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isEditing ? _editField(_nameController, 25, 350, true) : Text(user.name.toUpperCase(), style: TextStyle(color: textColor, fontSize: 25, fontVariations: const [FontVariation('wght', 350.0)])),
        isEditing ? _editField(_titleController, 20, 350, false) : Text(_toTitleCase(user.title), style: TextStyle(color: textColor, fontSize: 20, fontVariations: const [FontVariation('wght', 350.0)])),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black, 
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: isEditing ? textColor.withValues(alpha: 0.4) : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoTile(Symbols.location_on, user.country, _countryController),
              _infoTile(Symbols.phone, user.phone, _phoneController),
              _infoTile(Symbols.mail, user.email, _emailController),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: isEditing ? textColor.withValues(alpha: 0.4) : Colors.transparent),
          ),
          child: isEditing 
            ? TextField(controller: _bioController, maxLines: null, style: TextStyle(color: textColor, fontSize: 15, height: 1.6, fontVariations: const [FontVariation('wght', 300.0)]), decoration: const InputDecoration(border: InputBorder.none, isDense: true))
            : Text(user.bio, style: TextStyle(color: textColor, height: 1.6, fontSize: 15, fontVariations: const [FontVariation('wght', 300.0)])),
        ),
        const SizedBox(height: 40),
        Center(
          child: TextButton(
            onPressed: () {
              if (isEditing) user.updateProfile(n: _nameController.text, t: _titleController.text, c: _countryController.text, p: _phoneController.text, e: _emailController.text, b: _bioController.text);
              setState(() => isEditing = !isEditing);
            },
            style: TextButton.styleFrom(side: BorderSide(color: textColor.withValues(alpha: 0.4)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
            child: Text(isEditing ? "DONE" : "EDIT PROFILE", style: TextStyle(color: textColor, fontSize: 12, letterSpacing: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _editField(TextEditingController c, double s, double w, bool up) => TextField(controller: c, textCapitalization: up ? TextCapitalization.characters : TextCapitalization.words, style: TextStyle(color: const Color.fromARGB(255, 171, 163, 153), fontSize: s, fontVariations: [FontVariation('wght', w)]), decoration: const InputDecoration(isDense: true, border: InputBorder.none));

  Widget _infoTile(IconData i, String v, TextEditingController c) => Row(children: [
    Icon(i, color: const Color.fromARGB(144, 171, 163, 153), size: 15),
    const SizedBox(width: 8),
    isEditing ? SizedBox(width: 100, child: TextField(controller: c, style: const TextStyle(color: Color.fromARGB(255, 171, 163, 153), fontSize: 15), decoration: const InputDecoration(isDense: true, border: InputBorder.none))) : Text(v.isEmpty ? "Not Provided" : v, style: const TextStyle(color: Color.fromARGB(255, 171, 163, 153), fontSize: 15)),
  ]);
}