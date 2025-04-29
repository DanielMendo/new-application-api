import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del perfil
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/posts/avatar.png'),
                  radius: 38,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'J Daniel M Mendoza',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '2.5k Followers',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 18),
                          Text(
                            '2.5k Following',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TabBar
          TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 1,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'Posts'),
              Tab(text: 'About'),
            ],
          ),

          // TabBarView (contenido de pestañas)
          Expanded(
            child: TabBarView(
              children: [
                /// --- Pestaña de Posts (usando ListView para poder hacer scroll y ocupar espacio) ---
                ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/posts/avatar.png'),
                                    radius: 8,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'J Daniel M Mendoza',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'DTO vs Resource in Laravel: What’s the Difference and When to Use Each',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'In Laravel applications, managing how data enters and exits your app is crucial...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '2d ago',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Icon(Icons.visibility,
                                      size: 14, color: Colors.grey[500]),
                                  SizedBox(width: 4),
                                  Text(
                                    '5',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        // Imagen del post
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/posts/wather.jpg',
                              fit: BoxFit.cover,
                              height: 100,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: Colors.grey.shade200),

                    // Aquí podrías agregar más posts si quieres
                  ],
                ),

                /// --- Pestaña About (otra cosa) ---
                Center(
                  child: Text(
                    'Otra cosa',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
