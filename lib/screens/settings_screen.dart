import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../utils/session_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper _dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. CLEAR DATABASE CARD
          Card(
            color: const Color(0xFF151725),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.delete_sweep, color: Color(0xFFFF0055)),
              title: const Text('NUKE LIBRARY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Permanently delete all games', style: TextStyle(color: Colors.white54)),
              onTap: () => _showClearDialog(context, _dbHelper),
            ),
          ),
          const SizedBox(height: 16),

          // 2. ABOUT CARD
          Card(
            color: const Color(0xFF151725),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF00F0FF)),
              title: const Text('About Perpus Gaming', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Version 1.0.0 • Built with Flutter', style: TextStyle(color: Colors.white54)),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Perpus Gaming',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.videogame_asset, color: Color(0xFF00F0FF), size: 40),
                  children: [
                    const Text('Your personal gaming library tracker.', style: TextStyle(color: Colors.white70)),
                  ],
                  barrierColor: Colors.black54,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // AlertDialog tombol nuklir
  void _showClearDialog(BuildContext context, DatabaseHelper dbHelper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151725),
        title: const Text('WARNING!', style: TextStyle(color: Color(0xFFFF0055), fontWeight: FontWeight.bold)),
        content: const Text('This will permanently delete ALL games from your vault. This cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              int? userId = await SessionManager.getUserId();
              if (userId != null) {
                await dbHelper.deleteAllGames(userId); // Tombol nuklir specific user
              }
              Navigator.pop(context);

              // quick success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Library cleared successfully!'),
                  backgroundColor: Color(0xFFFF0055),
                ),
              );

              Navigator.pop(context);
            },
            child: const Text('WIPE LIBRARY', style: TextStyle(color: Color(0xFFFF0055), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}