import 'package:flutter/material.dart';

import '../../common/global.dart';
import '../../common/scale_screen.dart';
import '../../theme/theme_color.dart';
import '../../theme/theme_config.dart';
import '../all_tap_bottom/all_tap_bottom_screen.dart';
import '../auth/login_screen.dart';


class AnimateToNextScreen extends StatefulWidget {
  static const String routeName = "/AnimateToNextScreen";
  const AnimateToNextScreen({super.key});

  @override
  State<AnimateToNextScreen> createState() => _AnimateToNextScreenState();
}

class _AnimateToNextScreenState extends State<AnimateToNextScreen> with TickerProviderStateMixin {
  double containerHeight = 0;
  bool lineFade = false;
  bool filterBlur = true;
  double fadeColor = 0.8;
  
  int idUser = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          lineFade = true;
          containerHeight = MediaQuery.of(context).size.height;
          fadeColor = 0.0;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          filterBlur = false;
        });
      }
    });
    idUser = Global.getInt(ThemeConfig.idUser);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: const Color(0xFF2B2B2B),
          body: Stack(
            children: [
              SizedBox(
                height: heightScreen(context),
                width: widthScreen(context),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: idUser < 0 ? const LoginScreen() : const AllTapBottomScreen()
                ),
              ),
              Visibility(
                visible: filterBlur,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: heightScreen(context),
                  width: widthScreen(context),
                  color: Colors.black.withOpacity(fadeColor),
                ),
              ),
              filterBlur ? Column(
                children: [
                  AnimatedContainer(
                    height: containerHeight,
                    width: widthScreen(context),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Visibility(
                              visible: lineFade,
                              child: SizedBox(
                                height: heightScreen(context) * 0.1,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          ThemeColor.pinkFadeColor.withOpacity(0),
                                          ThemeColor.pinkFadeColor
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )),
                                ),
                              ),
                            ),
                            ColoredBox(
                              color: ThemeColor.pinkFadeColor,
                              child: SizedBox(
                                height: heightScreen(context),
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              ) : const SizedBox(),
            ],
          ),
        ));
  }
}
