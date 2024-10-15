import 'package:dating_build/service/notify/firebase_api.dart';
import 'package:dating_build/theme/theme_color.dart';
import 'package:dating_build/theme/theme_notifier.dart';
import 'package:dating_build/ui/preamble/hello_screen.dart';
import 'package:dating_build/ui/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'common/global.dart';
import 'firebase_options.dart';
import 'multibloc.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: const FirebaseOptions(
    //   apiKey: "AIzaSyCZgDYLKRFoSvmdfkrMMYv5iQtpOM7zxb8",
    //   appId: "1:186321810718:android:ad661dc08a7f3fc2fe850f",
    //   messagingSenderId: "186321810718",
    //   projectId: "dating-d6a6b"
    // )
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotification();
  await Global.load();
  runApp(
    const MultiBloc(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return ColorPaletteProvider(
          themeColor: ThemeColor(),
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_ , child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'First Method',
                navigatorKey: navigatorKey,
                scaffoldMessengerKey: scaffoldMessengerKey,
                onGenerateRoute: AppRouter.generateRoute,
                home: child,
              );
            },
            child: const HelloScreen(),
            // child: const AllTapBottomScreen(),
          ),
        );
      }
    );
  }
}
