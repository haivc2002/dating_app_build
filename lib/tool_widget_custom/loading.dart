import 'package:dating_build/common/textstyles.dart';
import 'package:dating_build/tool_widget_custom/wait.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../theme/theme_notifier.dart';

class Loading {

  static void onLoading(BuildContext context) {
    showDialog(context: context, builder: (context) {
      final themeNotifier = Provider.of<ThemeNotifier>(context);
      return Center(
        child: Container(
          height: 50.w,
          width: 50.w,
          decoration: BoxDecoration(
            color: themeNotifier.systemText,
            borderRadius: BorderRadius.circular(10.w)
          ),
          child: Center(
            child: CircularProgressIndicator(color: themeNotifier.systemTheme)
          ),
        ),
      );
    }, barrierDismissible: false);
  }

  static void onLoaded(BuildContext context) => Navigator.pop(context);
}