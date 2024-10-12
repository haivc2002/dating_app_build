import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../theme/theme_color.dart';
import '../theme/theme_notifier.dart';

class ItemCard extends StatelessWidget {
  final Color? colorCard, titleColor;
  final String? titleCard;
  final double? fontSize, paddingBottom;
  final Widget? iconTitle;
  final IconData? iconRight;
  final List<Widget>? listWidget;
  final Function()? onTap;
  const ItemCard({
    super.key,
    this.colorCard,
    this.titleCard,
    this.fontSize,
    this.titleColor,
    this.iconTitle,
    this.paddingBottom,
    this.listWidget,
    this.iconRight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, paddingBottom ?? 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.w),
        child: GestureDetector(
          onTap: onTap,
          child: Material(
            color: colorCard ?? themeNotifier.systemThemeFade,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          iconTitle ?? const SizedBox.shrink(),
                          iconTitle != null ? SizedBox(width: 10.w) : const SizedBox.shrink(),
                          Text(titleCard ?? '', style: TextStyle(
                            fontSize: fontSize ?? 13.sp,
                            fontWeight: FontWeight.bold,
                            color: titleColor ?? themeNotifier.systemText
                          ))
                        ],
                      ),
                      if (listWidget != null) ...listWidget! else const SizedBox()
                    ],
                  ),
                  const Spacer(),
                  iconRight != null ? Icon(iconRight!, color: ThemeColor.greyColor.withOpacity(0.7), size: 17.sp,) : const SizedBox.shrink()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
