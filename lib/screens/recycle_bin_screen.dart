import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/custom_note_route.dart';
import 'note_editor_screen.dart';

class RecycleBinScreen extends StatefulWidget {
  final NoteService noteService;

  const RecycleBinScreen({super.key, required this.noteService});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  List<Note> _deletedNotes = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchField = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeletedNotes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _searchField.dispose();
    super.dispose();
  }

  Future<void> _loadDeletedNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await widget.noteService.getDeletedNotes();
      setState(() {
        _deletedNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading deleted notes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _loadDeletedNotes();
      } else {
        final query = _searchController.text.toLowerCase();
        _deletedNotes =
            _deletedNotes.where((note) {
              return note.title.toLowerCase().contains(query) ||
                  note.content.toLowerCase().contains(query);
            }).toList();
      }
    });
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
          return AppColors.coral.withValues(alpha: 0.8);
        case 2:
          return AppColors.lightYellow;
        case 3:
          return AppColors.beige;
        default:
          return AppColors.lightBlue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF2F7F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recycle Bin',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
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
                        Icons.search,
                        color:
                            isDarkMode
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.black87,
                      ),
                      onPressed: () {
                        // Focus the search field
                        FocusScope.of(context).requestFocus(_searchFocus);
                        _searchFocus.requestFocus();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search deleted notes...',
                          hintStyle: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                isDarkMode
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black54,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color:
                              isDarkMode
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.black87,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _deletedNotes.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 64,
                              color:
                                  isDarkMode
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.black54,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No deleted notes',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color:
                                    isDarkMode
                                        ? Colors.white.withValues(alpha: 0.5)
                                        : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                      : SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childCount: _deletedNotes.length,
                          itemBuilder: (context, index) {
                            final note = _deletedNotes[index];
                            return _buildNoteCard(note);
                          },
                        ),
                      ),
            ),
          ],
        ),
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
                    noteService: widget.noteService,
                    isDeletedNote: true,
                  ),
                ),
              ).then((_) => _loadDeletedNotes());
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
                        color: Colors.black.withValues(alpha: 0.05),
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
}
