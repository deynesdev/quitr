import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Quit App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Added a basic theme
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  DateTime lastRelapseTime = DateTime.now(); // saves the last time you relapsed
  // This is a placeholder for the last relapse time.
  // In a real app, you might want to load this from persistent storage.
  double get progress {
  final totalSeconds = 21 * 24 * 60 * 60; // 21 days
  final elapsedSeconds = DateTime.now().difference(lastRelapseTime).inSeconds;
  double p = elapsedSeconds / totalSeconds;
  return p > 1.0 ? 1.0 : p; // cap at 1.0
}

@override
void initState() {
  super.initState();
  Timer.periodic(Duration(seconds: 1), (_) {
    setState(() {}); // re-renders the UI every second
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( // Wrap the Column in a Center to horizontally center its content
        child: Column( // Column takes a list of children
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center content within the column
          crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center content within the column
          children: <Widget>[ // This is the list of widgets
            SizedBox(
              width: 200, // Set a fixed width for the CircularProgressIndicator
              height: 200, // Set a fixed height for the CircularProgressIndicator
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 10, // Set the width of the progress indicator
                value: progress,  // from 0.0 to 1.0
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0), // Add some padding around the text
              child: Text(
                'You have been clean for:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              '${DateTime.now().difference(lastRelapseTime).inDays} days, ${DateTime.now().difference(lastRelapseTime).inHours} hours, ${DateTime.now().difference(lastRelapseTime).inMinutes % 60} minutes',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const Padding(
              padding: EdgeInsets.all(20.0), // Add some padding around the text
              child: Text(
                'Press the button below if you are tempted to quit.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('STOP!'),
                      content: const Text('Are you sure you are?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog first
                            // Introduce a small delay to ensure dialog closes before app quits
                            Future.delayed(const Duration(milliseconds: 100), () {
                              setState(() {
                              lastRelapseTime = DateTime.now();

                              // This updates the last relapse time to now
                              });
                            });
                          },
                          child: const Text('I relapsed...'),
                        ),
                      ],
                    );
                  },
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
