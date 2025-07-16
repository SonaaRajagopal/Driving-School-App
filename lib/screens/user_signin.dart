import 'package:drivinghub_welcome_login/auth/authfunctions.dart';
import 'package:flutter/material.dart';

class SignInUser extends StatefulWidget {
  const SignInUser({Key? key}) : super(key: key);

  @override
  _SignInUserState createState() => _SignInUserState();
}

class _SignInUserState extends State<SignInUser> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String fullname = '';
  bool login = false;
  bool isAdmin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Login Page') ,
        //backgroundColor: const Color.fromARGB(255, 3, 41, 111),
          //style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color:Colors.white), 
        ),

      body: SingleChildScrollView( 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), 
        child:Column(
          children: [
             SizedBox(height: 30),
          Text(
            'Sign In to view user / admin Dashboard !',
              style: TextStyle(fontSize: 25, 
              fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
      SizedBox(height: 20),
      Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //full name
              if (!login)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F9),
                      border: Border.all(
                        color: const Color(0xFFE8ECF4),
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        key: ValueKey('fullname'),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Full Name',
                          hintStyle: TextStyle(
                            color: Color(0xFF8391A1),
                          ),
                          prefixIcon: Icon(Icons.person, color: Color(0xFF8391A1)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Full Name';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          setState(() {
                            fullname = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 16),

              //Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(
                      color: const Color(0xFFE8ECF4),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      key: ValueKey('email'),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Email',
                        hintStyle: TextStyle(
                          color: Color(0xFF8391A1),
                        ),
                        prefixIcon: Icon(Icons.email, color: Color(0xFF8391A1)),
                      ),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please Enter valid Email';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        setState(() {
                          email = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              //Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(
                      color: const Color(0xFFE8ECF4),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      key: ValueKey('password'),
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Password',
                        hintStyle: TextStyle(
                          color: Color(0xFF8391A1),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF8391A1)),
                      ),
                      validator: (value) {
                        if (value!.length < 6) {
                          return 'Please Enter Password of min length 6';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        setState(() {
                          password = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),

              /*
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                      colors:[Color.fromARGB(255, 199, 230, 0), Color.fromARGB(255, 222, 218, 3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    */

              SizedBox(height: 16),

              // Admin Role Selection Switch
              if (!login)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Text('Sign up as Admin:'),
                      Switch(
                        value: isAdmin,
                        onChanged: (value) {
                          setState(() {
                            isAdmin = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Container(
                  height: 53,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Color.fromARGB(255, 214, 217, 2),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        if (login) {
                          await AuthServices.signinUser(email, password, context);
                        } else {
                          await AuthServices.signupUser(
                              email, password, fullname, context, isAdmin: isAdmin);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      login ? 'Login' : 'Create New Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 13),

              TextButton(
                onPressed: () {
                  setState(() {
                    login = !login;
                  });
                },
                child: Text(
                  login
                      ? "Don't have an account? Create New Account"
                      : "Already have an account? Login",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
     ],
   ),
      ),
      ),
  );
}
}