import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatters
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
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Simple hardcoded list of countries to keep dependencies light
  final List<String> _countries = [
    "United States", "United Kingdom", "Canada", "Australia", "India", 
    "Germany", "France", "Japan", "Brazil", "South Africa", "United Arab Emirates"
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

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "SELECT YOUR COUNTRY",
                style: TextStyle(
                  color: Color(0xFFD4C3A3),
                  fontSize: 14,
                  letterSpacing: 1.5,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _countries[index],
                        style: const TextStyle(color: Color.fromARGB(255, 182, 172, 155)),
                      ),
                      onTap: () {
                        setState(() {
                          _countryController.text = _countries[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft, // Adjusts where the "light" starts
            radius: 1.2,              // How far the color spreads
            colors: [
              Color(0xFF8B0000),      // Dark red (Inspo color)
              Colors.black,           // Fading to black
            ],
          ),
        ),
      ),
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
                  child: Form(
                    key: _formKey, 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        _buildHeaderReveal(),
                        const SizedBox(height: 80),
                        _buildAnimatedTextField(
                          label: "Preferred display name / nickname", 
                          start: 0.1, 
                          end: 0.4, 
                          controller: _nameController,
                          validator: (val) => val == null || val.trim().isEmpty ? "Name is required" : null,
                        ),
                        _buildAnimatedTextField(
                          label: "Professional or creative title (e.g., Graphic Designer & Researcher)", 
                          start: 0.3, 
                          end: 0.6, 
                          controller: _titleController,
                          validator: (val) => val == null || val.trim().isEmpty ? "Title is required" : null,
                        ),
                        _buildAnimatedCountryField("Country", 0.5, 0.8),
                        _buildAnimatedTextField(
                          label: "Contact Number", 
                          start: 0.7, 
                          end: 0.9, 
                          controller: _phoneController, 
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Only numbers
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Contact number is required";
                            if (val.length < 7 || val.length > 15) return "Enter a valid phone number (7-15 digits)";
                            return null;
                          },
                        ),
                        const SizedBox(height: 50),
                        _buildButton(),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

  // Refactored helper to support Input Validation
  Widget _buildAnimatedTextField({
    required String label, 
    required double start, 
    required double end, 
    required TextEditingController controller, 
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
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
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  validator: validator,
                  cursorColor: const Color(0xFFD4C3A3),
                  style: const TextStyle(color: Color.fromARGB(255, 182, 172, 155), fontSize: 16),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 11),
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

  // Separate method for country dropdown selection
  Widget _buildAnimatedCountryField(String label, double start, double end) {
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
              Opacity(
                opacity: animation.value,
                child: FormField<String>(
                  validator: (_) => _countryController.text.isEmpty ? "Please select a country" : null,
                  builder: (FormFieldState<String> state) {
                    return GestureDetector(
                      onTap: _showCountryPicker,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _countryController.text.isEmpty 
                                      ? "Tap to select country" 
                                      : _countryController.text,
                                  style: TextStyle(
                                    color: _countryController.text.isEmpty 
                                        ? const Color.fromARGB(100, 182, 172, 155) 
                                        : const Color.fromARGB(255, 182, 172, 155), 
                                    fontSize: 16
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Color.fromARGB(146, 207, 187, 156)),
                              ],
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  state.errorText ?? '',
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                                ),
                              ),
                          ],
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
            // Trigger constraints check before routing
            if (_formKey.currentState!.validate()) {
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
            }
          } : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.red[900],
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            side: const BorderSide(color: Color.fromARGB(255, 204, 25, 12), width: 0.7),
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