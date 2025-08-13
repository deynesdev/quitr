import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';

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
    return DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) {
    final lightScheme = lightDynamic ?? ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.light,
    );
    final darkScheme = darkDynamic ?? ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Quitr',
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
    if (diff.inDays > 0) {
      parts.add('${diff.inDays} days');
    }
    if (diff.inHours % 24 > 0) {
      parts.add('${diff.inHours % 24} hours');
    }
    if (diff.inMinutes % 60 > 0) {
      parts.add('${diff.inMinutes % 60} minutes');
    }
    if (diff.inSeconds % 60 > 0) {
      parts.add('${diff.inSeconds % 60} seconds');
    }
    if (parts.isEmpty) {
      return '0 seconds';
    }
    return parts.join(', ');
  }

Widget tipOfTheDay(Duration diff, BuildContext context) {
  const tips = [
    'Remember, every day is a new beginning. Consciously decide to change. You have got this!',
    'Confess the problem to loved ones or a support group; secrecy empowers addiction.',
    'Start by eliminating pornography. If cold turkey is too difficult, gradually wean off by using non-pornographic materials (e.g., bikini magazines) until they become boring. Buying more is prohibited.',
    'Stop using external stimuli for fapping (sounds/images). If you must, do it in the dark, allowing your mind to wander freely.',
    'Fill your schedule with other activities and tasks to avoid idle time that could lead to the habit.',
    'Spend time around people, even working in public places like a library or cafe.',
    'Write down your reasons for quitting and revisit them often. Remind yourself of them when temptations arise.',
    'Develop new interests – learn to code, play an instrument, start a business, learn languages, or find new social hobbies like pottery or parkour.',
    'Exercise regularly and vigorously to boost your mood, energy, and overall well-being. Work out to the point of exhaustion to leave no energy for fapping.',
    'Address your mental health. Addiction is often a symptom of deeper issues like loneliness or a poor mental state.',
    'Practice mindfulness and meditation to control urges and regain clarity of thought.',
    'Identify and avoid triggers that make you want to relapse.',
    'If quitting cold turkey is too difficult, consider gradually reducing frequency, for example, by setting a structured schedule for yourself.',
    'Use a calendar (physical or digital) to track your progress and plan your "clean" days.',
    'If you experience a relapse, **do not feel guilty**. Learn from what went wrong, understand the triggers, and recommit to your plan.',
    'Start confronting your shame and social fears. Write down lists of everything that has made you feel shame in your life.',
    'Forgive yourself and others for past mistakes. Your future is more important than dwelling on the past.',
    'Actively overcome your social fears (e.g., public speaking, interacting with new people) to build internal strength and control.',
    'Focus on building a meaningful life. True freedom from the habit often comes when your life feels purposeful and has direction.',
    'Cultivate inner strength and self-discipline, rather than relying solely on external structures or avoiding temptations.',
    'Be aware of the potential physical and psychological effects of excessive fapping, such as erectile dysfunction, brain fog, low energy levels, or even physical pain.',
    'You have successfully finished the challenge! Stay hydrated and maintain a healthy diet; this supports your overall well-being, energy levels, and mental clarity.',
  ];

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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tips[index],
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final horizontalPadding = screenWidth * 0.05;
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
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                      formatDuration(diff),
                      style : const TextStyle(
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
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
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            Padding(
  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
  child: Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
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