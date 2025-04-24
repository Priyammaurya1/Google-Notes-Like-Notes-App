import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';
import '../providers/theme_provider.dart';

class ThemeModeScreen extends StatefulWidget {
  const ThemeModeScreen({super.key});

  @override
  State<ThemeModeScreen> createState() => _ThemeModeScreenState();
}

class _ThemeModeScreenState extends State<ThemeModeScreen> {
  final List<Map<String, dynamic>> _themeOptions = [
    {
      'name': 'Dark',
      'value': 'dark',
      'icon': Icons.dark_mode,
      'color': Colors.grey[900],
      'textColor': Colors.white,
    },
    {
      'name': 'Light',
      'value': 'light',
      'icon': Icons.light_mode,
      'color': Colors.grey[100],
      'textColor': Colors.black,
    },
    {
      'name': 'System',
      'value': 'system',
      'icon': Icons.brightness_auto,
      'color': Colors.blueGrey,
      'textColor': Colors.white,
    },
  ];

  String _getThemeModeString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final currentTheme = _getThemeModeString(themeProvider.themeMode);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose Theme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _themeOptions.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) {
                    final theme = _themeOptions[index];
                    final isSelected = theme['value'] == currentTheme;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.coral : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: theme['color'],
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            themeProvider.setThemeMode(theme['value']);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  theme['icon'],
                                  color: theme['textColor'],
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  theme['name'],
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: theme['textColor'],
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.coral,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
