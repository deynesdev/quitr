import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
    setState(() {
      isDarkMode = !isDarkMode;
      prefs.setBool('isDarkMode', isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quitr',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: MyHomePage(
        isDarkMode: isDarkMode,
        toggleTheme: _toggleTheme,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: widget.isDarkMode,
              onChanged: (_) => widget.toggleTheme(),
            ),
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
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 10,
                        value: _getProgress(now),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'You have been clean for:',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      '${diff.inDays} days, '
                      '${diff.inHours % 24} hours, '
                      '${diff.inMinutes % 60} minutes',
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'You are doing great! Keep it up!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
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
              child: const Text('I AM TEMPTED'),
            ),
          ],
        ),
      ),
    );
  }
}