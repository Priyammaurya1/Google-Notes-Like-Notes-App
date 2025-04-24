import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteService {
  static const String _storageKey = 'notes';
  late SharedPreferences _prefs;
  List<Note> _notes = [];

  NoteService() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadNotes();
    _cleanupOldDeletedNotes();
  }

  Future<void> _loadNotes() async {
    final String? notesJson = _prefs.getString(_storageKey);
    if (notesJson == null) {
      _notes = [];
      return;
    }

    try {
      final List<dynamic> decoded = json.decode(notesJson);
      _notes = decoded.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      print('Error loading notes: $e');
      _notes = [];
    }
  }

  Future<List<Note>> getNotes() async {
    await _loadNotes();
    return _notes.where((note) => !note.isDeleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<List<Note>> getDeletedNotes() async {
    await _loadNotes();
    return _notes.where((note) => note.isDeleted).toList()
      ..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
  }

  Future<void> createNote(String title, String content) async {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.add(newNote);
    await _saveNotes();
  }

  Future<void> updateNote(String id, String title, String content) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = Note(
        id: id,
        title: title,
        content: content,
        createdAt: _notes[index].createdAt,
        updatedAt: DateTime.now(),
        isDeleted: _notes[index].isDeleted,
        deletedAt: _notes[index].deletedAt,
      );
      await _saveNotes();
    }
  }

  Future<void> deleteNote(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
      );
      await _saveNotes();
    }
  }

  Future<void> restoreNote(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isDeleted: false, deletedAt: null);
      await _saveNotes();
    }
  }

  Future<void> permanentlyDeleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _saveNotes();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isFavorite: !_notes[index].isFavorite,
      );
      await _saveNotes();
    }
  }

  Future<void> _cleanupOldDeletedNotes() async {
    final now = DateTime.now();
    _notes.removeWhere((note) {
      if (note.isDeleted && note.deletedAt != null) {
        return now.difference(note.deletedAt!).inDays > 7;
      }
      return false;
    });
    await _saveNotes();
  }

  Future<void> _saveNotes() async {
    try {
      final String encoded = json.encode(
        _notes.map((note) => note.toJson()).toList(),
      );
      await _prefs.setString(_storageKey, encoded);
    } catch (e) {
      print('Error saving notes: $e');
    }
  }

  Future<List<Note>> searchNotes(String query) async {
    await _loadNotes();
    final lowercaseQuery = query.toLowerCase();
    return _notes.where((note) {
      if (note.isDeleted) return false;
      return note.title.toLowerCase().contains(lowercaseQuery) ||
          note.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
