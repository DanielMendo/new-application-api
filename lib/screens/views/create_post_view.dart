import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:new_application_api/services/toolbar_basic.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:new_application_api/screens/views/preview_post.view.dart';
import 'package:new_application_api/services/upload_image.dart';
import 'package:iconsax/iconsax.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostView();
}

class _CreatePostView extends State<CreatePostView> {
  final user = UserSession.currentUser;
  final token = UserSession.token!;

  String? imageUrl;

  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();

  Future<void> _handleAction(String action) async {
    if (!mounted) return;
    final selection = _controller.getSelectionStyle();

    switch (action) {
      case 'bold':
        final isBold = selection.attributes.containsKey(Attribute.bold.key);
        _controller.formatSelection(
            isBold ? Attribute.clone(Attribute.bold, null) : Attribute.bold);
        break;

      case 'italic':
        final isItalic = selection.attributes.containsKey(Attribute.italic.key);
        _controller.formatSelection(isItalic
            ? Attribute.clone(Attribute.italic, null)
            : Attribute.italic);
        break;

      case 'underline':
        final isUnderline =
            selection.attributes.containsKey(Attribute.underline.key);
        _controller.formatSelection(isUnderline
            ? Attribute.clone(Attribute.underline, null)
            : Attribute.underline);
        break;

      case 'link':
        String? text;
        String? url;

        await showDialog<void>(
          context: context,
          builder: (context) {
            final textController = TextEditingController();
            final urlController = TextEditingController();

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Insertar enlace',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Texto a mostrar",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          autofocus: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Link", style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                            hintText: 'https://...',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancelar',
                              style: TextStyle(color: Colors.grey[700])),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            text = textController.text.trim();
                            url = urlController.text.trim();
                            Navigator.of(context).pop();
                          },
                          child: Text('Aceptar',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );

        if (url != null &&
            url!.isNotEmpty &&
            text != null &&
            text!.isNotEmpty) {
          final index = _controller.selection.baseOffset;
          _controller.replaceText(index, 0, text!, null);
          _controller.formatText(index, text!.length, LinkAttribute(url!));
        }
        break;

      case 'quote':
        final isQuote =
            selection.attributes.containsKey(Attribute.blockQuote.key);
        _controller.formatSelection(isQuote
            ? Attribute.clone(Attribute.blockQuote, null)
            : Attribute.blockQuote);
        break;

      case 'list':
        final isList = selection.attributes.containsKey(Attribute.list.key);
        _controller.formatSelection(
            isList ? Attribute.clone(Attribute.list, null) : Attribute.ul);
        break;

      case 'image':
        await showDialog<void>(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              backgroundColor: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Añadir imagen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20),
                    _MinimalOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Tomar foto',
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? pickedFile =
                            await picker.pickImage(source: ImageSource.camera);

                        if (pickedFile == null) return;

                        final imageFile = File(pickedFile.path);

                        imageUrl =
                            await UploadImage().uploadImage(imageFile, token);

                        final index = _controller.selection.baseOffset;
                        _controller.replaceText(
                            index, 0, BlockEmbed.image(imageUrl!), null);

                        Navigator.of(context).pop();
                      },
                    ),
                    _MinimalOption(
                      icon: Icons.photo_outlined,
                      label: 'Seleccionar de galería',
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);

                        if (pickedFile == null) return;

                        final imageFile = File(pickedFile.path);

                        imageUrl =
                            await UploadImage().uploadImage(imageFile, token);

                        final index = _controller.selection.baseOffset;
                        _controller.replaceText(
                            index, 0, BlockEmbed.image(imageUrl!), null);

                        Navigator.of(context).pop();
                      },
                    ),
                    _MinimalOption(
                      icon: Icons.image_search_outlined,
                      label: 'Escoger de Unsplash',
                      onTap: () {
                        print('Abrir búsqueda de imágenes en Unsplash');
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );

        break;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final description = _controller.document.toPlainText().trim();
              final html = jsonEncode(_controller.document.toDelta().toJson());

              if (title.isNotEmpty && description.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewPostView(
                        title: title,
                        description: description,
                        image: imageUrl,
                        html: html),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'El título y el contenido no pueden estar vacíos')),
                );
              }
            },
            child: Text("Publicar", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: "Título",
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Expanded(
              child: QuillEditor(
                controller: _controller,
                scrollController: _scrollController,
                focusNode: _focusNode,
                config: QuillEditorConfig(
                    placeholder: 'Escribe aquí...',
                    enableInteractiveSelection: true,
                    embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders()),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomEditorToolbar(onAction: _handleAction),
    );
  }
}

class _MinimalOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MinimalOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
