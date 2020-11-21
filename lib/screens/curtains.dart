import 'package:flutter/material.dart';
import 'package:qubisch_home/api/curtain/LivingRoom.dart';

class CurtainsScreen extends StatefulWidget {
  @override
  _CurtainState createState() => _CurtainState();
}

class _CurtainState extends State<CurtainsScreen> {
  bool isSwitched = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PERDELER"),
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OTURMA ODASI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),Switch(
              value: isSwitched,
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
                onChanged: (value){
                  setState(() {
                    isSwitched=value;
                     LivingRoom room = LivingRoom();
                     room.makeRequest();

                  });
                }

            )


          ],
        ),
      ),
    );
  }
}
