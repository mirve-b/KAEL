import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/SCREENS/FORMS/LAYOUT/form3.dart';
import 'package:kael/SCREENS/FORMS/LAYOUT/pfp.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class Form2 extends StatefulWidget {
  const Form2({super.key});

  @override
  State<Form2> createState() => _Form2State();
}

class _Form2State extends State<Form2> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _showButtons = true);
      }
    });
  }

  // 2. Logic to open macOS Finder
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Restricts selection to images
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      // Image selected! 
      String filePath = result.files.single.path!;
      debugPrint("Selected file: $filePath");
      
      // 3. Logic to open the next page (Waiting for your Form4/Image Edit page code)
      _navigateToNextPage(filePath);
    } else {
      // User canceled the picker
      debugPrint("User canceled the picker");
    }
  }

void _navigateToNextPage(String imagePath) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Pfp(uploadedImagePath: imagePath),
    ),
  );
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToForm3() {
    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const Form3(), 
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeaderReveal(),
                    const SizedBox(height: 40),
                    _buildSubtextReveal(),
                    const SizedBox(height: 60),
                    _buildImagePickerPlaceholder(),
                    const SizedBox(height: 80),
                    _buildSeparatorLine(),
                    const SizedBox(height: 40),
                    _buildActionButtons(),
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
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value,
        child: const Text(
          "CURATE YOUR PROFESSIONAL IMAGE",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 1.5,
            fontFamily: 'Serif',
            color: Color(0xFFD4C3A3),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtextReveal() {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value,
        child: const Text(
          "Upload a profile picture (optional)",
          style: TextStyle(
            color: Color.fromARGB(179, 185, 174, 152),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerPlaceholder() {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value,
        child: GestureDetector(
          onTap: _pickImage, 
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(44, 128, 119, 106),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "ADD",
                style: TextStyle(
                  color: Color(0xFFD4C3A3),
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeparatorLine() {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Container(
        height: 0.5,
        width: double.infinity,
        transform: Matrix4.diagonal3Values(animation.value, 1.0, 1.0),
        color: const Color.fromARGB(97, 172, 162, 147),
      ),
    );
  }

  Widget _buildActionButtons() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _showButtons ? 1.0 : 0.0,
      child: SizedBox(
        height: 30,
        width: 250,
        child: OutlinedButton(
          onPressed: _showButtons ? () {
  Provider.of<UserDataModel>(context, listen: false).setFinalPfp(null); 
  _navigateToForm3();
} : null,
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(45, 90, 83, 73),
            foregroundColor: const Color.fromARGB(255, 192, 173, 152),
            side: const BorderSide(color: Color.fromARGB(255, 128, 119, 106), width: 0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text("Skip", style: TextStyle(color: Color(0xFFD4C3A3))),
        ),
      ),
    );
  }
}