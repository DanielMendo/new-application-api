import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "For you",
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              )),
          SizedBox(height: 10),

          /// --- [Posts] --- ///
          Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.asset(
                      "assets/posts/wather.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/posts/avatar.png'),
                              radius: 13,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "John Doe",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Emilio Azcarraga ah hecho blablabla",
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              "12 min ago",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(width: 30),
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.heartFill,
                                  color: Colors.grey.shade600,
                                  size: 14,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "0",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.chatFill,
                                  color: Colors.grey.shade600,
                                  size: 14,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "1",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
