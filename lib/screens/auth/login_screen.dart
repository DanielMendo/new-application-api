import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/screens/auth/forgot_screen.dart';
import 'package:new_application_api/screens/home/home_screen.dart';
import 'package:new_application_api/screens/auth/signup_screen.dart';
import 'package:new_application_api/services/auth/auth_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/widgets/social_auth_buttons.dart';
import 'package:new_application_api/services/auth/google_auth_service.dart';
import 'package:new_application_api/services/auth/fb_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isPasswordHidden = true;
  bool isChecking = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      final loginResponse = await AuthService()
          .login(_emailController.text.trim(), _passwordController.text.trim());

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;

      if (loginResponse.token != null) {
        UserSession.setSession(loginResponse.user!, loginResponse.token!,
            rememberMe: isChecking);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: [
              Icon(Iconsax.danger, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Invalid credentials",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Please check your credentials",
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
            ],
          ),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(12),
        ),
      );
    }
  }

  void _signInWithGoogle() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
    try {
      final loginResponse = await GoogleAuthService().signInWithGoogle();

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;

      if (loginResponse.token != null) {
        UserSession.setSession(loginResponse.user!, loginResponse.token!,
            rememberMe: true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: [
              Icon(Iconsax.direct_send, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Error signing with google",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Please check your internet connection",
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
            ],
          ),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(12),
        ),
      );
    }
  }

  void _signInWithFb() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
    try {
      final loginResponse = await FbAuthService().signInWithFb();

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;

      if (loginResponse.token != null) {
        UserSession.setSession(loginResponse.user!, loginResponse.token!,
            rememberMe: true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: [
              Icon(Iconsax.direct_send, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Error signing with facebook",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Please check your internet connection",
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
            ],
          ),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// --- [Header] --- ///
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Enter details to use de appp",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),

                /// --- [Form] --- ///
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        prefixIcon: Icon(Iconsax.direct_right,
                            color: Colors.grey.shade600, size: 20),
                        labelText: "Email",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Email is invalid';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Password
                    TextFormField(
                        controller: _passwordController,
                        obscureText: isPasswordHidden,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                          prefixIcon: Icon(Iconsax.password_check,
                              color: Colors.grey.shade600, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordHidden
                                  ? Iconsax.eye
                                  : Iconsax.eye_slash,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordHidden = !isPasswordHidden;
                              });
                            },
                          ),
                          labelText: "Password",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        }),
                    SizedBox(height: 15),

                    // Remember me & forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember me
                        Row(
                          children: [
                            Checkbox(
                              value: isChecking,
                              onChanged: (value) {
                                setState(() {
                                  isChecking = value!;
                                });
                              },
                            ),
                            Text(
                              "Remember me",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        // Forgot password
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotScreen()),
                            );
                          },
                          child: Text("Forgot password?"),
                        )
                      ],
                    ),
                    SizedBox(height: 40),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _login(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                SocialAuthButtons(
                  onGoogleTap: () => _signInWithGoogle(),
                  onFacebookTap: () => _signInWithFb(),
                ),

                SizedBox(height: 30),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
