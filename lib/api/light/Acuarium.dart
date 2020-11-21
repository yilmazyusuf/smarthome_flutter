import 'dart:convert';
import 'package:http/http.dart' as http;

class Acuarium {
  Future<Light> makeRequest() async {
    final http.Response response = await http.get(
        'http://85.100.127.47:5000/lights/aquarium',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 201) {
      return Light.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create album.');
    }
  }
}

class Light {
  final String status;

  Light({this.status});

  factory Light.fromJson(Map<String, dynamic> json) {
    return Light(status: json['status']);
  }


}
