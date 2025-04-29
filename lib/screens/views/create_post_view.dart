import 'package:flutter/material.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  CreatePostViewState createState() => CreatePostViewState();
}

class CreatePostViewState extends State<CreatePostView> {
  final TextEditingController _titleCtrl = TextEditingController();
  final quill.QuillController _controller = quill.QuillController.basic();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  // void _submit() {
  //   final titulo = _titleCtrl.text.trim();
  //   final delta = _controller.document.toDelta();
  //   final contenidoJson = jsonEncode(delta.toJson());
  //   // Documento enriquecido en formato Delta → JSON
  //   print('Título: $titulo');
  //   print('Contenido (Delta JSON): $contenidoJson');
  //   // Aquí llamas a tu API enviando: titulo, contenidoJson, etc.
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Share with us",
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final titulo = _titleCtrl.text.trim();
                  debugPrint('Título: $titulo');
                },
                child: Text('Publicar'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/posts/avatar.png'),
                radius: 35,
              ),
              SizedBox(width: 35),
              Expanded(
                child: Text(
                  '${UserSession.currentUser?.name}',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Debes escribir un título';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: 100, // altura fija
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: quill.QuillSimpleToolbar(
                  controller: _controller,

                  // única fila
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: quill.QuillEditor(
                  controller: _controller,
                  scrollController: ScrollController(),
                  focusNode: FocusNode(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
