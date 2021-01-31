import 'dart:async';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_sound/public/util/wave_header.dart';
import 'package:qubisch_home/api/humidity/LivingRoom.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:dio/dio.dart';

typedef _Fn = void Function();

class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String _mPath;
  Dio dio = new Dio();

  final LivingRoom livingRoom = LivingRoom();

  Socket socket;
  List<int> recordedData = [];

  Future<void> pcmToWaveXXXX({
    /// Stereophony is not yet implemented
    int numChannels = 1,
    int sampleRate = 16000,
  }) async {
    Directory directory = await getExternalStorageDirectory();
    String pathi = directory.path;
    Directory tempDir = await getExternalStorageDirectory();
    String inp = '${tempDir.path}/myFile.pcm';

    var filOut = File('$pathi/filename.wav');
    var filIn = File(inp);

    var size = filIn.lengthSync();
    Log.i(
        'pcmToWave() : input = $inp,  output = $pathi/filename.wav,  size = $size');
    var sink = filOut.openWrite();

    var header = WaveHeader(
      WaveHeader.formatPCM,
      numChannels = numChannels, //
      sampleRate = sampleRate,
      16, // 16 bits per byte
      size, // total number of bytes
    );
    header.write(sink);
    await filIn.open();
    var buffer = filIn.readAsBytesSync();
    sink.add(buffer.toList());
    await sink.close();
  }

  void socketSet(Socket _socket) {
    socket = _socket;
  }

  @override
  void initState() {
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    stopRecorder();
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    if (_mPath != null) {
      var outputFile = File(_mPath);
      if (outputFile.existsSync()) {
        outputFile.delete();
      }
    }

    super.dispose();
  }

  Future<void> openTheRecorder() async {
    var statusMic = await Permission.microphone.request();
    var statusStorage = await Permission.storage.request();
    if (statusMic != PermissionStatus.granted ||
        statusStorage != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    var tempDir = await getTemporaryDirectory();
    _mPath = '${tempDir.path}/flutter_sound_example.aac';
    var outputFile = File(_mPath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }

  Future<void> record() async {
    Directory tempDir = await getExternalStorageDirectory();
    String outputFile = '${tempDir.path}/myFile.pcm';

    assert(_mRecorderIsInited && _mPlayer.isStopped);
    await _mRecorder.startRecorder(
      codec: Codec.pcm16,
      toFile: outputFile,
      sampleRate: 16000,
      numChannels: 1,
    );
    setState(() {});
  }

  Future<void> stopRecorder() async {
    await _mRecorder.stopRecorder().whenComplete(() {
      Future cont = pcmToWaveXXXX();
      cont.whenComplete(() {
        sendToApi();
      });
    });
    _mplaybackReady = true;
  }

  void sendToApi() async {
    Directory directory = await getExternalStorageDirectory();
    String pathi = directory.path;
    var filOut = File('$pathi/filename.wav');
    final file = MultipartFile.fromBytes(filOut.readAsBytesSync(),
        filename: 'filename.wav');

    FormData formData = FormData.fromMap({"file": file});
    await dio.post("http://85.100.127.47:5000/stream", data: formData);
  }

  _Fn getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return null;
    }
    return _mRecorder.isStopped
        ? record
        : () {
            stopRecorder().then((value) => setState(() {}));
          };
  }

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
          title: const Text('Kubiş Akıllı Evim',
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
                                      'assets/images/home.png',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    child: Text('Güzel Evim',
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
              Row(
                children: [
                  Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Stack(
                            children: [
                              Container(
                                color: infoCardBg,
                                width: 170,
                                height: 150,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: DottedBorder(
                                      color: infoCardDashed,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: [5, 3],
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  alignment: Alignment.topRight,
                                                  width: 140,
                                                  height: 40,
                                                  child: Text(
                                                    'Sıcaklık',
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        color: pink),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  width: 110,
                                                  height: 90,
                                                  child: FutureBuilder<Curtain>(
                                                      future: livingRoom.makeRequest(),
                                                      builder: (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Text(
                                                          snapshot.data.temperature + '℃',
                                                          style: TextStyle(
                                                              fontSize: 35,
                                                              color: navBarColor),
                                                        );
                                                      }
                                                      else if (snapshot.hasError) {
                                                        return Text("${snapshot.error}");
                                                      }
                                                      return CircularProgressIndicator(
                                                          valueColor: new AlwaysStoppedAnimation<Color>(navBarColor)
                                                      );
                                                      }

                                                  )
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  width: 40,
                                                  height: 90,
                                                  child: Image.asset(
                                                    'assets/images/derece.png',
                                                    height: 50,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Stack(
                            children: [
                              Container(
                                color: infoCardBg,
                                width: 170,
                                height: 150,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: DottedBorder(
                                      color: infoCardDashed,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: [5, 3],
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  alignment: Alignment.topRight,
                                                  width: 140,
                                                  height: 40,
                                                  child: Text(
                                                    'Nem',
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        color: pink),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  width: 110,
                                                  height: 90,
                                                  child: FutureBuilder<Curtain>(
                                                      future: livingRoom.makeRequest(),
                                                      builder: (context, snapshot) {
                                                        if (snapshot.hasData) {
                                                          return Text(
                                                              snapshot.data.humidity + '%',
                                                            style: TextStyle(
                                                                fontSize: 35,
                                                                color: navBarColor),
                                                          );
                                                        }
                                                        else if (snapshot.hasError) {
                                                          return Text("${snapshot.error}");
                                                        }
                                                        return CircularProgressIndicator(
                                                            valueColor: new AlwaysStoppedAnimation<Color>(navBarColor)
                                                        );
                                                      }

                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  width: 40,
                                                  height: 90,
                                                  child: Image.asset(
                                                    'assets/images/nem.png',
                                                    height: 50,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          ))
                    ],
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 60, left: 10),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        child: RawMaterialButton(
                          onPressed: () {},
                          elevation: 0,
                          fillColor: mic_btn_shadow,
                          child: Container(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.mic,
                                size: 90.0,
                                color: Colors.white,
                              )),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 50),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        child: RawMaterialButton(
                          onPressed: getRecorderFn(),
                          elevation: 0,
                          fillColor: mic_btn,
                          child: Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: DottedDecoration(
                                shape: Shape.circle,
                                dash: <int>[10, 5],
                                color: Colors.white,
                              ),
                              child: Icon(
                                _mRecorder.isRecording  ? Icons.mic_off : Icons.mic,
                                size: 90.0,
                                color: Colors.white,
                              )),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(bottom: 20),
                    alignment: Alignment.center,
                    child: Text('Evine Mesaj Gönder',
                        style: TextStyle(color: navBarColor, fontSize: 30)),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 10, left: 10),
                            child: RawMaterialButton(
                              onPressed: () {},
                              elevation: 0,
                              fillColor: mic_btn_shadow,
                              child: Container(
                                width: 110,
                                height: 115,
                              ),
                              padding: EdgeInsets.all(15.0),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0),
                            child: RawMaterialButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/curtains');
                              },
                              elevation: 0,
                              fillColor: infoCardBg,
                              child: Container(
                                width: 110,
                                height: 115,
                                  decoration: DottedDecoration(
                                    shape: Shape.box,
                                    dash: <int>[10, 5],
                                    color: infoCardDashed,
                                  )
                                  ,child: Column(
                                children: [
                                  Text(
                                    'Perdeler',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20, color: pink),
                                  ),
                                  Image.asset(
                                    'assets/images/perde_yesil.png',
                                    height: 70,
                                  )
                                ],
                              ),
                              ),
                              padding: EdgeInsets.all(15.0),
                            ),

                          )
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 10, left: 10),
                            child: RawMaterialButton(
                              onPressed: () {},
                              elevation: 0,
                              fillColor: mic_btn_shadow,
                              child: Container(
                                width: 110,
                                height: 115,
                              ),
                              padding: EdgeInsets.all(15.0),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0),
                            child: RawMaterialButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/lights');
                              },
                              elevation: 0,
                              fillColor: infoCardBg,
                              child: Container(
                                width: 110,
                                height: 115,
                                decoration: DottedDecoration(
                                  shape: Shape.box,
                                  dash: <int>[10, 5],
                                  color: infoCardDashed,
                                )
                                ,child: Column(
                                children: [
                                  Text(
                                    'Işıklar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20, color: pink),
                                  ),
                                  Image.asset(
                                    'assets/images/isiklar.png',
                                    height: 70,
                                  )
                                ],
                              ),
                              ),
                              padding: EdgeInsets.all(15.0),
                            ),

                          )
                        ],
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}