import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomEditorToolbar extends StatelessWidget {
  final Function(String action) onAction;

  const CustomEditorToolbar({super.key, required this.onAction});

  Widget _toolbarButton({required IconData icon, required String action}) {
    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: () => onAction(action),
      tooltip: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _toolbarButton(icon: PhosphorIcons.textBolderBold, action: 'bold'),
            _toolbarButton(icon: PhosphorIcons.textItalic, action: 'italic'),
            _toolbarButton(
                icon: PhosphorIcons.textUnderline, action: 'underline'),
            _toolbarButton(icon: PhosphorIcons.link, action: 'link'),
            _toolbarButton(icon: PhosphorIcons.quotes, action: 'quote'),
            _toolbarButton(icon: PhosphorIcons.listBullets, action: 'list'),
            _toolbarButton(icon: PhosphorIcons.image, action: 'image'),
          ],
        ),
      ),
    );
  }
}
