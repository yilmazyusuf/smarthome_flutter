import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qubisch_home/api/humidity/LivingRoom.dart';
import 'package:sound_stream/sound_stream.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';

typedef _Fn = void Function();

class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  RecorderStream _recorder = RecorderStream();
  PlayerStream _player = PlayerStream();
  List<Uint8List> _micChunks = [];
  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription _recorderStatus;
  StreamSubscription _playerStatus;
  StreamSubscription _audioStream;

  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String _mPath;

  final LivingRoom livingRoom = LivingRoom();

  Socket socket;
  List<int> recordedData = [];

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
    //initPlugin();
    //requestWritePermission();
    //initSocket();
  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _playerStatus?.cancel();
    _audioStream?.cancel();

    stopPlayer();
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
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
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
    await _mRecorder.stopRecorder();
    _mplaybackReady = true;
  }

  void play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);

    Directory tempDir = await getExternalStorageDirectory();
    String outputFile = '${tempDir.path}/myFile.pcm';
    print("dosya:"+outputFile);

    await _mPlayer.startPlayer(
        fromURI: outputFile,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate:16000,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  Future<void> stopPlayer() async {
    await _mPlayer.stopPlayer();
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

  _Fn getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return null;
    }
    return _mPlayer.isStopped
        ? play
        : () {
            stopPlayer().then((value) => setState(() {}));
          };
  }

  requestWritePermission() async {
    var status = await Permission.storage.status;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  void initSocket() async {
    await Socket.connect("192.168.1.8", 48748).then((Socket sock) {
      socket = sock;
      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
      socketSet(socket);
    }).catchError((AsyncError e) {
      print("Unable to connect: $e");
    });

    //Connect standard in to the socket
    stdin.listen(
        (data) => socket.write(new String.fromCharCodes(data).trim() + '\n'));
  }

  void dataHandler(data) {
    print(new String.fromCharCodes(data).trim());
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    socket.destroy();
  }

  Future<void> initPlugin() async {
    _recorderStatus = _recorder.status.listen((status) {
      if (mounted)
        setState(() {
          _isRecording = status == SoundStreamStatus.Playing;
        });
    });

    _audioStream = _recorder.audioStream.listen((data) {
      if (_isPlaying) {
        _player.writeChunk(data);
      } else {
        socket.add(data);

        //recordedData.addAll(data);
        _micChunks.add(data);
      }
    });

    _playerStatus = _player.status.listen((status) {
      if (mounted)
        setState(() {
          _isPlaying = status == SoundStreamStatus.Playing;
        });
    });

    await Future.wait([
      _recorder.initialize(),
      _player.initialize(),
    ]);
  }

  void _play() async {
    await _player.start();

    if (_micChunks.isNotEmpty) {
      for (var chunk in _micChunks) {
        await _player.writeChunk(chunk);
      }
      //print('dosya');
      //await save(recordedData, 44100);

      _micChunks.clear();
    }
  }

  Future<void> save(List<int> data, int sampleRate) async {
    final path = await _localPath;
    File recordedFile = File('$path/recordedFile.wav');
    print(recordedFile);

    var channels = 1;

    int byteRate = ((16 * sampleRate * channels) / 8).round();

    var size = data.length;

    var fileSize = size + 36;

    Uint8List header = Uint8List.fromList([
      // "RIFF"
      82, 73, 70, 70,
      fileSize & 0xff,
      (fileSize >> 8) & 0xff,
      (fileSize >> 16) & 0xff,
      (fileSize >> 24) & 0xff,
      // WAVE
      87, 65, 86, 69,
      // fmt
      102, 109, 116, 32,
      // fmt chunk size 16
      16, 0, 0, 0,
      // Type of format
      1, 0,
      // One channel
      channels, 0,
      // Sample rate
      sampleRate & 0xff,
      (sampleRate >> 8) & 0xff,
      (sampleRate >> 16) & 0xff,
      (sampleRate >> 24) & 0xff,
      // Byte rate
      byteRate & 0xff,
      (byteRate >> 8) & 0xff,
      (byteRate >> 16) & 0xff,
      (byteRate >> 24) & 0xff,
      // Uhm
      ((16 * channels) / 8).round(), 0,
      // bitsize
      16, 0,
      // "data"
      100, 97, 116, 97,
      size & 0xff,
      (size >> 8) & 0xff,
      (size >> 16) & 0xff,
      (size >> 24) & 0xff,
      ...data
    ]);

    return recordedFile.writeAsBytes(header, flush: true);
  }

  TextEditingController _controller = TextEditingController();

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
                          snapshot.data.temperature + ' *C',
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          iconSize: 96.0,
                          icon: Icon(_isRecording ? Icons.mic_off : Icons.mic),
                          onPressed:
                              _isRecording ? _recorder.stop : _recorder.start,
                        ),
                        IconButton(
                          iconSize: 96.0,
                          icon:
                              Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: _isPlaying ? _player.stop : _play,
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(3),
                      height: 80,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFFAF0E6),
                        border: Border.all(
                          color: Colors.indigo,
                          width: 3,
                        ),
                      ),
                      child: Row(children: [
                        RaisedButton(
                          onPressed: getRecorderFn(),
                          color: Colors.white,
                          disabledColor: Colors.grey,
                          child:
                              Text(_mRecorder.isRecording ? 'Stop' : 'Record'),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(_mRecorder.isRecording
                            ? 'Recording in progress'
                            : 'Recorder is stopped'),
                      ]),
                    ),
                    Container(
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(3),
                      height: 80,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFFAF0E6),
                        border: Border.all(
                          color: Colors.indigo,
                          width: 3,
                        ),
                      ),
                      child: Row(children: [
                        RaisedButton(
                          onPressed: getPlaybackFn(),
                          color: Colors.white,
                          disabledColor: Colors.grey,
                          child: Text(_mPlayer.isPlaying ? 'Stop' : 'Play'),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(_mPlayer.isPlaying
                            ? 'Playback in progress'
                            : 'Player is stopped'),
                      ]),
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
