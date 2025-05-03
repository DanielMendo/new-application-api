import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ActionHandler {
  final QuillController controller;
  final BuildContext context;

  ActionHandler({required this.controller, required this.context});

  Future<void> handleAction(String action) async {
    final selection = controller.getSelectionStyle();

    switch (action) {
      case 'bold':
        final isBold = selection.attributes.containsKey(Attribute.bold.key);
        controller.formatSelection(
            isBold ? Attribute.clone(Attribute.bold, null) : Attribute.bold);
        break;

      case 'italic':
        final isItalic = selection.attributes.containsKey(Attribute.italic.key);
        controller.formatSelection(isItalic
            ? Attribute.clone(Attribute.italic, null)
            : Attribute.italic);
        break;

      case 'underline':
        final isUnderline =
            selection.attributes.containsKey(Attribute.underline.key);
        controller.formatSelection(isUnderline
            ? Attribute.clone(Attribute.underline, null)
            : Attribute.underline);
        break;

      case 'link':
        await _showLinkDialog();
        break;

      case 'quote':
        final isQuote =
            selection.attributes.containsKey(Attribute.blockQuote.key);
        controller.formatSelection(isQuote
            ? Attribute.clone(Attribute.blockQuote, null)
            : Attribute.blockQuote);
        break;

      case 'list':
        final isList = selection.attributes.containsKey(Attribute.list.key);
        controller.formatSelection(
            isList ? Attribute.clone(Attribute.list, null) : Attribute.ul);
        break;

      case 'image':
        await _showImageDialog();
        break;
    }
  }

  Future<void> _showLinkDialog() async {
    String? text;
    String? url;

    await showDialog<void>(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        final urlController = TextEditingController();

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Insertar enlace',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(hintText: 'Texto a mostrar'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(hintText: 'https://...'),
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

    if (url != null && url!.isNotEmpty && text != null && text!.isNotEmpty) {
      final index = controller.selection.baseOffset;
      controller.replaceText(index, 0, text!, null);
      controller.formatText(index, text!.length, LinkAttribute(url!));
    }
  }

  Future<void> _showImageDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Añadir imagen',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 20),
                _ImageOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Tomar foto',
                  onTap: () async {
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      final imageUrl = pickedFile.path;
                      final index = controller.selection.baseOffset;
                      controller.replaceText(
                          index, 0, BlockEmbed.image(imageUrl), null);
                    }
                    Navigator.of(context).pop();
                  },
                ),
                _ImageOption(
                  icon: Icons.photo_outlined,
                  label: 'Seleccionar de galería',
                  onTap: () async {
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      final imageUrl = pickedFile.path;
                      final index = controller.selection.baseOffset;
                      controller.replaceText(
                          index, 0, BlockEmbed.image(imageUrl), null);
                    }
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar',
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImageOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageOption({
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
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
