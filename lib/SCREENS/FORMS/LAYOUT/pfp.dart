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
  String? currentImagePath;
  bool isHoveringCard = false;
  bool isNextHovered = false;
  String? _errorMessage;

  static const _accentGrey = Color(0xFF9A9A9A);
  static const _accentRed = Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();
    currentImagePath = widget.uploadedImagePath ??
        Provider.of<UserDataModel>(context, listen: false).uploadedImagePath;
  }

  bool get _hasSourceImage =>
      currentImagePath != null && currentImagePath!.isNotEmpty && File(currentImagePath!).existsSync();

  Future<void> _replaceImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      final newPath = result.files.single.path!;
      setState(() {
        currentImagePath = newPath;
        _errorMessage = null;
      });
      Provider.of<UserDataModel>(context, listen: false).updateUploadedPath(newPath);
    }
  }

  void _onNext() {
    if (!_hasSourceImage) {
      setState(() => _errorMessage = 'Upload a photo before continuing.');
      return;
    }

    Provider.of<UserDataModel>(context, listen: false).setFinalPfp(currentImagePath);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Form3()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = (screenWidth * 0.9).clamp(0.0, 1000.0);
    final hPadding = (screenWidth * 0.05).clamp(15.0, 40.0);
    final cardWidth = screenWidth > 700 ? 210.0 : 150.0;
    final cardHeight = screenWidth > 700 ? 230.0 : 170.0;

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
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _accentGrey, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: containerWidth,
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 50),
                decoration: BoxDecoration(
                  border: Border.all(color: _accentGrey.withValues(alpha: 0.5), width: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CURATE YOUR VISUAL PRESENCE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _accentGrey,
                        letterSpacing: 2,
                        fontSize: 18,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasSourceImage
                          ? 'Tap your photo to replace it, or continue with this image.'
                          : 'Upload a photo from your device to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: CustomPaint(
                        painter: GradientBorderPainter(),
                        child: _buildUploadCard(cardWidth, cardHeight),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 11, height: 1.4),
                      ),
                    ],
                    const SizedBox(height: 40),
                    MouseRegion(
                      onEnter: (_) => setState(() => isNextHovered = true),
                      onExit: (_) => setState(() => isNextHovered = false),
                      child: AnimatedScale(
                        scale: isNextHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _onNext,
                            style: TextButton.styleFrom(
                              backgroundColor: _accentRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text('NEXT', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(double w, double h) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHoveringCard = true),
      onExit: (_) => setState(() => isHoveringCard = false),
      child: GestureDetector(
        onTap: _replaceImage,
        child: Container(
          width: w,
          height: h,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              currentImagePath != null
                  ? Image.file(File(currentImagePath!), fit: BoxFit.cover)
                  : const Center(
                      child: Icon(Icons.person, color: Color.fromARGB(26, 255, 255, 255), size: 50),
                    ),
              if (isHoveringCard) ...[
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: const Color.fromARGB(116, 127, 21, 21)),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.file_upload_outlined, color: _accentGrey, size: 22),
                        onPressed: _replaceImage,
                      ),
                      const Text('UPLOAD', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ],
              if (_hasSourceImage)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.check_circle, color: Colors.redAccent, size: 18),
                ),
            ],
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
          Color.fromARGB(255, 255, 77, 77),
          Color.fromARGB(255, 255, 156, 156),
          Color.fromARGB(255, 255, 53, 110),
          Color.fromARGB(255, 255, 23, 7),
          Color.fromARGB(255, 255, 77, 77),
        ],
      ).createShader(rect);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(15));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
