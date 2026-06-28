import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/LAYOUT/done.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class Form4 extends StatefulWidget {
  const Form4({super.key});

  @override
  State<Form4> createState() => _Form4State();
}

class _Form4State extends State<Form4> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _showButton = false;
  bool _isNextHovered = false;
  String? _hoveredInterest;

  final List<TextEditingController> _skillControllers = [TextEditingController()];
  final TextEditingController _hobbiesController = TextEditingController();

  final Set<String> _selectedInterests = {};
  final List<String> _interestOptions = [
    "Research & Academia", "Creative Arts & Design",
    "Writing & Storytelling", "Tech & Digital Innovation",
    "Media & Communication", "Psychology & Humanities",
    "Social Impact & Culture", "Career & Entrepreneurship",
    "Fashion & Aesthetics", "Music & Audio Production"
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

  void _addSkillField() => setState(() => _skillControllers.add(TextEditingController()));

  void _toggleInterest(String interest) => setState(() {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else {
      _selectedInterests.add(interest);
    }
  });

  @override
  void dispose() {
    _controller.dispose();
    for (var c in _skillControllers) {
      c.dispose();
    }
    _hobbiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skillsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
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
                const Text("04/ 04", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
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
                    _buildLabelOnly("List your key skills (AI, writing, art, coding, etc.)", skillsAnimation),
                    ..._skillControllers.map((controller) => _buildMinimalField(controller, animation: skillsAnimation)),
                    _buildPlusButton(0.4, 0.6),
                    const SizedBox(height: 40),
                    _buildInterestGrid(0.5, 0.8),
                    const SizedBox(height: 40),
                    _buildAnimatedTextField("Hobbies / Personal Interests", 0.7, 0.9, _hobbiesController),
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
            child: const Text("LET’S HIGHLIGHT WHAT YOU’RE GREAT AT!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, letterSpacing: 1.5, fontFamily: 'Serif', color: Color(0xFF9A9A9A)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestGrid(double start, double end) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose your main interest areas (multi-select):",
              style: TextStyle(color: Color.fromARGB(179, 185, 174, 152), fontSize: 14, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _interestOptions.map((interest) {
                bool isSelected = _selectedInterests.contains(interest);
                bool isHovered = _hoveredInterest == interest;
                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredInterest = interest),
                  onExit: (_) => setState(() => _hoveredInterest = null),
                  child: GestureDetector(
                    onTap: () => _toggleInterest(interest),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color.fromARGB(150, 139, 0, 0) : (isHovered ? const Color.fromARGB(40, 128, 119, 106) : const Color.fromARGB(20, 128, 119, 106)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.red : const Color.fromARGB(40, 128, 119, 106),
                          width: 0.7,
                        ),
                      ),
                      child: Text(interest,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color.fromARGB(150, 154, 154, 154),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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

  Widget _buildPlusButton(double start, double end) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOut));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value,
        child: GestureDetector(
          onTap: _addSkillField,
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
            child: ElevatedButton(
              onPressed: () {
                List<String> collectedSkills = _skillControllers
                    .map((c) => c.text.trim())
                    .where((text) => text.isNotEmpty)
                    .toList();
                if (collectedSkills.isEmpty || _selectedInterests.isEmpty || _hobbiesController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please complete all fields and select interests."),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }
                Provider.of<UserDataModel>(context, listen: false).updateForm4(
                  skillList: collectedSkills,
                  interestSet: _selectedInterests,
                  hobbyText: _hobbiesController.text.trim(),
                );
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Done()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Next", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ),
        ),
      ),
    );
  }

}