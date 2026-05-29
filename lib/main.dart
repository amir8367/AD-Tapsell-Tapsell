import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:liquid_glass_render/liquid_glass_render.dart';

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
          // ۱. لایه پس‌زمینه: نمایش زنده دوربین به صورت تمام‌صفحه
          Positioned.fill(
            child: CameraPreview(controller),
          ),
          
          // ۲. لایه رویی: دایره افکت Liquid Glass در مرکز صفحه
          Center(
            child: LiquidGlassContainer(
              width: 250,
              height: 250,
              blur: 20.0,            // میزان محو شدگی پس‌زمینه شیشه
              thickness: 1.5,        // ضخامت لبه‌های مایع شیشه
              refraction: 0.4,       // میزان شکست نور مایع
              glassColor: Colors.white.withOpacity(0.1), // رنگ پایه شیشه
              shape: BoxShape.circle, // تغییر شکل کامپوننت به دایره
              child: const SizedBox.expand(), // فضای داخلی دایره
            ),
          ),
        ],
      ),
    );
  }
}
