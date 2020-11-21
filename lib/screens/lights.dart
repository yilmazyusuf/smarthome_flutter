import 'package:flutter/material.dart';
import 'package:qubisch_home/api/light/Acuarium.dart';
import 'package:qubisch_home/api/light/Kubis.dart';
import 'package:qubisch_home/api/light/LivingRoomLeds.dart';
import 'package:qubisch_home/api/light/SleepingRoom.dart';

class LightsScreen extends StatefulWidget {
  @override
  _CurtainState createState() => _CurtainState();
}

class _CurtainState extends State<LightsScreen> {
  bool isSwitched = true;
  bool isSwitchedAc = true;
  bool isSwitchedKubis = true;
  bool isSwitchedSleeping = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IŞIKLAR"),
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OTURMA ODASI LED',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                    value: isSwitched,
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                        LivingRoomLeds room = LivingRoomLeds();
                        room.makeRequest();
                      });
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AKVARYUM',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                    value: isSwitchedAc,
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        isSwitchedAc = value;
                        Acuarium room = Acuarium();
                        room.makeRequest();
                      });
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KUBİŞ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                    value: isSwitchedKubis,
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        isSwitchedKubis = value;
                        Kubis room = Kubis();
                        room.makeRequest();
                      });
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YATAK ODASI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                    value: isSwitchedSleeping,
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        isSwitchedSleeping = value;
                        SleepingRoom room = SleepingRoom();
                        room.makeRequest();
                      });
                    }),
              ],
            ),


          ],

        ),

      ),
    );
  }
}
