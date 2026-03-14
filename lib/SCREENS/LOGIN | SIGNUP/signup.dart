import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added provider
import 'package:kael/SCREENS/FORMS/LAYOUT/form1.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/login.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart'; // Ensure path is correct

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // --- CONTROLLERS ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACK BUTTON
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color.fromARGB(147, 219, 207, 188), size: 20),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          /// MAIN CONTENT
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 900),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 24,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 196, 179, 155),
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "CREATE AN ACCOUNT",
                          style: TextStyle(
                              fontSize: 30,
                              fontFamily: "BacasimeAntique",
                              color: Color(0xFFD4C3A3)),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nameController, // Attached Controller
                          cursorHeight: 16,
                          cursorColor: const Color.fromARGB(255, 209, 171, 109),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 186, 176, 158),
                              fontFamily: "Avenir Next"),
                          decoration: const InputDecoration(
                            hintText: "FULL NAME",
                            hintStyle: TextStyle(
                                color: Color.fromARGB(132, 219, 207, 188),
                                fontFamily: "Avenir Next",
                                fontSize: 14),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 219, 207, 188),
                                  width: 0.2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 219, 207, 188),
                                  width: 0.2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 203, 162, 98),
                                  width: 0.2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _emailController, // Attached Controller
                          cursorHeight: 16,
                          cursorColor: const Color.fromARGB(255, 209, 171, 109),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 186, 176, 158),
                              fontFamily: "Avenir Next"),
                          decoration: const InputDecoration(
                            hintText: "EMAIL",
                            hintStyle: TextStyle(
                                color: Color.fromARGB(132, 219, 207, 188),
                                fontFamily: "Avenir Next",
                                fontSize: 14),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 219, 207, 188),
                                  width: 0.2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 219, 207, 188),
                                  width: 0.2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 219, 207, 188),
                                  width: 0.2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _passwordController, // Attached Controller
                          cursorHeight: 16,
                          cursorColor: const Color.fromARGB(255, 209, 171, 109),
                          obscureText: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 186, 176, 158),
                              fontFamily: "Avenir Next"),
                          decoration: const InputDecoration(
                            hintText: "PASSWORD",
                            hintStyle: TextStyle(
                                color: Color.fromARGB(132, 219, 207, 188),
                                fontFamily: "Avenir Next",
                                fontSize: 14),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 219, 207, 188),
                                  width: 0.2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 219, 207, 188),
                                  width: 0.2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 219, 207, 188),
                                  width: 0.2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        SizedBox(
                          height: 27,
                          width: 250,
                          child: TextButton(
                            onPressed: () {
                              final userModel = Provider.of<UserDataModel>(context, listen: false);
                              userModel.signupUser(
                                full: _nameController.text, 
                                mail: _emailController.text
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Form1()),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(138, 90, 83, 73),
                              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 128, 119, 106),
                                  width: 0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                'SIGN UP',
                                style: TextStyle(
                                    fontFamily: "Avenir Next",
                                    color: Color.fromARGB(255, 191, 178, 160)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                              color: Color.fromARGB(69, 219, 207, 188),
                              fontFamily: "Avenir Next"),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 27,
                          width: 250,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color.fromARGB(137, 0, 0, 0),
                              foregroundColor:
                                  const Color.fromARGB(255, 134, 123, 96),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 128, 119, 106),
                                  width: 0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                'LOG IN',
                                style: TextStyle(
                                    fontFamily: "Avenir Next",
                                    color: Color.fromARGB(255, 191, 178, 160)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}