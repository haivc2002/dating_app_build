import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../argument_model/argument_register_info.dart';
import '../common/global.dart';
import '../common/textstyles.dart';
import '../model/model_info_user.dart';
import '../model/model_request_auth.dart';
import '../service/service_login.dart';
import '../theme/theme_color.dart';
import '../theme/theme_icon.dart';
import '../tool_widget_custom/button_widget_custom.dart';
import '../tool_widget_custom/input_custom.dart';
import '../tool_widget_custom/popup_custom.dart';
import '../ui/all_tap_bottom/all_tap_bottom_screen.dart';
import '../ui/auth/register_info_screen.dart';

class LoginController {

  BuildContext context;
  LoginController(this.context);

  ServiceLogin serviceLogin = ServiceLogin();

  final TextEditingController emailController = TextEditingController(text: 'thanhhaivc2002');
  final TextEditingController passController = TextEditingController(text: '123456');
  final firebaseAuth = FirebaseAuth.instance;
  double scaleValue = 1.0;

  void popupLogin(setState) {
    setState(()=>scaleValue = 1.1);
    showCupertinoDialog(context: context, barrierDismissible: true,
      builder: (context) {
        return Center(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(end: 30, begin: 0),
            builder: (context, value, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaY: value, sigmaX: value),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text('Login', style: TextStyle(
                            color: ThemeColor.whiteColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 30.sp
                          )),
                          SizedBox(width: 10.w),
                          Expanded(child: Divider(
                            color: ThemeColor.whiteColor.withOpacity(0.5),
                          ))
                        ],
                      ),
                      SizedBox(height: 30.h),
                      InputCustom(
                        controller: emailController,
                        colorInput: ThemeColor.blackColor.withOpacity(0.3),
                        labelText: 'Email',
                        colorText: ThemeColor.whiteColor,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20.h),
                      InputCustom(
                        controller: passController,
                        hidePass: true,
                        colorInput: ThemeColor.blackColor.withOpacity(0.3),
                        labelText: 'passWord',
                        colorText: ThemeColor.whiteColor,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      SizedBox(height: 20.h),
                      ButtonWidgetCustom(
                          textButton: 'Login',
                          height: 40.h,
                          radius: 10.w,
                          color: ThemeColor.pinkColor.withOpacity(0.6),
                          styleText: TextStyle(
                              color: ThemeColor.whiteColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold
                          ),
                          onTap: ()=> login(emailController.text, passController.text)
                      ),
                      SizedBox(height: 20.w),
                      Row(
                        children: [
                          Expanded(child: Divider(endIndent: 20.w, color: ThemeColor.whiteColor.withOpacity(0.5))),
                          Text('or', style: TextStyles.defaultStyle.whiteText),
                          Expanded(child: Divider(indent: 20.w, color: ThemeColor.whiteColor.withOpacity(0.5))),
                        ],
                      ),
                      Row(
                        children: [
                          _or(
                              title: 'Back',
                              textColor: ThemeColor.blackColor,
                              boxColor: ThemeColor.whiteColor,
                              icon: const Icon(Icons.arrow_back_rounded),
                              onTap: () => Navigator.pop(context)
                          ),
                          const Spacer(),
                          _or(
                              title: 'Google',
                              textColor: ThemeColor.blackColor,
                              boxColor: ThemeColor.whiteColor,
                              icon: Image.asset(ThemeIcon.iconGoogle),
                              onTap: () async => await loginWithGoogle()
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      );
      }
    ).whenComplete(()=> setState(()=> scaleValue = 1.0));
  }

  void login(String email, String password) async {
    ModelRequestAuth req = ModelRequestAuth(
        email : email,
        password: password
    );
    ModelInfoUser response = await serviceLogin.login(req);
    if(response.result == 'Success') {
      onSuccess(response);
    } else {
      onError(response);
    }
  }

  void onSuccess(ModelInfoUser response) async {
    if (!context.mounted) return;
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 250));
    if (context.mounted) {
      if (response.info?.name != null) {
        Global.setInt('idUser', response.idUser!);
        Navigator.pushNamedAndRemoveUntil(context, AllTapBottomScreen.routeName, (route) => false);
      } else {
        Navigator.pushNamed(
          context,
          RegisterInfoScreen.routeName,
          arguments: ArgumentRegisterInfo(
              email: emailController.text,
              password: passController.text,
              idUser: response.idUser
          ),
        );
      }
    }
  }

  void onError(ModelInfoUser response) {
    PopupCustom.showPopup(context,
      content: Text('${response.message}'),
      listOnPress: [(context)=> Navigator.pop(context)],
      listAction: [Text('Ok', style: TextStyles.defaultStyle.bold.setColor(ThemeColor.blueColor))]
    );
  }

  Widget _or({String? title, Color? textColor, Color? boxColor, Widget? icon, Function()? onTap}) {
    return Padding(
      padding: EdgeInsets.only(top: 20.w),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 30.w,
          width: 150.w,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30.w,
                      width: 30.w,
                      child: icon,
                    ),
                    Expanded(child: Center(child: Text(title??'', style: TextStyles.defaultStyle.bold.setColor(textColor??Colors.transparent)))),
                    SizedBox(
                      height: 30.w,
                      width: 30.w,
                    ),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }

  Future<void> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    final cred = GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken,
      accessToken: googleAuth?.accessToken,
    );
    await firebaseAuth.signInWithCredential(cred);
    ModelInfoUser response = await serviceLogin.loginWithGoogle(firebaseAuth.currentUser?.email);
    if(response.result == "Success") {
      onSuccess(response);
    } else {
      onError(response);
    }
  }

}