import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
import 'package:new_application_api/utils/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_application_api/config.dart';
import 'package:new_application_api/services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final baseUrl = AppConfig.baseStorageUrl;

  late TextEditingController nameController;
  late TextEditingController lastNameController;
  late TextEditingController bioController;
  String? profileImagePath;
  XFile? _tempPickedFile;

  @override
  void initState() {
    super.initState();
    final user = UserSession.currentUser!;
    nameController = TextEditingController(text: user.name);
    lastNameController = TextEditingController(text: user.lastName);
    bioController = TextEditingController(text: user.bio ?? "No hay biografía");
    profileImagePath = user.profileImage;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _tempPickedFile = pickedFile;
      });
    }
  }

  Future<void> _saveChanges() async {
    final currentUser = UserSession.currentUser!;

    final hasNameChanged = nameController.text != currentUser.name;
    final hasLastNameChanged = lastNameController.text != currentUser.lastName;
    final hasBioChanged =
        bioController.text != (currentUser.bio ?? "No hay biografía");
    final hasImageChanged = _tempPickedFile != null;

    if (!hasNameChanged &&
        !hasLastNameChanged &&
        !hasBioChanged &&
        !hasImageChanged) {
      context.pop(false);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? uploadedImageUrl = profileImagePath;

      if (hasImageChanged) {
        final imageFile = File(_tempPickedFile!.path);
        uploadedImageUrl =
            await UserService().uploadImage(imageFile, UserSession.token!);
      }

      final updatedUser = currentUser.copyWithProfile(
        name: nameController.text,
        lastName: lastNameController.text,
        bio: bioController.text,
        profileImage: uploadedImageUrl,
      );

      await UserService().updateProfile(updatedUser, UserSession.token!);

      UserSession.currentUser = updatedUser;
      await UserSession.setSession(updatedUser, UserSession.token!,
          rememberMe: true);

      if (!mounted) return;

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      context.pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            children: [
              Icon(Iconsax.like, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Perfil actualizado",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Perfil actualizado con éxito",
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
                  Text("Error al actualizar el perfil",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Por favor, revisa tu conexión a internet",
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
    final imageProvider = _tempPickedFile != null
        ? FileImage(File(_tempPickedFile!.path)) as ImageProvider
        : profileImagePath != null
            ? NetworkImage('$baseUrl/$profileImagePath')
            : const AssetImage('assets/posts/avatar.png') as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar perfil"),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () {
            context.pop(false);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text("Guardar"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: imageProvider,
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    child: Text(
                      "Seleccionar imagen",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildLabel("Nombre"),
            _buildInput(nameController, maxLength: 50),
            const SizedBox(height: 24),
            _buildLabel("Apellido"),
            _buildInput(lastNameController, maxLength: 50),
            const SizedBox(height: 24),
            _buildLabel("Biografía"),
            _buildInput(bioController, maxLength: 160),
            const SizedBox(height: 24),
          ],
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

  Widget _buildInput(TextEditingController controller, {int? maxLength}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
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
