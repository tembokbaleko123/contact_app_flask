import 'dart:convert';
import 'package:frontend/models/group.dart';
import 'package:http/http.dart' as http;
import '../models/person.dart';

class ApiServices {
  static const String baseUrl = 'http://127.0.0.1:5000';

  // GET all persons
  static Future<List<Person>> getAllPersons() async {
    final response = await http.get(Uri.parse('$baseUrl/persons'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => Person.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load persons');
    }
  }

  // POST: Create person
  static Future<bool> addPerson(Person person) async {
    final response = await http.post(
      Uri.parse('$baseUrl/persons'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(person.toJson()),
    );

    return response.statusCode == 201;
  }

  // PUT: Update person
  static Future<bool> updatePerson(int id, Person person) async {
    final response = await http.put(
      Uri.parse('$baseUrl/persons/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(person.toJson()),
    );

    return response.statusCode == 200;
  }

  // DELETE person
  static Future<bool> deletePerson(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/persons/$id'));
    return response.statusCode == 200;
  }

  // Mendapatkan semua isi kontak berdasarkan USER
  static Future<List<Person>> getAllPersonsByUser(int userId, {int? groupId}) async {
  String url = '$baseUrl/persons?user_id=$userId';
  if (groupId != null) {
    url += '&group_id=$groupId';
  }

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.map((e) => Person.fromJson(e)).toList();
  } else {
    throw Exception('Gagal memuat data');
  }
}


  // GET groups by user
  static Future<List<Group>> getAllGroupsByUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/groups?user_id=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Group.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat grup');
    }
  }

  // POST create group
  static Future<bool> addGroup(Group group) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(group.toJson()),
    );

    return response.statusCode == 201;
  }

  // PUT update group
  static Future<bool> updateGroup(int id, Group group) async {
    final response = await http.put(
      Uri.parse('$baseUrl/groups/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(group.toJson()),
    );

    return response.statusCode == 200;
  }

  // DELETE group
  static Future<bool> deleteGroup(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/groups/$id'));
    return response.statusCode == 200;
  }

}
