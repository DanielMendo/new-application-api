import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/models/category.dart';
import 'package:new_application_api/models/post.dart';
import 'package:new_application_api/services/toolbar_basic.dart';
import 'package:new_application_api/utils/image_compressed.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/services/upload_image.dart';
import 'package:new_application_api/widgets/minimal_option.dart';

class EditPostView extends StatefulWidget {
  final Post post;
  final Category selectedCategory;
  const EditPostView(
      {super.key, required this.post, required this.selectedCategory});

  @override
  State<EditPostView> createState() => _EditPostView();
}

class _EditPostView extends State<EditPostView> {
  final user = UserSession.currentUser;
  final token = UserSession.token!;

  List<String> imageUrls = [];
  String? currentThumbnailUrl;

  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title;
    currentThumbnailUrl = widget.post.image;
    imageUrls = widget.post.allImages ?? [];
    _initializeQuillContent();
  }

  void _initializeQuillContent() {
    try {
      if (widget.post.html.isNotEmpty) {
        final deltaJson = jsonDecode(widget.post.html);
        final Delta delta = Delta.fromJson(deltaJson);
        _controller.document = Document.fromDelta(delta);
      }
    } catch (e) {
      _controller.document = Document();
    }
  }

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
                    MinimalOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Tomar foto',
                      onTap: () async {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (pickedFile == null) return;

                        final compressedFile = await ImageCompressed()
                            .compressImage(File(pickedFile.path));
                        if (compressedFile == null) return;

                        final uploadedImageUrl = await UploadImage()
                            .uploadImage(File(compressedFile.path), token);

                        setState(() {
                          imageUrls.add(uploadedImageUrl);
                        });

                        final index = _controller.selection.baseOffset;

                        _controller.replaceText(
                            index, 0, BlockEmbed.image(uploadedImageUrl), null);

                        Navigator.of(context).pop();
                      },
                    ),
                    MinimalOption(
                      icon: Icons.photo_outlined,
                      label: 'Seleccionar de galería',
                      onTap: () async {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile == null) return;

                        final compressedFile = await ImageCompressed()
                            .compressImage(File(pickedFile.path));
                        if (compressedFile == null) return;

                        final uploadedImageUrl = await UploadImage()
                            .uploadImage(File(compressedFile.path), token);

                        setState(() {
                          imageUrls.add(uploadedImageUrl);
                        });

                        final index = _controller.selection.baseOffset;

                        _controller.replaceText(
                            index, 0, BlockEmbed.image(uploadedImageUrl), null);
                        Navigator.of(context).pop();
                      },
                    ),
                    MinimalOption(
                      icon: Icons.image_search_outlined,
                      label: 'Escoger de Unsplash',
                      onTap: () {
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
            context.pop();
          },
        ),
        title:
            Text('Editar publicación', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              String getPlainText(QuillController controller) {
                final delta = controller.document.toDelta();
                if (delta.isEmpty) return '';
                String plainText = '';
                for (var operation in delta.toList()) {
                  if (operation.isInsert && operation.data is String) {
                    plainText += operation.data as String;
                  }
                }
                return plainText.trim();
              }

              final title = _titleController.text.trim();
              final description = getPlainText(_controller);
              final html = jsonEncode(_controller.document.toDelta().toJson());

              if (title.isNotEmpty && description.isNotEmpty) {
                context.push('/preview-post', extra: {
                  'isEditing': true,
                  'postId': widget.post.id,
                  'title': title,
                  'description': description,
                  'image': currentThumbnailUrl,
                  'allImages': imageUrls,
                  'html': html,
                  'privacy': widget.post.isPublished == 1,
                  'category': widget.selectedCategory,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('El título y el contenido no pueden estar vacíos'),
                  ),
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
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: -0.5,
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
                  embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      GoogleFonts.merriweather(
                        fontSize: 18.0,
                        color: Colors.black87,
                        height: 1.8,
                        fontWeight: FontWeight.w400,
                      ),
                      HorizontalSpacing(8.0, 8.0),
                      VerticalSpacing(0.0, 0.0),
                      VerticalSpacing(0.0, 0.0),
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CustomEditorToolbar(
          controller: _controller,
          onAction: _handleAction,
        ),
      ),
    );
  }
}
