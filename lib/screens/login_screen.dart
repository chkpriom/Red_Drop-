// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'home_screen.dart';
// import 'register_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   bool _obscurePassword = true;
//   bool _isShowingPassword = false;
//
//   void showPasswordTemporarily() {
//     if (_isShowingPassword) return; // prevent multiple triggers
//
//     setState(() {
//       _obscurePassword = false;
//       _isShowingPassword = true;
//     });
//
//     Future.delayed(Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() {
//           _obscurePassword = true;
//           _isShowingPassword = false;
//         });
//       }
//     });
//   }
//
//   void login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => HomeScreen()),
//       );
//     } on FirebaseAuthException catch (e) {
//       print('Login error: ${e.code}');
//       String message;
//       switch (e.code) {
//         case 'user-not-found':
//           message = 'No user found for that email.';
//           break;
//         case 'wrong-password':
//           message = 'Wrong password provided.';
//           break;
//         case 'invalid-email':
//           message = 'Invalid email format.';
//           break;
//         case 'user-disabled':
//           message = 'This account has been disabled.';
//           break;
//         default:
//           message = 'Login failed: ${e.message}';
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     } catch (e) {
//       print('Unexpected error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An unexpected error occurred.')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Log In')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) =>
//                 value == null || value.isEmpty ? 'Enter email' : null,
//               ),
//               TextFormField(
//                 controller: passwordController,
//                 obscureText: _obscurePassword,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   suffixIcon: IconButton(
//                     icon: Icon(Icons.visibility),
//                     onPressed: showPasswordTemporarily,
//                     tooltip: 'Show password for 5 seconds',
//                   ),
//                 ),
//                 validator: (value) => value == null || value.length < 6
//                     ? 'Password must be at least 6 characters'
//                     : null,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: login,
//                 child: Text('Log In'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => RegisterScreen()),
//                   );
//                 },
//                 child: Text('Don\'t have an account? Sign Up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isShowingPassword = false;

  void showPasswordTemporarily() {
    if (_isShowingPassword) return;

    setState(() {
      _obscurePassword = false;
      _isShowingPassword = true;
    });

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _obscurePassword = true;
          _isShowingPassword = false;
        });
      }
    });
  }

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.red[700],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      appBar: AppBar(
        title: Text('Log In'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                style: TextStyle(color: Colors.white),
                decoration: buildInputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter email' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: Colors.white),
                decoration: buildInputDecoration(
                  'Password',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.visibility, color: Colors.white),
                    onPressed: showPasswordTemporarily,
                    tooltip: 'Show password for 5 seconds',
                  ),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red[900],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        // decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
