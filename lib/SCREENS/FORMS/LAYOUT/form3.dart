import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isNextHovered = false;
  String? _hoveredEducation;

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

  final List<String> _languageOptions = [
    "English", "Urdu", "Spanish", "French", "German",
    "Mandarin", "Arabic", "Japanese", "Russian"
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

  Future<void> _selectGraduationDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
      helpText: "SELECT GRADUATION DATE",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9A9A9A),
              onPrimary: Colors.black,
              surface: Color.fromARGB(255, 20, 18, 16),
              onSurface: Color.fromARGB(255, 182, 172, 155),
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _gradYearController.text = DateFormat('MMMM yyyy').format(picked).toUpperCase();
      });
    }
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
    final languageAnimation = CurvedAnimation(
      parent: _controller, 
      curve: const Interval(0.7, 0.9, curve: Curves.easeOutCubic)
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,
                colors: [Color(0xFF8B0000), Colors.black],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Color.fromARGB(146, 207, 187, 156), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                const Text(
                  "03/ 04",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 90),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    _buildHeaderReveal(),
                    const SizedBox(height: 60),
                    _buildEducationSection(0.1, 0.4),
                    const SizedBox(height: 30),
                    _buildAnimatedTextField("What’s your field of study or profession?", 0.3, 0.6, _fieldOfStudyController),
                    _buildAnimatedTextField("What’s your institution/company name?", 0.5, 0.8, _institutionController),
                    _buildAnimatedTextField(
                      "Graduation year (if applicable)?", 
                      0.6, 
                      0.85, 
                      _gradYearController,
                      readOnly: true,
                      onTap: () => _selectGraduationDate(context),
                    ),
                    _buildLabelOnly("Languages You Speak", languageAnimation),
                    ..._languageControllers.map((controller) => 
                      _buildMinimalLanguageField(controller, animation: languageAnimation)
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
              style: TextStyle(fontSize: 20, letterSpacing: 1.5, fontFamily: 'Serif', color: Color(0xFF9A9A9A)),
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
              bool isHovered = _hoveredEducation == level;
              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredEducation = level),
                onExit: (_) => setState(() => _hoveredEducation = null),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedEducation = level),
                  child: AnimatedScale(
                    scale: isHovered ? 1.02 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color.fromARGB(150, 139, 0, 0) : (isHovered ? const Color.fromARGB(40, 128, 119, 106) : const Color.fromARGB(20, 128, 119, 106)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.red : const Color.fromARGB(40, 128, 119, 106),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        level,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isSelected ? Colors.white : const Color.fromARGB(150, 154, 154, 154), fontSize: 14),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField(
    String label, 
    double start, 
    double end, 
    TextEditingController controller, 
    {bool readOnly = false, VoidCallback? onTap}
  ) {
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
            _buildMinimalField(controller, animation: animation, readOnly: readOnly, onTap: onTap),
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

  Widget _buildMinimalField(
    TextEditingController controller, 
    {required Animation<double> animation, bool readOnly = false, VoidCallback? onTap}
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Column(
          children: [
            Opacity(
              opacity: animation.value,
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                cursorColor: const Color(0xFF9A9A9A),
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

  Widget _buildMinimalLanguageField(TextEditingController controller, {required Animation<double> animation}) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Column(
          children: [
            Opacity(
              opacity: animation.value,
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _languageOptions;
                  }
                  return _languageOptions.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
                  if (controller.text.isNotEmpty && fieldController.text.isEmpty) {
                    fieldController.text = controller.text;
                  }
                  fieldController.addListener(() {
                    controller.text = fieldController.text;
                  });
                  return TextField(
                    controller: fieldController,
                    focusNode: focusNode,
                    cursorColor: const Color(0xFF9A9A9A),
                    style: const TextStyle(color: Color.fromARGB(255, 182, 172, 155), fontSize: 16),
                    decoration: const InputDecoration(
                      isDense: true, 
                      contentPadding: EdgeInsets.symmetric(vertical: 8), 
                      border: InputBorder.none,
                      hintText: "TYPE OR CHOOSE A LANGUAGE",
                      hintStyle: TextStyle(color: Color.fromARGB(60, 154, 154, 154), fontSize: 14),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      color: const Color.fromARGB(255, 20, 18, 16),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 20, 18, 16),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color.fromARGB(40, 128, 119, 106), width: 0.5),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(
                                  option, 
                                  style: const TextStyle(color: Color.fromARGB(255, 182, 172, 155), fontSize: 14),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
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
              border: Border.all(color: const Color.fromARGB(80, 154, 154, 154), width: 0.5),
            ),
            child: const Icon(Icons.add_rounded, color: Color(0xFF9A9A9A), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _showButton ? 1.0 : 0.0,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isNextHovered = true),
        onExit: (_) => setState(() => _isNextHovered = false),
        child: AnimatedScale(
          scale: _isNextHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: SizedBox(
            width: double.infinity,
            height: 30,
            child: OutlinedButton(
              onPressed: _showButton
                  ? () {
                      List<String> collectedLangs = _languageControllers
                          .map((c) => c.text.trim())
                          .where((text) => text.isNotEmpty)
                          .toList();
                      if (_selectedEducation == null || 
                          _fieldOfStudyController.text.trim().isEmpty || 
                          _institutionController.text.trim().isEmpty || 
                          _gradYearController.text.trim().isEmpty || 
                          collectedLangs.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red[900],
                            content: const Text(
                              "ALL BACKGROUND FIELDS ARE COMPULSORY.", 
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 12),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      Provider.of<UserDataModel>(context, listen: false).updateForm3(
                        edu: _selectedEducation,
                        field: _fieldOfStudyController.text.trim(),
                        inst: _institutionController.text.trim(),
                        year: _gradYearController.text.trim(),
                        langs: collectedLangs,
                      );
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const Form4()),
                      );
                    }
                  : null,
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[900],
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color.fromARGB(255, 204, 25, 12), width: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PolkaDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(220, 0, 0, 0)
      ..style = PaintingStyle.fill;
    const double spacing = 28.0;
    const double radius = 2.5;
    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}