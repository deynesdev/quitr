import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'tips.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = !isDarkMode);
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = lightDynamic ??
            const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xFFD32F2F),
              onPrimary: Colors.white,
              secondary: Color(0xFF00796B),
              onSecondary: Colors.white,
              tertiary: Color(0xFFF57C00),
              onTertiary: Colors.black,
              surface: Color(0xFFFDFDFD),
              onSurface: Color(0xFF212121),
              surfaceVariant: Color(0xFFE0E0E0),
              errorContainer: Color(0xFFB00020),
              error: Color(0xFFCF6679),
              onError: Colors.white,
              outline: Color(0xFF757575),
            );

        final darkScheme = darkDynamic ??
            const ColorScheme(
              brightness: Brightness.dark,
              primary: Color(0xFFD32F2F),
              onPrimary: Colors.black,
              secondary: Color(0xFF80CBC4),
              onSecondary: Colors.black,
              tertiary: Color(0xFFFFB74D),
              onTertiary: Colors.black,
              surface: Color(0xFF121212),
              onSurface: Color(0xFFE0E0E0),
              surfaceVariant: Color(0xFF1E1E1E),
              error: Color(0xFFCF6679),
              onError: Colors.black,
              outline: Color(0xFF757575),
            );

        return MaterialApp(
          title: 'Waffles',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MyHomePage(
            isDarkMode: isDarkMode,
            toggleTheme: _toggleTheme,
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const MyHomePage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime lastRelapseTime = DateTime.now();
  late final Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _loadLastRelapseTime();
    _timeStream =
        Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  double _getProgress(DateTime now) {
    const totalSeconds = 21 * 24 * 60 * 60; // 21 days
    final elapsedSeconds = now.difference(lastRelapseTime).inSeconds;
    final p = elapsedSeconds / totalSeconds;
    return p > 1.0 ? 1.0 : p;
  }

  Future<void> _saveLastRelapseTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastRelapseTime', lastRelapseTime.toIso8601String());
  }

  Future<void> _loadLastRelapseTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRelapseString = prefs.getString('lastRelapseTime');
    if (lastRelapseString != null) {
      lastRelapseTime = DateTime.parse(lastRelapseString);
    } else {
      lastRelapseTime = DateTime.now();
      await _saveLastRelapseTime();
    }
    setState(() {});
  }

  String formatDuration(Duration diff) {
    final parts = <String>[];
    if (diff.inDays > 0) parts.add('${diff.inDays} days');
    if (diff.inHours % 24 > 0) parts.add('${diff.inHours % 24} hours');
    if (diff.inMinutes % 60 > 0) parts.add('${diff.inMinutes % 60} minutes');
    if (diff.inSeconds % 60 > 0) parts.add('${diff.inSeconds % 60} seconds');
    return parts.isEmpty ? '0 seconds' : parts.join(', ');
  }

  Widget tipOfTheDay(Duration diff, BuildContext context) {

    final index = diff.inDays % tips.length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Day ${diff.inDays}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tips[index],
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 16.0;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            StreamBuilder<DateTime>(
              stream: _timeStream,
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();
                final diff = now.difference(lastRelapseTime);

                return Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        strokeWidth: 15,
                        value: _getProgress(now),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'You have been clean for:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      formatDuration(diff),
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('STOP!'),
                    content: const Text('Are you sure you are?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          lastRelapseTime = DateTime.now();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('You have relapsed.')),
                          );
                          await _saveLastRelapseTime();
                        },
                        child: const Text('I relapsed...'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.warning),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              label: const Text('I AM TEMPTED'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: tipOfTheDay(
                  DateTime.now().difference(lastRelapseTime),
                  context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}