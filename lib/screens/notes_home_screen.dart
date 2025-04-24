import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/custom_note_route.dart';
import 'note_editor_screen.dart';
import 'theme_mode_screen.dart';
import 'recycle_bin_screen.dart';

enum NoteFilter { all, favorites, important }

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({super.key});

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  final NoteService _noteService = NoteService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _selectedFilter = 0;
  String _searchQuery = '';
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  List<String> _filters = ['All', 'Favorites', 'Important'];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await _noteService.getNotes();
      if (!mounted) return;

      // First update the all notes list
      _allNotes = notes;

      // Then apply filters and search
      List<Note> filteredNotes = notes;
      if (_searchController.text.isNotEmpty) {
        filteredNotes =
            notes.where((note) {
              final searchLower = _searchController.text.toLowerCase();
              return note.title.toLowerCase().contains(searchLower) ||
                  note.content.toLowerCase().contains(searchLower);
            }).toList();
      }

      if (_selectedFilter == 1) {
        filteredNotes = filteredNotes.where((note) => note.isFavorite).toList();
      } else if (_selectedFilter == 2) {
        filteredNotes =
            filteredNotes.where((note) {
              final title = note.title.toLowerCase();
              return title.contains('important') || title.contains('urgent');
            }).toList();
      }

      if (!mounted) return;

      setState(() {
        _filteredNotes = filteredNotes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notes: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      _applyFiltersAndSearch();
    });
  }

  void _applyFiltersAndSearch() {
    if (!mounted) return;

    // First apply search filter
    List<Note> searchResults = _allNotes;
    if (_searchController.text.isNotEmpty) {
      searchResults =
          _allNotes.where((note) {
            final searchLower = _searchController.text.toLowerCase();
            return note.title.toLowerCase().contains(searchLower) ||
                note.content.toLowerCase().contains(searchLower);
          }).toList();
    }

    // Then apply category filter
    if (_selectedFilter == 1) {
      searchResults = searchResults.where((note) => note.isFavorite).toList();
    } else if (_selectedFilter == 2) {
      searchResults =
          searchResults.where((note) {
            final title = note.title.toLowerCase();
            return title.contains('important') || title.contains('urgent');
          }).toList();
    }

    setState(() {
      _filteredNotes = searchResults;
    });
  }

  void _updateFilters() {
    if (!mounted) return;

    setState(() {
      _selectedFilter = _selectedFilter == 0 ? 1 : 0;
      _applyFiltersAndSearch();
    });
  }

  Future<void> _toggleFavorite(String id) async {
    await _noteService.toggleFavorite(id);
    await _loadNotes(); // Wait for notes to reload
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF2F7F7);

    // Calculate counts for each filter
    final allCount = _allNotes.length;
    final favoritesCount = _allNotes.where((note) => note.isFavorite).length;
    final importantCount =
        _allNotes.where((note) {
          final title = note.title.toLowerCase();
          return title.contains('important') || title.contains('urgent');
        }).length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              accountName: const Text(
                'John Doe',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: const Text('john.doe@example.com'),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeModeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Recycle Bin'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            RecycleBinScreen(noteService: _noteService),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sign out functionality
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? const Color(0xFF2D2D2D)
                                : const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.menu,
                              color:
                                  isDarkMode
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black87,
                            ),
                            onPressed:
                                () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search notes...',
                                hintStyle: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color:
                                      isDarkMode
                                          ? Colors.white.withOpacity(0.5)
                                          : Colors.black54,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color:
                                    isDarkMode
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black87,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final count =
                              index == 0
                                  ? allCount
                                  : index == 1
                                  ? favoritesCount
                                  : importantCount;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_filters[index]),
                                  if (count > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '($count)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              selected: _selectedFilter == index,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = index;
                                  _applyFiltersAndSearch();
                                });
                              },
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredNotes.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 64,
                        color:
                            isDarkMode
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notes yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              isDarkMode
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childCount: _filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = _filteredNotes[index];
                    return _buildNoteCard(note);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(noteService: _noteService),
            ),
          );
          if (mounted) {
            await _loadNotes();
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Builder(
      builder:
          (context) => GestureDetector(
            onTap: () {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final position = renderBox.localToGlobal(Offset.zero);

              Navigator.push(
                context,
                CustomNoteRoute(
                  startPosition: position,
                  child: NoteEditorScreen(
                    note: note,
                    noteService: _noteService,
                  ),
                ),
              ).then((_) => _loadNotes());
            },
            child: Hero(
              tag: note.id,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: _getNoteColor(note),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          note.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                color:
                                    isDarkMode ? Colors.black : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ) ??
                              AppTypography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (note.title.isNotEmpty && note.content.isNotEmpty)
                          const SizedBox(height: 8),
                        if (note.content.isNotEmpty)
                          Flexible(
                            child: Text(
                              note.content,
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color:
                                        isDarkMode
                                            ? Colors.black
                                            : Colors.black54,
                                  ) ??
                                  AppTypography.bodyMedium,
                              maxLines: null,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Color _getNoteColor(Note note) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final title = note.title.toLowerCase();

    if (title.contains('important') || title.contains('urgent')) {
      return isDarkMode ? const Color(0xFF9A8297) : AppColors.coral;
    }

    final colorIndex = note.id.hashCode % 4;

    if (isDarkMode) {
      switch (colorIndex) {
        case 0:
          return const Color(0xFF7C9EC4);
        case 1:
          return const Color(0xFF8E8DBE);
        case 2:
          return const Color(0xFF7EA891);
        case 3:
          return const Color(0xFFB6927E);
        default:
          return const Color(0xFF7C9EC4);
      }
    } else {
      switch (colorIndex) {
        case 0:
          return AppColors.lightBlue;
        case 1:
          return AppColors.coral.withOpacity(0.8);
        case 2:
          return AppColors.lightYellow;
        case 3:
          return AppColors.beige;
        default:
          return AppColors.lightBlue;
      }
    }
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
