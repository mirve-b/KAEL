import 'package:flutter/material.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/login.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/signup.dart';
import 'package:video_player/video_player.dart';

// Import your pages here so the navigation works:
// import 'login_page.dart';
// import 'signup_page.dart';

class WelcomeScreen2 extends StatefulWidget {
  const WelcomeScreen2({super.key});

  @override
  State<WelcomeScreen2> createState() => _WelcomeScreen2State();
}

class _WelcomeScreen2State extends State<WelcomeScreen2> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/VIDEOS/bg.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
        _controller.setVolume(0);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          Container(color: const Color.fromARGB(69, 0, 0, 0)),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 135, 122, 107)),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 40),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/IMAGES/KAEL_2nd.png', width: 60),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('ABOUT US', style: TextStyle(fontFamily: 'Avenir Next', color: Color.fromARGB(255, 170, 157, 138))),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: () {},
                          child: const Text('HELP', style: TextStyle(fontFamily: 'Avenir Next', color: Color.fromARGB(255, 170, 157, 138))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double maxW = constraints.maxWidth;
                          double imageWidth = maxW * 0.6;
                          double buttonWidth = maxW * 0.35;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/IMAGES/i5.png', width: imageWidth.clamp(250, 500)),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // --- LOGIN BUTTON ---
                                  SizedBox(
                                    width: buttonWidth.clamp(120, 250),
                                    height: 30,
                                    child: _button('LOG IN', () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                                    }),
                                  ),
                                  const SizedBox(width: 20),
                                  // --- SIGN UP BUTTON ---
                                  SizedBox(
                                    width: buttonWidth.clamp(120, 250),
                                    height: 30,
                                    child: _button('SIGN UP', () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Signup()));
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}


Widget _button(String text, VoidCallback onTap) {
  return TextButton(
    onPressed: onTap, 
    style: TextButton.styleFrom(
      backgroundColor: const Color.fromARGB(137, 0, 0, 0),
      foregroundColor: const Color.fromARGB(255, 134, 123, 96),
      side: const BorderSide(
        color: Color.fromARGB(255, 128, 119, 106),
        width: 0.7,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: "Avenir Next",
        color: Color.fromARGB(255, 191, 178, 160),
      ),
    ),
  );
}