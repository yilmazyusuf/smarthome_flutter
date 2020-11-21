import 'dart:convert';
import 'package:http/http.dart' as http;

class LivingRoom {
  Future<Curtain> makeRequest() async {
    final http.Response response = await http.get(
        'http://85.100.127.47:5000/curtains/living_room',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 201) {
      return Curtain.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create album.');
    }
  }
}

class Curtain {
  final String status;

  Curtain({this.status});

  factory Curtain.fromJson(Map<String, dynamic> json) {
    return Curtain(status: json['status']);
  }


}
