
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/textstyles.dart';
import '../theme/theme_color.dart';

class ListTileCustom extends StatelessWidget {
  final String? title, subtitle;
  final Color? color;
  final Function()? onTap;
  final double? borderRadius;
  final IconData? iconLeading, iconTrailing;
  const ListTileCustom({
    super.key,
    this.title,
    this.iconLeading,
    this.iconTrailing,
    this.color,
    this.subtitle,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(borderRadius ?? 10.w),
      color: color ?? ThemeColor.whiteColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius ?? 10.w),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.w),
          child: ListTile(
            title: Text(title??'', style: TextStyles.defaultStyle.bold.setTextSize(17.w).setColor(ThemeColor.blackColor)),
            subtitle: Text(subtitle??'', style: TextStyles.defaultStyle),
            leading: Icon(iconLeading, color: ThemeColor.blackColor),
            trailing: Icon(iconTrailing, color: ThemeColor.blackColor),
          ),
        ),
      ),
    );
  }
}
