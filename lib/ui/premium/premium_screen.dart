import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_build/common/extension/gradient.dart';
import 'package:dating_build/common/is_premium.dart';
import 'package:dating_build/common/year_old.dart';
import 'package:dating_build/ui/premium/state_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc_premium/premium_bloc.dart';
import '../../common/scale_screen.dart';
import '../../common/textstyles.dart';
import '../../controller/premium/premium_controller.dart';
import '../../theme/theme_color.dart';
import '../../theme/theme_image.dart';
import '../../theme/theme_notifier.dart';
import '../../tool_widget_custom/appbar_custom.dart';

class PremiumScreen extends StatefulWidget {
  static const String routeName = "/premiumScreen";
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> with WidgetsBindingObserver {

  late PremiumController controller;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => controller.lifecycleState(state);

  @override
  void initState() {
    super.initState();
    controller = PremiumController(context);
    controller.getEnigmatic();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      backgroundColor: themeNotifier.systemTheme,
      body: AppBarCustom(
        title: 'Premium',
        textStyle: TextStyles.defaultStyle.bold.appbarTitle,
        bodyListWidget: [
          BlocBuilder<PremiumBloc, PremiumState>(
            builder: (context, state) {
              if(state is LoadPremiumState) {
                return StateScreen.wait(context);
              } else if (state is SuccessPremiumState) {
                return Stack(
                  children: [
                    _screenIsOK(state, themeNotifier),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('data')
                    )
                  ],
                );
              } else {
                return StateScreen.error(context);
              }
            },
          )
        ],
      ),
    );
  }

  _screenIsOK(SuccessPremiumState state, ThemeNotifier themeNotifier) {
    if((state.resEnigmatic??[]).isNotEmpty) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.w),
            child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.w,
                    childAspectRatio: 1/1.3
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.resEnigmatic?.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.w),
                    child: _item(state, index)
                  );
                }
            ),
          )
      );
    } else {
      return _listNull(themeNotifier);
    }
  }

  _item(SuccessPremiumState state, int index) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if(isPremium(context)) {
      return GestureDetector(
        onTap: ()=> controller.toDetailEnigmatic(state, index),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Hero(tag: 0, child: SizedBox(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: "${state.resEnigmatic?[index].listImage?[0].image}",
                  progressIndicatorBuilder: (context, url, progress) => ColoredBox(color: themeNotifier.systemTheme),
                  errorWidget: (context, url, error) => const SizedBox(),
                  fit: BoxFit.cover,
                )
            )),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: GradientColor.gradientBlackFade
              ),
              padding: EdgeInsets.all(8.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${state.resEnigmatic?[index].info?.name}, "
                      "${yearOld(state.resEnigmatic?[index].info?.birthday??"")}",
                      style: TextStyles.defaultStyle.setColor(themeNotifier.systemText)
                      .bold.setTextSize(16)
                  ),
                  Text("${state.resEnigmatic?[index].info?.desiredState}",
                      style: TextStyles.defaultStyle.setColor(ThemeColor.pinkColor)
                      .bold.setTextSize(16)
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: controller.getUrlPayment,
        child: Stack(
          children: [
            SizedBox(
                width: double.infinity,
                child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: CachedNetworkImage(
                      imageUrl: "${state.resEnigmatic?[index].listImage?[0].image}",
                      progressIndicatorBuilder: (context, url, progress) => ColoredBox(color: themeNotifier.systemTheme),
                      errorWidget: (context, url, error) => const SizedBox(),
                      fit: BoxFit.cover,
                    )
                )
            ),
            Column(
              children: [
                const Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 0, 30.w, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: ThemeColor.whiteIos.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(100.w)
                    ),
                    child: SizedBox(
                      height: 12.w,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 6.w, 70.w, 6.w),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: ThemeColor.whiteIos.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(100.w)
                    ),
                    child: SizedBox(
                      height: 9.w,
                      width: double.infinity,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
    }
  }

  _listNull(ThemeNotifier themeNotifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 100.w),
        GestureDetector(
          onTap: !isPremium(context) ? controller.getUrlPayment : null,
          child: SizedBox(
            width: widthScreen(context)*(!isPremium(context) ? 0.9 : 0.5),
            child: Image.asset(!isPremium(context)
                ? ThemeImage.cardPremium
                : ThemeImage.notList, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 50.w),
        Text('you don\'t have anyone like you yet',
            style: TextStyles.defaultStyle.setColor(themeNotifier.systemText)
        )
      ],
    );
  }

  _isPremiumEffect() {

  }
}
