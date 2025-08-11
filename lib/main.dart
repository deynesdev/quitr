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
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> toggleTheme() async {
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
        toggleTheme: toggleTheme,
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

  double get progress {
    final totalSeconds = 21 * 24 * 60 * 60; // 21 days
    final elapsedSeconds = DateTime.now().difference(lastRelapseTime).inSeconds;
    double p = elapsedSeconds / totalSeconds;
    return p > 1.0 ? 1.0 : p;
  }

  @override
  void initState() {
    super.initState();
    loadLastRelapseTime();

    Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  Future<void> saveLastRelapseTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastRelapseTime', lastRelapseTime.toIso8601String());
  }

  Future<void> loadLastRelapseTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRelapseString = prefs.getString('lastRelapseTime');
    if (lastRelapseString != null) {
      setState(() {
        lastRelapseTime = DateTime.parse(lastRelapseString);
      });
    } else {
      setState(() {
        lastRelapseTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: widget.isDarkMode,
              onChanged: (value) {
                widget.toggleTheme();
              },
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 10,
                value: progress,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'You have been clean for:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              '${DateTime.now().difference(lastRelapseTime).inDays} days, '
              '${DateTime.now().difference(lastRelapseTime).inHours % 24} hours, '
              '${DateTime.now().difference(lastRelapseTime).inMinutes % 60} minutes',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future.delayed(const Duration(milliseconds: 100), () {
                            setState(() {
                              lastRelapseTime = DateTime.now();
                              saveLastRelapseTime();
                            });
                          });
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