import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomEditorToolbar extends StatelessWidget {
  final void Function(String action)? onAction;

  const CustomEditorToolbar({super.key, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _toolbarButton(icon: PhosphorIcons.textBolderBold, action: 'bold'),
          _toolbarButton(icon: PhosphorIcons.textItalic, action: 'italic'),
          _toolbarButton(icon: PhosphorIcons.textUnderline, action: 'underline'),
          _toolbarButton(icon: PhosphorIcons.textHOne, action: 'h1'),
          _toolbarButton(icon: PhosphorIcons.textHTwo, action: 'h2'),
          _toolbarButton(icon: PhosphorIcons.image, action: 'image'),
          _toolbarButton(icon: PhosphorIcons.quotes, action: 'quote'),
          _toolbarButton(icon: PhosphorIcons.link, action: 'link'),
          _toolbarButton(icon: PhosphorIcons.listBullets, action: 'ulist'),
          _toolbarButton(icon: PhosphorIcons.listNumbers, action: 'olist'),
          _toolbarButton(icon: PhosphorIcons.code, action: 'code'),
        ],
      ),
    );
  }

  Widget _toolbarButton({required IconData icon, required String action}) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: action.toUpperCase(),
      onPressed: () => onAction?.call(action),
    );
  }
}