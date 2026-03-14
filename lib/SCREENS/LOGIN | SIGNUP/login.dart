import 'package:flutter/material.dart';
import 'package:kael/SCREENS/HOME/home_screen.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/signup.dart';

class Login extends StatelessWidget{
 const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACK BUTTON (top-left)
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
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
                
                      Text("WELCOME BACK!", style: TextStyle(fontSize: 27,fontFamily: "BacasimeAntique", color: const  Color(0xFFD4C3A3)),),
                      Text("LOGIN TO CONTINUE", style: TextStyle(fontSize: 20,fontFamily: "BacasimeAntique", color: const  Color(0xFFD4C3A3)),),
                
                      SizedBox(height: 10,),
                
                      TextField(
                        cursorHeight: 16,
                        cursorColor: const Color.fromARGB(255, 209, 171, 109),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: const Color.fromARGB(255, 186, 176, 158), fontFamily: "Avenir Next"),
                        decoration: InputDecoration(
                          hintText: "EMAIL",
                          hintStyle: TextStyle(color: const Color.fromARGB(132, 219, 207, 188), fontFamily: "Avenir Next", fontSize: 14),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 219, 207, 188), width: 0.2),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 219, 207, 188), width: 0.2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 203, 162, 98), width: 0.2),
                          ),
                        ),
                      ),
                
                      const SizedBox(height: 5),
                
                      TextField(
                        cursorHeight: 16,
                        cursorColor: const Color.fromARGB(255, 209, 171, 109),
                        obscureText: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: const Color.fromARGB(255, 186, 176, 158), fontFamily: "Avenir Next"),
                        decoration: InputDecoration(
                          hintText: "PASSWORD",
                          hintStyle: TextStyle(color: const Color.fromARGB(132, 219, 207, 188), fontFamily: "Avenir Next", fontSize: 14),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 219, 207, 188), width: 0.2),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 219, 207, 188), width: 0.2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 219, 207, 188), width: 0.2),
                          ),
                        ),
                      ),
                
                      SizedBox(height: 40,),
                
                      SizedBox(
                        height: 27,
                        width: 300,
                        child: TextButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),);
                          }, 
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(138, 90, 83, 73),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            side: BorderSide(color:  Color.fromARGB(255, 128, 119, 106), width: 0.7),
                            shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 94, right: 94),
                            child: Text('LOG IN', style: TextStyle(fontFamily: "Avenir Next", color: const Color.fromARGB(255, 191, 178, 160)),),
                          ),
                         ),
                      ),
                
                      SizedBox(height: 10,),
                      Text("Don't have an account?", style: TextStyle(color: const Color.fromARGB(69, 219, 207, 188), fontFamily: "Avenir Next"),),
                      SizedBox(height: 10,),
                
                      SizedBox(
                        height: 27,
                        width: 300,
                        child: TextButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Signup()),);
                          }, 
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(137, 0, 0, 0),
                            foregroundColor: const Color.fromARGB(255, 134, 123, 96),
                            side: BorderSide(color:  Color.fromARGB(255, 128, 119, 106), width: 0.7),
                            shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 42, right: 42),
                            child: Text('CREATE AN ACCOUNT', style: TextStyle(fontFamily: "Avenir Next", color: const Color.fromARGB(255, 191, 178, 160)),),
                          ),
                         ),
                      ),
                
                    ],
                  ),
        ),
              ),
            ),
          ),)
        ],
      ),
    );
  }
}
