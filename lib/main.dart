import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

// متغیر سراسری برای ذخیره لیست دوربین‌های در دسترس
late List<CameraDescription> _cameras;

Future<void> main() async {
  // اطمینان از مقداردهی اولیه سرویس‌های فلاتر
  WidgetsFlutterBinding.ensureInitialized();
  
  // دریافت دوربین‌های دستگاه
  _cameras = await availableCameras();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Liquid Glass',
      theme: ThemeData.dark(), // تم تاریک برای هماهنگی بیشتر با افکت‌ها
      home: const CameraScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    // راه‌اندازی اولین دوربین (دوربین عقب) با بالاترین کیفیت ممکن
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        isCameraInitialized = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('دسترسی به دوربین داده نشد.');
            break;
          default:
            print('خطای دوربین: ${e.description}');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    // آزادسازی منابع دوربین هنگام خروج
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نمایش لودینگ تا زمان فعال شدن دوربین
    if (!isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      body: Stack(
  children: [
    // 1. Your background content goes here
  

    // 2. Create a layer for liquid glass effects
    LiquidGlassLayer(
      // 3. Add your LiquidGlass widgets here
      child: LiquidGlass(
        shape: LiquidRoundedSuperellipse(borderRadius: 30),
        child: const SizedBox.square(dimension: 100),
      ),
    ),
  ],
)
        
    );
  }
}
