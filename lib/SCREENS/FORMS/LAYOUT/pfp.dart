import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/SCREENS/FORMS/LAYOUT/form3.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class Pfp extends StatefulWidget {
  final String? uploadedImagePath; 
  const Pfp({super.key, this.uploadedImagePath});

  @override
  State<Pfp> createState() => _PfpState();
}

class _PfpState extends State<Pfp> {
  int selectedIndex = 0;
  String? currentImagePath;
  String? generatedHeadshotPath;
  String? generatedCharacterPath;
  bool isHoveringFirstCard = false;

  @override
  void initState() {
    super.initState();
    currentImagePath = widget.uploadedImagePath ?? 
        Provider.of<UserDataModel>(context, listen: false).uploadedImagePath;
  }

  Future<void> _replaceImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    // FIXED: Guard against async gaps
    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      String newPath = result.files.single.path!;
      setState(() {
        currentImagePath = newPath;
      });
      Provider.of<UserDataModel>(context, listen: false).updateUploadedPath(newPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = (screenWidth * 0.9).clamp(0.0, 1000.0);
    double hPadding = (screenWidth * 0.05).clamp(15.0, 40.0);
    double cardWidth = screenWidth > 700 ? 210 : 150;
    double cardHeight = screenWidth > 700 ? 230 : 170;
    double spacing = (screenWidth * 0.04).clamp(10.0, 50.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFDBCFBC), size: 20), // FIXED: 8-digit hex
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 50),
              decoration: BoxDecoration(
                // FIXED: Corrected the hex value here
                border: Border.all(color: const Color.fromARGB(142, 212, 195, 163), width: 0.75),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "CURATE YOUR VISUAL PRESENCE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD4C3A3),
                      letterSpacing: 2,
                      fontSize: 18,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  SizedBox(
                    width: (cardWidth * 3) + (spacing * 2),
                    height: cardHeight,
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          left: selectedIndex * (cardWidth + spacing),
                          child: SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: CustomPaint(painter: GradientBorderPainter()),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFirstCard(cardWidth, cardHeight),
                            SizedBox(width: spacing),
                            _buildNormalCard(1, "Professional\nHeadshot", generatedHeadshotPath, cardWidth, cardHeight),
                            SizedBox(width: spacing),
                            _buildNormalCard(2, "Custom\nCharacter", generatedCharacterPath, cardWidth, cardHeight),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        String? pathToSave;
                        if (selectedIndex == 0) {
                          pathToSave = currentImagePath;
                        } else if (selectedIndex == 1) {
                          pathToSave = generatedHeadshotPath;
                        } else {
                          pathToSave = generatedCharacterPath;
                        }

                        Provider.of<UserDataModel>(context, listen: false).setFinalPfp(pathToSave);

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Form3()),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(138, 90, 83, 73),
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        side: const BorderSide(color: Color.fromARGB(255, 128, 119, 106), width: 0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("NEXT", style: TextStyle(color: Color.fromARGB(255, 191, 178, 160))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstCard(double w, double h) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHoveringFirstCard = true),
      onExit: (_) => setState(() => isHoveringFirstCard = false),
      child: GestureDetector(
        onTap: () => setState(() => selectedIndex = 0),
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              currentImagePath != null
                  ? Image.file(File(currentImagePath!), fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.person, color: Color.fromARGB(26, 0, 0, 0), size: 50)),
              if (isHoveringFirstCard) ...[
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: const Color.fromARGB(116, 53, 43, 21)),
                ),
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.file_upload_outlined, color: Color.fromARGB(255, 171, 160, 143), size: 22),
                    onPressed: _replaceImage,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalCard(int index, String label, String? path, double w, double h) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0),
          border: Border.all(color: const Color.fromARGB(94, 178, 164, 144)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: path != null
              ? Image.file(File(path), fit: BoxFit.cover)
              : Center(
                  child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color.fromARGB(140, 182, 170, 131), fontSize: 13)),
                ),
        ),
      ),
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFB2D8F5),
          Color(0xFFDB89BE),
          Color(0xFFD379CF),
          Color(0xFFF1E99B),
          Color(0xFFB2D8F5),
        ],
      ).createShader(rect);

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(15));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}