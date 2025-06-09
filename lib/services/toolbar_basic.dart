import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomEditorToolbar extends StatelessWidget {
  final QuillController controller;
  final Function(String action) onAction;

  const CustomEditorToolbar({
    super.key,
    required this.controller,
    required this.onAction,
  });

  Widget _toolbarButton({
    required IconData icon,
    required String action,
    required IconData activeIcon,
    required bool isActive,
  }) {
    return IconButton(
      icon: Icon(
        isActive ? activeIcon : icon,
        size: 22,
      ),
      onPressed: () => onAction(action),
      tooltip: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final attributes = controller.getSelectionStyle().attributes;
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
                _toolbarButton(
                  icon: PhosphorIcons.textBolder,
                  activeIcon: PhosphorIcons.textBolderBold,
                  action: 'bold',
                  isActive: attributes.containsKey(Attribute.bold.key),
                ),
                _toolbarButton(
                  icon: PhosphorIcons.textItalic,
                  activeIcon: PhosphorIcons.textItalicBold,
                  action: 'italic',
                  isActive: attributes.containsKey(Attribute.italic.key),
                ),
                _toolbarButton(
                  icon: PhosphorIcons.textUnderline,
                  activeIcon: PhosphorIcons.textUnderlineBold,
                  action: 'underline',
                  isActive: attributes.containsKey(Attribute.underline.key),
                ),
                _toolbarButton(
                  icon: PhosphorIcons.link,
                  activeIcon: PhosphorIcons.linkBold,
                  action: 'link',
                  isActive: attributes.containsKey(Attribute.link.key),
                ),
                _toolbarButton(
                  icon: PhosphorIcons.quotes,
                  activeIcon: PhosphorIcons.quotesBold,
                  action: 'quote',
                  isActive: attributes.containsKey(Attribute.blockQuote.key),
                ),
                _toolbarButton(
                  icon: PhosphorIcons.listBullets,
                  activeIcon: PhosphorIcons.listBulletsBold,
                  action: 'list',
                  isActive: attributes.containsKey(Attribute.list.key),
                ),
                _toolbarButton(
                  icon: PhosphorIcons.image,
                  activeIcon: PhosphorIcons.imageBold,
                  action: 'image',
                  isActive: attributes.containsKey(Attribute.image.key),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
