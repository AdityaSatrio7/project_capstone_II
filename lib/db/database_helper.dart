import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/game_model.dart';
import '../model/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // 10.0.2.2 is the special IP for 'localhost' when using the Android Emulator.
  static const String baseUrl = "http://10.0.2.2/perpusgaming_api";

  // AUTH: Register
  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: {'username': username, 'password': password},
      );
      
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Error ${response.statusCode}"
        };
      }
    } catch (e) {
      print("Register error: $e");
    }
    return {"success": false, "message": "Connection error"};
  }

  // AUTH: Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Login error: $e");
    }
    return {"success": false, "message": "Connection error"};
  }

  // CREATE
  Future<int> insertGame(Game game) async {
    if (game.userId == null) return 0;
    final response = await http.post(
      Uri.parse('$baseUrl/add_game.php'),
      body: {
        'user_id': game.userId.toString(),
        'title': game.title,
        'genre': game.genre,
        'platform': game.platform,
        'status': game.status,
        'coverUrl': game.coverUrl,
      },
    );
    if (response.statusCode == 200) {
      return int.tryParse(response.body) ?? 0;
    }
    return 0;
  }

  // READ (Filtered by User)
  Future<List<Game>> getGames(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_games.php?user_id=$userId'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Game.fromMap(e)).toList();
      }
    } catch (e) {
      print("Error fetching games: $e");
    }
    return [];
  }

  // READ (Search Filtered by User)
  Future<List<Game>> searchGames(int userId, String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search_games.php?user_id=$userId&query=${Uri.encodeComponent(query)}'),
      );
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Game.fromMap(e)).toList();
      }
    } catch (e) {
      print("Error searching games: $e");
    }
    return [];
  }

  // UPDATE
  Future<int> updateGame(Game game) async {
    if (game.id == null || game.userId == null) return 0;
    final response = await http.post(
      Uri.parse('$baseUrl/update_game.php'),
      body: {
        'id': game.id.toString(),
        'user_id': game.userId.toString(),
        'title': game.title,
        'genre': game.genre,
        'platform': game.platform,
        'status': game.status,
        'coverUrl': game.coverUrl,
      },
    );
    if (response.statusCode == 200) {
      return int.tryParse(response.body) ?? 0;
    }
    return 0;
  }

  // DELETE
  Future<int> deleteGame(int gameId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_game.php'),
      body: {
        'id': gameId.toString(),
        'user_id': userId.toString(),
      },
    );
    if (response.statusCode == 200) {
      return int.tryParse(response.body) ?? 0;
    }
    return 0;
  }

  // DELETE ALL (User Specific)
  Future<int> deleteAllGames(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/delete_all_games.php?user_id=$userId'));
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      return res['success'] ? 1 : 0;
    }
    return 0;
  }
}
