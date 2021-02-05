import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:qubisch_home/api/light/Acuarium.dart';
import 'package:qubisch_home/api/light/Kubis.dart';
import 'package:qubisch_home/api/light/LivingRoomAvize.dart';
import 'package:qubisch_home/api/light/LivingRoomLeds.dart';
import 'package:qubisch_home/api/light/SleepingRoom.dart';

class LightsScreen extends StatefulWidget {
  @override
  _CurtainState createState() => _CurtainState();
}

class _CurtainState extends State<LightsScreen> {
  bool isSwitched = true;
  bool isSwitchedAvize = true;
  bool isSwitchedAc = true;
  bool isSwitchedKubis = true;
  bool isSwitchedSleeping = true;

  Color navBarColor = const Color(0xFF669D89);
  static const navBarTextColor = const Color(0xFFfef4d4);
  Color subTitleColor = const Color(0xFFdec978);
  Color SubtitleDashed = const Color(0xFFcbb663);
  Color infoCardBg = const Color(0xFFfdebbd);
  Color infoCardDashed = const Color(0xFFd6d5be);
  Color pink = const Color(0xFFf27c7e);
  Color mic_btn = const Color(0xFFe0a81c);
  Color mic_btn_dashed = const Color(0xFFaa7d0d);
  Color mic_btn_shadow = const Color(0xFFefca74);
  Color disabled = const Color(0xFF987654);


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/body-pattern.jpg"),
            fit: BoxFit.none,
            repeat: ImageRepeat.repeat,
          )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Işıklar',
              style: TextStyle(color: navBarTextColor)),
          elevation: 0,
          backgroundColor: navBarColor,
        ),
          body: Container(
            child: Column(

              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: subTitleColor,
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.all(5),
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            child: DottedBorder(
                                color: SubtitleDashed,
                                strokeWidth: 2,
                                strokeCap: StrokeCap.butt,
                                dashPattern: [5, 3],
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: Image.asset(
                                        'assets/images/isiklar.png',
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.08,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Text('Işıklar',
                                          style: TextStyle(
                                              color: navBarColor, fontSize: 30)),
                                    )
                                  ],
                                ))),
                        Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 5, top: 0),
                          width: MediaQuery.of(context).size.width,
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                        )
                      ],
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Oturma Odası Led',
                            style: TextStyle(
                              color: navBarColor,
                              fontSize: 25
                            ),
                          ),

                          FlutterSwitch(
                            value: isSwitched,
                            width: 90.0,
                            height: 50.0,
                            toggleSize: 45.0,
                            borderRadius: 30.0,
                            padding: 2.0,
                            toggleColor: navBarTextColor,
                            switchBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            toggleBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            activeColor: infoCardBg,
                            inactiveColor: mic_btn_shadow,
                            //showOnOff: true,
                            activeIcon: Icon(
                              Icons.nightlight_round,
                              color: pink,
                            ),
                            inactiveIcon: Icon(
                              Icons.wb_sunny,
                              color: pink,
                            ),
                            onToggle: (value) {
                              setState(() {
                                isSwitched = value;
                                LivingRoomLeds room = LivingRoomLeds();
                                room.makeRequest();
                              });
                            },
                          )
                        ],
                      ),
                      Padding(padding: const EdgeInsets.only( top: 20),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Oturma Odası Avize',
                            style: TextStyle(
                                color: navBarColor,
                                fontSize: 25
                            ),
                          ),
                          FlutterSwitch(
                            value: isSwitchedAvize,
                            width: 90.0,
                            height: 50.0,
                            toggleSize: 45.0,
                            borderRadius: 30.0,
                            padding: 2.0,
                            toggleColor: navBarTextColor,
                            switchBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            toggleBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            activeColor: infoCardBg,
                            inactiveColor: mic_btn_shadow,
                            //showOnOff: true,
                            activeIcon: Icon(
                              Icons.nightlight_round,
                              color: pink,
                            ),
                            inactiveIcon: Icon(
                              Icons.wb_sunny,
                              color: pink,
                            ),
                            onToggle: (value) {
                              setState(() {
                                isSwitchedAvize = value;
                                LivingRoomAvize room = LivingRoomAvize();
                                room.makeRequest();
                              });
                            },
                          )

                        ],
                      ),
                      Padding(padding: const EdgeInsets.only( top: 20),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Akvaryum',
                            style: TextStyle(
                                color: navBarColor,
                                fontSize: 25
                            ),
                          ),
                          FlutterSwitch(
                            value: isSwitchedAc,
                            width: 90.0,
                            height: 50.0,
                            toggleSize: 45.0,
                            borderRadius: 30.0,
                            padding: 2.0,
                            toggleColor: navBarTextColor,
                            switchBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            toggleBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            activeColor: infoCardBg,
                            inactiveColor: mic_btn_shadow,
                            //showOnOff: true,
                            activeIcon: Icon(
                              Icons.nightlight_round,
                              color: pink,
                            ),
                            inactiveIcon: Icon(
                              Icons.wb_sunny,
                              color: pink,
                            ),
                            onToggle: (value) {
                              setState(() {
                                isSwitchedAc = value;
                                Acuarium room = Acuarium();
                                room.makeRequest();
                              });
                            },
                          )
                        ],
                      ),
                      Padding(padding: const EdgeInsets.only( top: 20),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kubiş',
                            style: TextStyle(
                                color: navBarColor,
                                fontSize: 25
                            ),
                          ),
                          FlutterSwitch(
                            value: isSwitchedKubis,
                            width: 90.0,
                            height: 50.0,
                            toggleSize: 45.0,
                            borderRadius: 30.0,
                            padding: 2.0,
                            toggleColor: navBarTextColor,
                            switchBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            toggleBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            activeColor: infoCardBg,
                            inactiveColor: mic_btn_shadow,
                            //showOnOff: true,
                            activeIcon: Icon(
                              Icons.nightlight_round,
                              color: pink,
                            ),
                            inactiveIcon: Icon(
                              Icons.wb_sunny,
                              color: pink,
                            ),
                            onToggle: (value) {
                              setState(() {
                                isSwitchedKubis = value;
                                Kubis room = Kubis();
                                room.makeRequest();
                              });
                            },
                          ),
                        ],
                      ),
                      Padding(padding: const EdgeInsets.only( top: 20),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Yatak Odası',
                            style: TextStyle(
                                color: navBarColor,
                                fontSize: 25
                            ),
                          ),
                          FlutterSwitch(
                            value: isSwitchedSleeping,
                            width: 90.0,
                            height: 50.0,
                            toggleSize: 45.0,
                            borderRadius: 30.0,
                            padding: 2.0,
                            toggleColor: navBarTextColor,
                            switchBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            toggleBorder: Border.all(
                              color: mic_btn,
                              width: 2.0,
                            ),
                            activeColor: infoCardBg,
                            inactiveColor: mic_btn_shadow,
                            //showOnOff: true,
                            activeIcon: Icon(
                              Icons.nightlight_round,
                              color: pink,
                            ),
                            inactiveIcon: Icon(
                              Icons.wb_sunny,
                              color: pink,
                            ),
                            onToggle: (value) {
                              setState(() {
                                isSwitchedSleeping = value;
                                SleepingRoom room = SleepingRoom();
                                room.makeRequest();
                              });
                            },
                          )
                        ],
                      ),

                    ],
                  ),
                )



              ],

            ),

          )
      ),

    );
  }
}
