import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyAPI {

  static const String _baseUrl = 'http://api.nstack.in/v1/todos';

  static Future<MyModel> getData(int id) async {
    final response = await http.post(Uri.parse('$_baseUrl/data/$id'));
    if (response.statusCode == 200) {
      return MyModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  // static Future<MyModel> getUpdate(int id) async {
  //   final response = await http.get(Uri.parse('$_baseUrl/data/$id'));
  //   if (response.statusCode == 200) {
  //     return MyModel.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }

}

class MyModel {
  final int id;
  final String name;

  MyModel({
    required this.id,
    required this.name,
  });

  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyModel>(
      future: MyAPI.getData(1),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.name);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
