import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qubisch_home/api/humidity/LivingRoom.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final LivingRoom livingRoom = LivingRoom();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kubiş Akıllı Evim')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  color: Colors.blue,
                  image: DecorationImage(
                      image: AssetImage("assets/web_hi_res_512.png"),
                      fit: BoxFit.cover)),
              child: Text(
                'Güzel Evim',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
                leading: Icon(
                  Icons.wb_sunny_rounded,
                ),
                title: Text('Perdeler'),
                onTap: () {
                  Navigator.pushNamed(context, '/curtains');
                }),
            ListTile(
                leading: Icon(
                  Icons.wb_incandescent,
                ),
                title: Text('Işıklar'),
                onTap: () {
                  Navigator.pushNamed(context, '/lights');
                })
          ],
        ),
      ),
      body: Container(
          padding: const EdgeInsets.all(32),
          child: FutureBuilder<Curtain>(
            future: livingRoom.makeRequest(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sıcaklık',
                        ),
                        Text(
                          snapshot.data.temperature + ' °C',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nem'),
                        Text(
                          snapshot.data.humidity + '%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          )),
    );
  }
}
