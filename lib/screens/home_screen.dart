import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../model/game_model.dart';
import '../utils/session_manager.dart';
import 'settings_screen.dart';
import 'add_edit_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Game> _games = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  int? _userId;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _initSessionAndLoad();
  }

  void _initSessionAndLoad() async {
    _userId = await SessionManager.getUserId();
    _username = await SessionManager.getUsername() ?? '';
    if (_userId != null) {
      _loadGames();
    }
  }

  void _loadGames() async {
    if (_userId == null) return;
    List<Game> games = await _dbHelper.getGames(_userId!);
    setState(() => _games = games);
  }

  void _searchGames(String query) async {
    if (_userId == null) return;
    if (query.isEmpty) {
      _loadGames();
      return;
    }
    List<Game> results = await _dbHelper.searchGames(_userId!, query);
    setState(() => _games = results);
  }

  void _confirmDelete(Game game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151725),
        title: const Text('Delete Game?', style: TextStyle(color: Color(0xFFFF0055))),
        content: Text('Are you sure you want to delete "${game.title}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (_userId != null && game.id != null) {
                await _dbHelper.deleteGame(game.id!, _userId!);
                Navigator.pop(context);
                _loadGames();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF0055))),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // DRAWER
      drawer: Drawer(
        backgroundColor: const Color(0xFF0B0C15),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF151725)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.videogame_asset, color: Color(0xFF00F0FF), size: 40),
                  const SizedBox(height: 10),
                  const Text('PERPUS GAMING', style: TextStyle(color: Color(0xFF00F0FF), fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Welcome, $_username', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF00F0FF)),
              title: const Text('My Games', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF00F0FF)),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
                _loadGames();
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFFF0055)),
              title: const Text('Logout', style: TextStyle(color: Color(0xFFFF0055))),
              onTap: _logout,
            ),
          ],
        ),
      ),
      // APP BAR
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search games...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: _searchGames,
        )
            : const Text('PERPUS GAMING'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _loadGames();
                }
                _isSearching = !_isSearching;
              });
            },
          )
        ],
      ),
      // BODY
      body: _games.isEmpty
          ? const Center(child: Text('No games found.', style: TextStyle(color: Colors.white54)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return Card(
            color: const Color(0xFF151725),
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      game.coverUrl.isNotEmpty ? game.coverUrl : 'https://placehold.co/100x100/151725/00F0FF?text=No+Cover',
                      width: 80, height: 80, fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 80, height: 80, color: Colors.black26,
                        child: const Icon(Icons.videogame_asset, color: Colors.white54, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // TEXT INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(game.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${game.genre} • ${game.platform}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F0FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5)),
                          ),
                          child: Text(game.status, style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  // ACTION ICONS
                  Column(
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Color(0xFF00F0FF)), onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditScreen(game: game)));
                        _loadGames();
                      }),
                      IconButton(icon: const Icon(Icons.delete, color: Color(0xFFFF0055)), onPressed: () => _confirmDelete(game)),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditScreen()));
          _loadGames();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}