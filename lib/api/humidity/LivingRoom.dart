import 'dart:convert';
import 'package:http/http.dart' as http;

class LivingRoom {
  Future<Curtain> makeRequest() async {
    final http.Response response = await http.get(
        'http://85.100.127.47:5000/humidity',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 200) {
      return Curtain.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create album.');
    }
  }
}

class Curtain {
  final String humidity;
  final String temperature;

  Curtain({this.humidity,this.temperature});

  factory Curtain.fromJson(Map<String, dynamic> json) {
    return Curtain(humidity: json['humidity'],temperature: json['temperature']);
  }


}
