import 'package:flutter/material.dart';
import 'package:drivinghub_welcome_login/screens/user_signin.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        
        child: Column(
          children: [
            Image.asset(
              "assets/bg.jpg",
              height: MediaQuery.of(context).size.height * 0.55,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
             const Text(
                "Driving Hub", 
                style: TextStyle(
                fontSize: 50, 
                fontWeight: FontWeight.bold, 
                fontFamily:'PublicSans-SemiBold',
                color: Color.fromARGB(255, 1, 2, 47), 
                ),
             ),
            const SizedBox(height: 25),
            //login button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: MaterialButton(
                      color:  Color.fromARGB(255, 24, 78, 178),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color.fromARGB(255, 221, 229, 237),
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInUser()));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "LOGIN PAGE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ), 
          ],
        ),
      ),
    );
  }
}
