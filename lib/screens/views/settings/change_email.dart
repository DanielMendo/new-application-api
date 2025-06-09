import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/services/auth/auth_service.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController currentEmailController;

  void _changeEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newEmail = _emailController.text;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final response =
            await AuthService().updateEmail(newEmail, UserSession.token!);

        if (mounted) Navigator.of(context, rootNavigator: true).pop();

        if (!mounted) return;

        if (response.success) {
          UserSession.currentUser =
              UserSession.currentUser!.copyWithEmail(newEmail);
          await UserSession.setSession(
              UserSession.currentUser!, UserSession.token!,
              rememberMe: true);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Row(
                children: [
                  Icon(Iconsax.message, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email actualizado",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
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

          if (!mounted) return;

          context.pop(UserSession.currentUser);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );
        }
      } catch (e) {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el email')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final user = UserSession.currentUser!;
    currentEmailController = TextEditingController(text: user.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Email actual'),
              _buildInput(currentEmailController, readOnly: true),
              const SizedBox(height: 24),
              _buildLabel('Nuevo Email'),
              _buildInput(_emailController, maxLength: 50, readOnly: false),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _changeEmail(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Guardar",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInput(
    controller, {
    int? maxLength,
    bool? readOnly,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
        readOnly: readOnly!,
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLength == 160 ? null : 1,
        minLines: maxLength == 160 ? 3 : 1,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
