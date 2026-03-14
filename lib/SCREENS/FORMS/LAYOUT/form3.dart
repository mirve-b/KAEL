import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/LAYOUT/form4.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class Form3 extends StatefulWidget {
  const Form3({super.key});

  @override
  State<Form3> createState() => _Form3State();
}

class _Form3State extends State<Form3> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _showButton = false;

  final TextEditingController _fieldOfStudyController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _gradYearController = TextEditingController();
  
  final List<TextEditingController> _languageControllers = [TextEditingController()];

  String? _selectedEducation;
  final List<String> _educationLevels = [
    "High school",
    "Undergraduate",
    "Postgraduate",
    "Professional"
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _showButton = true);
      }
    });
  }

  void _addLanguageField() {
    setState(() {
      _languageControllers.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldOfStudyController.dispose();
    _institutionController.dispose();
    _gradYearController.dispose();
    for (var controller in _languageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the language section animation timing here so we can reuse it
    final languageAnimation = CurvedAnimation(
      parent: _controller, 
      curve: const Interval(0.7, 0.9, curve: Curves.easeOutCubic)
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color.fromARGB(146, 207, 187, 156), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    _buildHeaderReveal(),
                    const SizedBox(height: 60),
                    _buildEducationSection(0.1, 0.4),
                    const SizedBox(height: 30),
                    _buildAnimatedTextField("What’s your field of study or profession?", 0.3, 0.6, _fieldOfStudyController),
                    _buildAnimatedTextField("What’s your institution/company name?", 0.5, 0.8, _institutionController),
                    _buildAnimatedTextField("Graduation year (if applicable)?", 0.6, 0.85, _gradYearController),
                    
                    // Header for languages
                    _buildLabelOnly("Languages You Speak", languageAnimation),
                    
                    // Updated Map: Passing the animation to the existing language fields
                    ..._languageControllers.map((controller) => 
                      _buildMinimalField(controller, animation: languageAnimation)
                    ),
                    
                    const SizedBox(height: 10),
                    _buildPlusButton(0.8, 1.0),
                    const SizedBox(height: 60),
                    _buildNextButton(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderReveal() {
    final animation = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOut));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value,
        child: ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: animation.value,
            child: const Text(
              "TELL US ABOUT YOUR BACKGROUND.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, letterSpacing: 1.5, fontFamily: 'Serif', color: Color(0xFFD4C3A3)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEducationSection(double start, double end) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What’s your current education level?",
              style: TextStyle(color: Color.fromARGB(179, 185, 174, 152), fontSize: 14, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 15),
            ..._educationLevels.map((level) {
              bool isSelected = _selectedEducation == level;
              return GestureDetector(
                onTap: () => setState(() => _selectedEducation = level),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color.fromARGB(80, 128, 119, 106) : const Color.fromARGB(20, 128, 119, 106),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color.fromARGB(255, 181, 166, 139) : const Color.fromARGB(40, 128, 119, 106),
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    level,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isSelected ? const Color.fromARGB(255, 208, 195, 174) : const Color.fromARGB(150, 212, 195, 163), fontSize: 14),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField(String label, double start, double end, TextEditingController controller) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: animation.value,
                child: Opacity(
                  opacity: animation.value,
                  child: Text(label, style: const TextStyle(color: Color.fromARGB(179, 185, 174, 152), fontSize: 14, fontWeight: FontWeight.w300)),
                ),
              ),
            ),
            _buildMinimalField(controller, animation: animation),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelOnly(String label, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(bottom: 5),
        child: ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: animation.value,
            child: Text(label, style: const TextStyle(color: Color.fromARGB(179, 185, 174, 152), fontSize: 14, fontWeight: FontWeight.w300)),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalField(TextEditingController controller, {required Animation<double> animation}) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Column(
          children: [
            Opacity(
              opacity: animation.value,
              child: TextField(
                controller: controller,
                cursorColor: const Color(0xFFD4C3A3),
                style: const TextStyle(color: Color.fromARGB(255, 182, 172, 155), fontSize: 16),
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8), border: InputBorder.none),
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              transform: Matrix4.diagonal3Values(animation.value, 1.0, 1.0),
              color: const Color.fromARGB(97, 172, 162, 147),
            ),
            const SizedBox(height: 15),
          ],
        );
      }
    );
  }

  Widget _buildPlusButton(double start, double end) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOut));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value,
        child: GestureDetector(
          onTap: _addLanguageField,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(44, 128, 119, 106),
              shape: BoxShape.circle,
              border: Border.all(color: const Color.fromARGB(80, 212, 195, 163), width: 0.5),
            ),
            child: const Icon(Icons.add_rounded, color: Color(0xFFD4C3A3), size: 20),
          ),
        ),
      ),
    );
  }

Widget _buildNextButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _showButton ? 1.0 : 0.0,
      child: SizedBox(
        width: double.infinity,
        height: 30,
        child: OutlinedButton(
onPressed: _showButton
    ? () {
        // Collect all language strings from the list of controllers
        List<String> collectedLangs = _languageControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        // Save to Provider
        Provider.of<UserDataModel>(context, listen: false).updateForm3(
          edu: _selectedEducation,
          field: _fieldOfStudyController.text,
          inst: _institutionController.text,
          year: _gradYearController.text,
          langs: collectedLangs,
        );

        Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Form4()),
        );
      }
    : null,
                   style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(138, 90, 83, 73),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            side: BorderSide(color:  Color.fromARGB(255, 128, 119, 106), width: 0.7),
                            shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(15),
                            ),
                          ),
          child: const Text(
            "Next",
            style: TextStyle(
                color: Color.fromARGB(255, 191, 178, 160), letterSpacing: 1.2),
          ),
        ),
      ),
    );
}}