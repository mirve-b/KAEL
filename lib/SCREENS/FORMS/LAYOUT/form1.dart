import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/LAYOUT/form2.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class Form1 extends StatefulWidget {
  const Form1({super.key});

  @override
  State<Form1> createState() => _Form1State();
}

class _Form1State extends State<Form1> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _showButton = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Back Button
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    _buildHeaderReveal(),
                    const SizedBox(height: 80),
                    _buildAnimatedTextField("Preferred display name / nickname", 0.1, 0.4, _nameController),
                    _buildAnimatedTextField("Professional or creative title (e.g., Graphic Designer & Researcher)", 0.3, 0.6, _titleController),
                    _buildAnimatedTextField("Country", 0.5, 0.8, _countryController),
                    _buildAnimatedTextField("Contact Number", 0.7, 0.9, _phoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 50),
                    _buildButton(),
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
    final animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value,
        child: ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: animation.value,
            child: const Text(
              "LET’S SET UP YOUR CREATIVE-ACADEMIC IDENTITY",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                letterSpacing: 1.5,
                fontFamily: 'Serif',
                color: Color(0xFFD4C3A3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField(String label, double start, double end, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Reveal for Label
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: animation.value,
                  child: Opacity(
                    opacity: animation.value,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color.fromARGB(179, 185, 174, 152),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
              // Fade Reveal for Input
              Opacity(
                opacity: animation.value,
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  cursorColor: const Color(0xFFD4C3A3),
                  style: const TextStyle(color: Color.fromARGB(255, 182, 172, 155), fontSize: 16),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                ),
              ),
              // Sliding Line Reveal
              Container(
                height: 0.5,
                width: double.infinity,
                transform: Matrix4.diagonal3Values(animation.value, 1.0, 1.0),
                color: const Color.fromARGB(97, 172, 162, 147),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _showButton ? 1.0 : 0.0,
      child: SizedBox(
        width: double.infinity,
        height: 30,
        child: OutlinedButton(
          onPressed: _showButton ? () {
  // 1. Save data to the Model
  Provider.of<UserDataModel>(context, listen: false).updateForm1(
    n: _nameController.text,
    t: _titleController.text,
    c: _countryController.text,
    p: _phoneController.text,
  );

  // 2. Navigate
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Form2()),
  );
} : null,
          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(138, 90, 83, 73),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            side: BorderSide(color:  Color.fromARGB(255, 128, 119, 106), width: 0.7),
                            shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(15),
                            ),
                          ),
          child: const Text("Next", style: TextStyle(color: Color.fromARGB(255, 191, 178, 160), letterSpacing: 1.2)),
        ),
      ),
    );
  }
}