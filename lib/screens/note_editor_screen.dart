import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final NoteService noteService;
  final bool isDeletedNote;

  const NoteEditorScreen({
    super.key,
    this.note,
    required this.noteService,
    this.isDeletedNote = false,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _hasChanges = false;
  bool _isNewNote = true;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _isNewNote = widget.note == null;

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasContent =
        _titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty;
    if (_hasChanges != hasContent) {
      setState(() {
        _hasChanges = hasContent;
        if (!_isNewNote) {
          _isNewNote = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.trim().isEmpty && content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title or content')),
      );
      return;
    }

    if (_isNewNote) {
      await widget.noteService.createNote(title, content);
    } else {
      await widget.noteService.updateNote(widget.note!.id, title, content);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _restoreNote() async {
    if (widget.note != null) {
      await widget.noteService.restoreNote(widget.note!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _permanentlyDeleteNote() async {
    if (widget.note != null) {
      await widget.noteService.permanentlyDeleteNote(widget.note!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    try {
      // Request permissions first
      final status = await Permission.storage.request();
      final photosStatus = await Permission.photos.request();

      if (status.isGranted || photosStatus.isGranted) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null) {
          // Insert image markdown at current cursor position or at the end
          final String imagePath = image.path;
          print('Selected image path: $imagePath'); // Debug print

          final imageMarkdown = '![Image]($imagePath)\n';
          final currentContent = _contentController.text;
          final selection = _contentController.selection;

          setState(() {
            if (selection.isValid) {
              final newText = currentContent.replaceRange(
                selection.start,
                selection.end,
                imageMarkdown,
              );
              _contentController.text = newText;
              _contentController.selection = TextSelection.collapsed(
                offset: selection.start + imageMarkdown.length,
              );
            } else {
              // If no valid selection, append to the end
              if (currentContent.isNotEmpty && !currentContent.endsWith('\n')) {
                _contentController.text = '$currentContent\n$imageMarkdown';
              } else {
                _contentController.text = '$currentContent$imageMarkdown';
              }
            }
          });
        } else {
          print('No image selected'); // Debug print
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permission denied. Please grant access to photos in settings.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error picking image: $e'); // Debug print
      print('Stack trace: $stackTrace'); // Debug print

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showNoteTools() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          widget.note != null
              ? _getNoteColor(widget.note!)
              : const Color(0xFFF2F7F7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.image_outlined,
                    color: Colors.black87.withOpacity(0.75),
                    size: 26,
                  ),
                  title: Text(
                    'Add Image',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black87.withOpacity(0.9),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.brush_outlined,
                    color: Colors.black87.withOpacity(0.75),
                    size: 26,
                  ),
                  title: Text(
                    'Draw',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black87.withOpacity(0.9),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement drawing
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        widget.note != null
            ? _getNoteColor(widget.note!)
            : (isDarkMode
                ? const Color(0xFF1E2A3A).withOpacity(0.95)
                : const Color(0xFFF2F7F7));
    final textColor = Colors.black;
    final hintColor = Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Hero(
                  tag: widget.note?.id ?? 'new_note',
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: hintColor,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Tap here to continue...',
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: hintColor,
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    height: 1.5,
                  ),
                  maxLines: null,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(color: backgroundColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: _showNoteTools,
                  ),
                  if (widget.note != null)
                    Text(
                      widget.isDeletedNote
                          ? 'Deleted: ${_formatDateTime(widget.note!.deletedAt!)}'
                          : _isNewNote
                          ? 'Created: ${_formatDateTime(widget.note!.createdAt)}'
                          : 'Edited: ${_formatDateTime(widget.note!.updatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (widget.note != null)
                    IconButton(
                      icon: Icon(
                        widget.isDeletedNote
                            ? Icons.restore
                            : Icons.delete_outline,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        if (widget.isDeletedNote) {
                          _restoreNote();
                        } else {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Delete Note'),
                                  content: const Text(
                                    'Are you sure you want to delete this note?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        widget.noteService.deleteNote(
                                          widget.note!.id,
                                        );
                                        Navigator.pop(context); // Close dialog
                                        Navigator.pop(
                                          context,
                                        ); // Return to home screen
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          _hasChanges
              ? FloatingActionButton(
                onPressed: _saveNote,
                child: const Icon(Icons.check, color: Colors.black),
              )
              : null,
    );
  }

  Color _getNoteColor(Note note) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final title = note.title.toLowerCase();

    // Special color for important/urgent notes
    if (title.contains('important') || title.contains('urgent')) {
      return isDarkMode
          ? const Color(0xFF9A8297) // Muted purple for dark mode
          : AppColors.coral;
    }

    // Use the note's ID to determine color
    final colorIndex = note.id.hashCode % 4;

    if (isDarkMode) {
      // Elegant dark mode colors with higher saturation
      switch (colorIndex) {
        case 0:
          return const Color(0xFF7C9EC4); // Soft blue
        case 1:
          return const Color(0xFF8E8DBE); // Dusty purple
        case 2:
          return const Color(0xFF7EA891); // Sage green
        case 3:
          return const Color(0xFFB6927E); // Dusty rose
        default:
          return const Color(0xFF7C9EC4);
      }
    } else {
      // Light colors for light mode
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      // Format: "MMM dd, yyyy at HH:mm"
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[dateTime.month - 1];
      final day = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$month $day, $year at $hour:$minute';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
