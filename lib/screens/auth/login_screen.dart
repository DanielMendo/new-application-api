import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/services/auth/auth_service.dart';
import 'package:new_application_api/services/notification_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/widgets/social_auth_buttons.dart';
import 'package:new_application_api/services/auth/google_auth_service.dart';
import 'package:new_application_api/services/auth/fb_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      if (loginResponse.token != null) {
        // Guarda la sesión
        await UserSession.setSession(
          loginResponse.user!,
          loginResponse.token!,
          rememberMe: isChecking,
        );

        // Sube el token FCM
        await _uploadFcmTokenIfAvailable(loginResponse.token!);

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          context.go('/home');
        }
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
                  Text("Las credenciales no son correctas",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Por favor revisa tus credenciales",
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

      if (loginResponse.token != null) {
        // Guardar sesión
        await UserSession.setSession(
          loginResponse.user!,
          loginResponse.token!,
          rememberMe: true,
        );

        // Subir token FCM si existe
        await _uploadFcmTokenIfAvailable(loginResponse.token!);

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar loader
          context.go('/home'); // Redirigir a home
        }
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
                  Text("Error al iniciar sesión con Google",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Por favor revisa tu conexión a internet",
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

      if (loginResponse.token != null) {
        // Guardar sesión
        await UserSession.setSession(
          loginResponse.user!,
          loginResponse.token!,
          rememberMe: true,
        );

        // Subir token FCM si existe
        await _uploadFcmTokenIfAvailable(loginResponse.token!);

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar loader
          context.go('/home'); // Redirigir a home
        }
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
                  Text("Error al iniciar sesión con Facebook",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Por favor revisa tu conexión a internet",
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

  Future<void> _uploadFcmTokenIfAvailable(String authToken) async {
    final prefs = await SharedPreferences.getInstance();
    final fcmToken = prefs.getString('fcm_token');

    if (fcmToken != null) {
      await NotificationService().uploadDeviceToken(authToken, fcmToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
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
                        "Iniciar sesión",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Introduce tus datos para ingresar",
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
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Correo electrónico es requerido';
                          }
                          if (!value.contains('@')) {
                            return 'Correo electrónico no válido';
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
                            labelText: "Contraseña",
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
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
                              return "Por favor introduce una contraseña";
                            }
                            if (value.length < 6) {
                              return "La contraseña debe tener al menos 6 caracteres";
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
                                "Recordarme",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          // Forgot password
                          TextButton(
                            onPressed: () {
                              context.push('/forgot-password');
                            },
                            child: Text("¿Olvidaste tu contraseña?",
                                style: TextStyle(fontSize: 12)),
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
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Iniciar sesión",
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
                        Text("¿No tienes una cuenta? "),
                        GestureDetector(
                          onTap: () {
                            context.push('/register');
                          },
                          child: Text(
                            "Registrarse",
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
      ),
    );
  }
}
