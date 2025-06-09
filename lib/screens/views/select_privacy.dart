import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class SelectPrivacyView extends StatefulWidget {
  final bool? privacy;
  const SelectPrivacyView(this.privacy, {super.key});

  @override
  State<SelectPrivacyView> createState() => _SelectPrivacyViewState();
}

class _SelectPrivacyViewState extends State<SelectPrivacyView> {
  bool? privacy;

  @override
  void initState() {
    super.initState();
    privacy = widget.privacy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Iconsax.arrow_left, color: Colors.black),
            onPressed: () {
              context.pop(privacy);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Privacidad',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              '¿Quieres que tus posts sean públicos o privados? Esto te permite controlar quién puede ver tus publicaciones.',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const Text(
              "Modos de privacidad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                ListTile(
                  title: Text('Público'),
                  subtitle: Text(
                    'Todos pueden ver tus publicaciones',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: privacy == true ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      privacy = true;
                    });
                    context.pop(privacy);
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('Privado'),
                  subtitle: Text(
                    'Sólo tú puedes ver tus publicaciones',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: privacy == false ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      privacy = false;
                    });
                    context.pop(privacy);
                  },
                )
              ],
            )
          ]),
        ));
  }
}
