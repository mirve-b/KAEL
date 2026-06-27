import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/API/gemini_service.dart';
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
  final GeminiService _geminiService = GeminiService();

  int selectedIndex = 0;
  String? currentImagePath;
  String? generatedHeadshotPath;
  String? generatedCharacterPath;
  bool isHoveringFirstCard = false;
  bool isNextHovered = false;
  bool isGeneratingHeadshot = false;
  bool isGeneratingCharacter = false;
  String? _errorMessage;

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
        generatedHeadshotPath = null;
        generatedCharacterPath = null;
        _errorMessage = null;
      });
      Provider.of<UserDataModel>(context, listen: false).updateUploadedPath(newPath);
    }
  }

  Future<void> _generateHeadshot() async {
    if (!_hasSourceImage || isGeneratingHeadshot) return;
    setState(() {
      isGeneratingHeadshot = true;
      _errorMessage = null;
    });

    try {
      final path = await _geminiService.generateProfessionalHeadshot(currentImagePath!);
      if (!mounted) return;
      setState(() {
        generatedHeadshotPath = path;
        selectedIndex = 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Headshot generation failed: $e');
    } finally {
      if (mounted) setState(() => isGeneratingHeadshot = false);
    }
  }

  Future<void> _generateCharacter() async {
    if (!_hasSourceImage || isGeneratingCharacter) return;
    setState(() {
      isGeneratingCharacter = true;
      _errorMessage = null;
    });

    try {
      final path = await _geminiService.generateCharacterAvatar(currentImagePath!);
      if (!mounted) return;
      setState(() {
        generatedCharacterPath = path;
        selectedIndex = 2;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Character generation failed: $e');
    } finally {
      if (mounted) setState(() => isGeneratingCharacter = false);
    }
  }

  void _onNext() {
    String? pathToSave;
    if (selectedIndex == 0) {
      pathToSave = currentImagePath;
    } else if (selectedIndex == 1) {
      pathToSave = generatedHeadshotPath;
    } else {
      pathToSave = generatedCharacterPath;
    }

    if (pathToSave == null || pathToSave.isEmpty) {
      setState(() => _errorMessage = 'Select or generate an image before continuing.');
      return;
    }

    Provider.of<UserDataModel>(context, listen: false).setFinalPfp(pathToSave);
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
    final spacing = (screenWidth * 0.04).clamp(10.0, 50.0);

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFDBCFBC), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: containerWidth,
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 50),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(142, 212, 195, 163), width: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CURATE YOUR VISUAL PRESENCE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD4C3A3),
                        letterSpacing: 2,
                        fontSize: 18,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasSourceImage
                          ? 'Use your photo as-is, or generate AI options below.'
                          : 'Upload a photo first, then generate AI headshot or character options.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                              _buildAiCard(
                                index: 1,
                                label: 'Professional\nHeadshot',
                                path: generatedHeadshotPath,
                                isGenerating: isGeneratingHeadshot,
                                onGenerate: _generateHeadshot,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight,
                              ),
                              SizedBox(width: spacing),
                              _buildAiCard(
                                index: 2,
                                label: 'Custom\nCharacter',
                                path: generatedCharacterPath,
                                isGenerating: isGeneratingCharacter,
                                onGenerate: _generateCharacter,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight,
                              ),
                            ],
                          ),
                        ],
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
                            onPressed: (isGeneratingHeadshot || isGeneratingCharacter) ? null : _onNext,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red[900],
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

  Widget _buildFirstCard(double w, double h) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHoveringFirstCard = true),
      onExit: (_) => setState(() => isHoveringFirstCard = false),
      child: GestureDetector(
        onTap: () => setState(() => selectedIndex = 0),
        child: Container(
          width: w,
          height: h,
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
              if (isHoveringFirstCard) ...[
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: const Color.fromARGB(116, 127, 21, 21)),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.file_upload_outlined, color: Color(0xFFABA089), size: 22),
                        onPressed: _replaceImage,
                      ),
                      const Text('UPLOAD', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ],
              if (selectedIndex == 0)
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

  Widget _buildAiCard({
    required int index,
    required String label,
    required String? path,
    required bool isGenerating,
    required VoidCallback onGenerate,
    required double cardWidth,
    required double cardHeight,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (path != null) {
          setState(() => selectedIndex = index);
        } else if (_hasSourceImage) {
          onGenerate();
        } else {
          setState(() => _errorMessage = 'Upload a source photo in the first card before generating.');
        }
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          border: Border.all(color: const Color.fromARGB(94, 178, 164, 144)),
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (path != null)
              Image.file(File(path), fit: BoxFit.cover)
            else if (isGenerating)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4C3A3)),
                      ),
                      SizedBox(height: 12),
                      Text('GENERATING...', style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color.fromARGB(140, 182, 170, 131), fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color.fromARGB(80, 212, 195, 163)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'TAP TO GENERATE',
                          style: TextStyle(color: Color(0xFFD4C3A3), fontSize: 8, letterSpacing: 1.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (path != null && !isGenerating)
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onGenerate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('REGEN', style: TextStyle(color: Colors.white70, fontSize: 8)),
                  ),
                ),
              ),
            if (isSelected && path != null)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: Colors.redAccent, size: 18),
              ),
          ],
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
