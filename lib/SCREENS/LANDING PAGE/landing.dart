import 'package:flutter/material.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/login.dart';
import 'package:kael/SCREENS/LOGIN%20%7C%20SIGNUP/signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 130),
        child: Column(
          children: [
            //CHILD 1 : TOP ROW
            Row(
              children: [
                Image.asset('assets/IMAGES/KAEL_2nd.png', width: 60),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'ABOUT US',
                    style: TextStyle(
                      fontFamily: 'Avenir Next',
                      color: Color.fromARGB(255, 170, 157, 138),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'HELP',
                    style: TextStyle(
                      fontFamily: 'Avenir Next',
                      color: Color.fromARGB(255, 170, 157, 138),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 100),
            //CHILD 3 : MAIN ROW
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(child: CustomColumnCard()),
                    SizedBox(width: 40),
                    Expanded(child: CustomColumnCard2()),
                    SizedBox(width: 40),
                    Expanded(child: CustomColumnCard3()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



//COLUMNCARD 1
class CustomColumnCard extends StatelessWidget {
  const CustomColumnCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Container (flexible)
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(186, 170, 157, 138),width: 1),
              borderRadius: BorderRadius.circular(15),
              color: Colors.black,
              image: const DecorationImage(
                image: AssetImage('assets/Images/I1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Image.asset('assets/IMAGES/KAEL_2nd.png',),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Bottom Container (flexible)
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(186, 170, 157, 138), width: 1),
              borderRadius: BorderRadius.circular(15),
              color: Colors.black,
            ),
            child: const Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'ACADEMIC E-LIBRARY &',
                    style: TextStyle(
                      color: Color.fromARGB(255, 170, 157, 138),
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Button (fixed height)
        SizedBox(
          height: 30,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              foregroundColor: const Color.fromARGB(255, 170, 157, 138),
              side: const BorderSide(color: Color.fromARGB(186, 170, 157, 138), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Policy'),
          ),
        ),
      ],
    );
  }
}





//COLUMNCARD 2
class CustomColumnCard2 extends StatelessWidget {
  const CustomColumnCard2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Container (flexible)
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(186, 170, 157, 138), width: 1),
              borderRadius: BorderRadius.circular(15),
              color: Colors.black,
              image: const DecorationImage(
                image: AssetImage('assets/Images/I2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Button (fixed height)
        SizedBox(
          height: 30,
          child: TextButton(
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 71, 53, 34),
              foregroundColor: const Color.fromARGB(255, 170, 157, 138),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('LOGIN',style: TextStyle(color: Color.fromARGB(255, 185, 172, 153), fontFamily: "Avenir Next")),
          ),
        ),
      ],
    );
  }
}

//COLUMNCARD 3
class CustomColumnCard3 extends StatelessWidget {
  const CustomColumnCard3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Container (flexible)
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all( color: Color.fromARGB(186, 170, 157, 138), width: 1),
              borderRadius: BorderRadius.circular(15),
              color: Colors.black,
              image: const DecorationImage(
                image: AssetImage('assets/Images/I3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Button (fixed height)
        SizedBox(
          height: 30,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Signup()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 71, 53, 34),
              foregroundColor: const Color.fromARGB(255, 170, 157, 138),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('SIGN UP', style: TextStyle(color: Color.fromARGB(255, 185, 172, 153), fontFamily: "Avenir Next"),),
          ),
        ),
      ],
    );
  }
}
