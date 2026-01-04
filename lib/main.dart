import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';

void main() => runApp(const ExtremeApp());

class ExtremeApp extends StatelessWidget {
  const ExtremeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extreme System Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  bool _isStressing = false;
  List<Isolate?> _isolates = [];

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // 啟動時強制螢幕常亮
    _updateBattery();
  }

  void _updateBattery() async {
    final level = await _battery.batteryLevel;
    setState(() => _batteryLevel = level);
  }

  void _toggleStress() {
    setState(() {
      _isStressing = !_isStressing;
      if (_isStressing) {
        // 模擬高負載運算
        Timer.periodic(const Duration(milliseconds: 10), (timer) {
          if (!_isStressing) timer.cancel();
          double x = 0.0001;
          for (int i = 0; i < 1000000; i++) {
            x += math.sqrt(i);
          }
        });
        ScreenBrightness().setScreenBrightness(1.0); // 亮度調到最高
      } else {
        ScreenBrightness().resetScreenBrightness();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EXTREME SYSTEM PRO")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainType.center,
          children: [
            Text("電量: $_batteryLevel%", style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _toggleStress,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isStressing ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: Text(_isStressing ? "停止壓力測試" : "開始極限壓測", 
                style: const TextStyle(fontSize: 24)),
            ),
            if (_isStressing) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.orange),
              const Text("\n硬體滿載運作中...", style: TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}