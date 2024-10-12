
import 'package:dating_build/ui/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../tool_widget_custom/bottom_sheet_custom.dart';
import '../../../tool_widget_custom/button_widget_custom.dart';
import '../../common/scale_screen.dart';
import '../../controller/login_controller.dart';
import '../../theme/theme_color.dart';
import '../../theme/theme_image.dart';



class LoginScreen extends StatefulWidget {
  static const routeName = '/loginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {

  BottomSheetCustom bottomSheet = const BottomSheetCustom();
  late LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = LoginController(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.themeDarkSystem,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            height: heightScreen(context),
            width: widthScreen(context),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ThemeImage.backgroundLogin),
                fit: BoxFit.cover
              )
            ),
            child: SizedBox(
              height: heightScreen(context),
              width: widthScreen(context),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ThemeColor.blackColor.withOpacity(0.4), ThemeColor.blackColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter
                  )
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: heightScreen(context)*0.7),
                  ButtonWidgetCustom(
                    styleText: TextStyle(
                        color: ThemeColor.blackColor.withOpacity(0.6),
                        fontWeight: FontWeight.bold
                    ),
                    color: ThemeColor.whiteColor,
                    radius: 100,
                    textButton: 'I already have an account',
                    height: 40.h,
                    onTap: ()=> controller.popupLogin()
                  ),
                  SizedBox(height: 20.h),
                  ButtonWidgetCustom(
                    styleText: const TextStyle(
                        color: ThemeColor.whiteColor,
                        fontWeight: FontWeight.bold
                    ),
                    color: ThemeColor.pinkColor,
                    radius: 100,
                    textButton: 'Do not have an account?',
                    height: 40.h,
                    onTap: () => Navigator.pushNamed(context, RegisterScreen.routeName),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );

  }

}
