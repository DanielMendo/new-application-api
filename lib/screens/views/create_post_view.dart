import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

void main() => runApp(MaterialApp(home: CreatePostView()));

class CreatePostView extends StatefulWidget {
  @override
  State<CreatePostView> createState() => _CreatePostView();
}

class _CreatePostView extends State<CreatePostView> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  void _handleAction(String action) {
    switch (action) {
      case 'bold':
        _controller.formatSelection(Attribute.bold);
        break;
      case 'italic':
        _controller.formatSelection(Attribute.italic);
        break;
      case 'underline':
        _controller.formatSelection(Attribute.underline);
        break;
      case 'clear':
        _controller.clear();
        break;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editor con Toolbar')),
      body: Column(
        children: [
          CustomEditorToolbar(onAction: _handleAction),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              child: QuillEditor(
                controller: _controller,
                scrollController: _scrollController,
               
                focusNode: _focusNode,
               
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomEditorToolbar extends StatelessWidget {
  final Function(String action) onAction;

  const CustomEditorToolbar({Key? key, required this.onAction}) : super(key: key);

  Widget _toolbarButton({required IconData icon, required String action}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () => onAction(action),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _toolbarButton(icon: Icons.format_bold, action: 'bold'),
        _toolbarButton(icon: Icons.format_italic, action: 'italic'),
        _toolbarButton(icon: Icons.format_underline, action: 'underline'),
        _toolbarButton(icon: Icons.clear, action: 'clear'),
      ],
    );
  }
}
