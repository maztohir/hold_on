import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HoldOn',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: BreathAnimation(),
        backgroundColor: Colors.black45,
      ),
    );
  }
}

class BreathAnimation extends StatefulWidget {
  const BreathAnimation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BreathAnimationState createState() => _BreathAnimationState();
}

class _BreathAnimationState extends State<BreathAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  bool breathCompleted = false;

  final int animationDuration = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: animationDuration),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
        setState(() {
          breathCompleted = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        // stop after reverse once
        // _controller.forward();
      }
    });
    // _controller.addListener(_vibrationHandler);
    List<int> vibrationPattern =
        _getVibrationPattern(maxTimeSecond: animationDuration);
    Vibration.vibrate(pattern: vibrationPattern);
    _controller.forward();
  }

  List<int> _getVibrationPattern(
      {num initalTimeGapSecond = 1,
      required int maxTimeSecond,
      int vibrationPeriodMillis = 200,
      int rounding = 7}) {
    num currentTimeRunning = initalTimeGapSecond;

    num totalTimeGap = initalTimeGapSecond;
    List<int> timeGapsInMillis = [
      vibrationPeriodMillis,
      (initalTimeGapSecond * 1000).round()
    ];
    num maxTimeSecondTollerance = maxTimeSecond * 0.999;

    while (totalTimeGap < maxTimeSecondTollerance) {
      num newTimeRunning = sqrt(maxTimeSecond * currentTimeRunning);
      num newTimeGap = double.parse(
          (newTimeRunning - currentTimeRunning).toStringAsFixed(rounding));

      int newTimeGapInMillis = ((newTimeGap / 2) * 1000).round();
      int adjustedVibrationPeriodMillis =
          vibrationPeriodMillis < newTimeGapInMillis
              ? vibrationPeriodMillis
              : newTimeGapInMillis;
      timeGapsInMillis.add(adjustedVibrationPeriodMillis);
      timeGapsInMillis.add(newTimeGapInMillis);

      timeGapsInMillis.add(adjustedVibrationPeriodMillis);
      timeGapsInMillis.add(newTimeGapInMillis);

      currentTimeRunning = newTimeRunning;
      totalTimeGap += newTimeGap;
    }

    return timeGapsInMillis;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget shapeAnimation(double height) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: _animation.value * height,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
      ),
    );
  }

  Widget welcomeTextBreath() {
    return Visibility(
      visible: !breathCompleted,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Hold On!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "It's time to take a deep breath",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget appOpenDeciderPage() {
    return Visibility(
      visible: breathCompleted,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Are you sure still wanted to open the app?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Perform some action
                  },
                  child: const Text(
                    "No, I'll do something else productive",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Yes, open the previous app, and waste my time",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            welcomeTextBreath(),
            appOpenDeciderPage(),
            shapeAnimation(height),
          ],
        );
      },
    );
  }
}
