import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../bloc/bloc_home/home_bloc.dart';
import '../../common/global.dart';
import '../../common/scale_screen.dart';
import '../../common/textstyles.dart';
import '../../controller/home_controller.dart';
import '../../theme/theme_color.dart';
import '../../theme/theme_image.dart';
import '../../theme/theme_notifier.dart';
import '../../tool_widget_custom/button_widget_custom.dart';

class HomeComponent {
  static Widget load(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.w),
        child: SizedBox(
          height: heightScreen(context) * 0.8,
          child: Shimmer.fromColors(
            baseColor: themeNotifier.systemThemeFade,
            highlightColor: themeNotifier.systemTheme,
            child: SizedBox(
                height: heightScreen(context) * 0.8,
                width: widthScreen(context),
                child: const ColoredBox(color: ThemeColor.whiteColor)
            ),
          ),
        ),
      ),
    );
  }

  static Widget listNominationNull(BuildContext context, HomeController controller, int currentIndex) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return SizedBox(
      height: heightScreen(context)*0.8,
      child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, store) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200.w,
                  width: widthScreen(context)*0.6,
                  child: Image.asset(ThemeImage.error),
                ),
                SizedBox(height: 20.w),
                Text('Not found within', style: TextStyles.defaultStyle.setColor(themeNotifier.systemText)),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 20.w),
                  child: Slider(
                    min: 1,
                    max: 20,
                    activeColor: ThemeColor.pinkColor,
                    onChanged: (value) {
                      context.read<HomeBloc>().add(HomeEvent(currentDistance: value.toInt()));
                      Global.setInt('currentDistance', value.toInt());
                    },
                    value: store.currentDistance!.toDouble(),
                  ),
                ),
                Text('${store.currentDistance}km', style: TextStyles.defaultStyle.setColor(themeNotifier.systemText)),
                SizedBox(
                  width: widthScreen(context)/4,
                  child: ButtonWidgetCustom(
                      textButton: 'Retry',
                      styleText: TextStyles.defaultStyle.bold.whiteText,
                      color: ThemeColor.pinkColor,
                      radius: 5.w,
                      onTap: () {
                        controller.getData(store.currentDistance!);
                        context.read<HomeBloc>().add(HomeEvent(currentIndex: 0));
                        currentIndex = 0;
                        controller.page = 0;
                      }
                  ),
                ),
              ],
            );
          }
      ),
    );
  }
}

class BackGroundBlur extends StatefulWidget {
  final HomeState state;
  final BuildContext context;

  const BackGroundBlur({super.key, required this.state, required this.context});

  @override
  State<BackGroundBlur> createState() => _BackGroundBlurState();
}

class _BackGroundBlurState extends State<BackGroundBlur> {
  @override
  void didUpdateWidget(covariant BackGroundBlur oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentIndex != widget.state.currentIndex) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.state.listNomination?.nominations ?? [];
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    if (data.isNotEmpty &&
        widget.state.currentIndex != null &&
        widget.state.currentIndex! >= 0 &&
        widget.state.currentIndex! < data.length) {

      var images = data[widget.state.currentIndex!].listImage ?? [];

      if (images.isNotEmpty) {
        return SizedBox(
          height: heightScreen(context),
          width: widthScreen(context),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 5000),
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.easeOut,
            child: SizedBox(
              key: ValueKey<int>(widget.state.currentIndex!),
              height: heightScreen(context),
              width: widthScreen(context),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaY: 30, sigmaX: 30),
                child: _dataImageWidget(imageValue: images[0].image),
              ),
            ),
          ),
        );
      }
    }
    return const SizedBox();
  }

  Widget _dataImageWidget({String? imageValue}) {
    if(imageValue == null || imageValue == '') {
      return const SizedBox();
    } else {
      return CachedNetworkImage(
        imageUrl: imageValue,
        progressIndicatorBuilder: (context, url, progress) => const SizedBox(),
        errorWidget: (context, url, error) => const SizedBox(),
        fit: BoxFit.cover,
      );
    }
  }
}




