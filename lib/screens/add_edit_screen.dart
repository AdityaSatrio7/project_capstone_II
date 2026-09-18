import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../model/game_model.dart';
import '../utils/session_manager.dart';

class AddEditScreen extends StatefulWidget {
  final Game? game; // If null, tambah game. If not null, edit card.
  const AddEditScreen({super.key, this.game});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late TextEditingController _titleController;
  late TextEditingController _genreController;
  late TextEditingController _platformController;
  late TextEditingController _coverController;
  late String _selectedStatus;

  final List<String> _statuses = ['Backlog', 'Playing', 'Completed', 'Dropped'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.game?.title ?? '');
    _genreController = TextEditingController(text: widget.game?.genre ?? '');
    _platformController = TextEditingController(text: widget.game?.platform ?? '');
    _coverController = TextEditingController(text: widget.game?.coverUrl ?? '');
    _selectedStatus = widget.game?.status ?? 'Backlog';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _platformController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  void _saveGame() async {
    if (_formKey.currentState!.validate()) {
      int? userId = await SessionManager.getUserId();
      if (userId == null) return;

      Game newGame = Game(
        id: widget.game?.id,
        userId: userId,
        title: _titleController.text,
        genre: _genreController.text,
        platform: _platformController.text,
        status: _selectedStatus,
        coverUrl: _coverController.text,
      );

      if (widget.game == null) {
        await _dbHelper.insertGame(newGame);
      } else {
        await _dbHelper.updateGame(newGame);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game == null ? 'Add Game' : 'Edit Game'),
      ),
      // FORM
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Game Title', prefixIcon: Icon(Icons.title)),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Genre
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Genre', prefixIcon: Icon(Icons.category)),
              ),
              const SizedBox(height: 16),

              // Platform
              TextFormField(
                controller: _platformController,
                decoration: const InputDecoration(labelText: 'Platform (PC, PS5, etc.)', prefixIcon: Icon(Icons.devices)),
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status', prefixIcon: Icon(Icons.flag)),
                dropdownColor: const Color(0xFF151725),
                items: _statuses.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 16),

              // Cover URL
              TextFormField(
                controller: _coverController,
                decoration: const InputDecoration(labelText: 'Cover Image URL', prefixIcon: Icon(Icons.image)),
              ),
              const SizedBox(height: 32),

              // Elevated Button
              ElevatedButton(
                onPressed: _saveGame,
                child: Text(widget.game == null ? 'ADD TO LIBRARY' : 'UPDATE GAME', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}