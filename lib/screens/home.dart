import 'dart:async';
import 'dart:convert';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navBarTextColor,
      appBar: AppBar(
        title: const Text('Kubiş Akıllı Evim',
            style: TextStyle(color: navBarTextColor)),
        elevation: 0,
        backgroundColor: navBarColor,
      ),
      body: Row(children: [
        Container(

            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 5,top: 5),
            height: MediaQuery.of(context).size.height * 0.1,
            width:  MediaQuery.of(context).size.width,
            child: Container(
              transform: Matrix4.translationValues(0.0, 0, 0.0),
              child: Image.asset('assets/images/logo.png'),
            ),
            decoration: BoxDecoration(
              color: subTitleColor,
            ),


        ),
        Container(
          child: Row(
            children: [],
          ),
        )
      ],


      ),
    );
  }
}

/*
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
                            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)
                        ),
                        Text(
                          snapshot.data.temperature + '℃',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30


                          ),
                        )
                      ],
                    ),
                    Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [

                        Text(
                            'Nem',
                            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)

                        ),
                        Text(
                          snapshot.data.humidity + '%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                              fontSize: 30
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          padding: EdgeInsets.only(top: 50.0),
                          iconSize: 150,
                          icon: Icon(_mRecorder.isRecording  ? Icons.mic_off : Icons.mic),
                          onPressed: getRecorderFn(),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          )),
 */
