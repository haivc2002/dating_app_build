import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';

import '../../argument_model/arguments_detail_model.dart';
import '../../bloc/bloc_home/home_bloc.dart';
import '../../common/scale_screen.dart';
import '../../common/textstyles.dart';
import '../../common/year_old.dart';
import '../../controller/detail_controller.dart';
import '../../controller/home_controller.dart';
import '../../theme/theme_color.dart';
import '../../theme/theme_notifier.dart';
import '../../tool_widget_custom/appbar_custom.dart';
import '../../tool_widget_custom/item_card.dart';
import '../../tool_widget_custom/number_of_photos.dart';

class DetailScreen extends StatefulWidget {
  static const String routeName = 'detailScreen';
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  late HomeController homeController;
  late DetailController controller;

  int page = 0;
  PageController pageController = PageController();
  late ArgumentsDetailModel args;

  @override
  void initState() {
    super.initState();
    homeController = HomeController(context);
    controller = DetailController(context);
    pageController.addListener(() {
      setState(() {
        page = pageController.page!.round();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    args = ModalRoute.of(context)!.settings.arguments as ArgumentsDetailModel;
    return Scaffold(
      backgroundColor: themeNotifier.systemTheme,
      body: Stack(
        children: [
          AppBarCustom(
            title: '${args.info?.name}, ${yearOld('${args.info?.birthday}')}',
            textStyle: TextStyles.defaultStyle.appbarTitle.bold,
            bodyListWidget: [
              Stack(
                children: [
                  Hero(
                    tag: '${args.keyHero}',
                    child: SizedBox(
                      height: heightScreen(context)*0.6,
                      width: widthScreen(context),
                      child: PageView.builder(
                          controller: pageController,
                          itemCount: args.listImage?.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              '${args.listImage?[index].image}',
                              fit: BoxFit.cover,
                            );
                          }
                      ),
                    ),
                  ),
                  NumberOfPhotos(count: args.listImage?.length, currentPage: page),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.w),
                child: Column(
                  children: [
                    ItemCard(
                      titleCard: 'introduce yourself',
                      iconTitle: Icon(Icons.format_quote, color: themeNotifier.systemText),
                      fontSize: 20.sp,
                      listWidget: [
                        SizedBox(
                          width: 240.w,
                          child: Text('${args.info?.describeYourself}',
                              style: TextStyles.defaultStyle.setColor(themeNotifier.systemText)
                          ),
                        )
                      ],
                    ),
                    ItemCard(
                      fontSize: 20.sp,
                      titleCard: 'Information base',
                      iconTitle: Icon(CupertinoIcons.person_alt_circle_fill, color: themeNotifier.systemText),
                      listWidget: [
                        BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, homeState) {
                              return _infoBase(Icons.location_on_outlined,
                              ' ${homeController.calculateDistance(
                                latYou: homeState.info!.info!.lat!,
                                lonYou: homeState.info!.info!.lon!,
                                latOj: args.info!.lat!,
                                lonOj: args.info!.lon!,
                              )} away');
                            }
                        ),
                        _infoBase(Icons.school_outlined, ' ${args.info?.academicLevel}'),
                        _infoBase(Icons.work_outline, ' ${args.info?.word}'),
                      ],
                    ),
                    ItemCard(
                      fontSize: 20.sp,
                      titleCard: '${args.info?.desiredState}',
                      titleColor: ThemeColor.pinkColor,
                      iconTitle: Icon(CupertinoIcons.square_stack_3d_up, color: ThemeColor.pinkColor.withOpacity(0.5)),
                    ),
                    ItemCard(
                      fontSize: 20.sp,
                      titleCard: 'Information more',
                      iconTitle: Icon(Icons.contacts_outlined, color: themeNotifier.systemText),
                      listWidget: [
                        SizedBox(height: 20.w),
                        SizedBox(
                          width: widthScreen(context)*0.77,
                          child: Wrap(
                              direction: Axis.horizontal,
                              runSpacing: 7.w,
                              spacing: 7.w,
                              children: controller.items(args).isEmpty
                                  ? [Text('No information available', style: TextStyles.defaultStyle.setColor(themeNotifier.systemText))]
                                  : controller.items(args)
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          (args.notFeedback == null || args.notFeedback == true)
          ? Positioned(
            bottom: 0,
            child: _btnBefore(args)
          ) : const SizedBox()
        ],
      ),
    );
  }

  Widget _btnBefore(ArgumentsDetailModel args) {
    return SizedBox(
      height: 150.w,
      width: widthScreen(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _btnLeftOrRight(
              color: ThemeColor.themeLightSystem,
              onTap: ()=> args.controller?.next(swipeDirection: SwipeDirection.left),
              icon: CupertinoIcons.clear
            ),
            _btnLeftOrRight(
              border: false,
              color: ThemeColor.pinkColor,
              onTap: () {
                args.controller?.next(swipeDirection: SwipeDirection.right);
              },
              icon: Icons.favorite
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnLeftOrRight({required Color color, bool? border, required Function() onTap, required IconData icon}) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          Navigator.pop(context);
          border??true ? null : HapticFeedback.vibrate();
          await Future.delayed(const Duration(milliseconds: 300));
          onTap();
        },
        child: Container(
          height: 70.w,
          width: 70.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border??true ? Border.all(width: 2.w, color: ThemeColor.blackColor.withOpacity(0.4)) : null,
            boxShadow: [
              BoxShadow(
                color: ThemeColor.blackColor.withOpacity(0.4),
                offset: Offset(0, 5.w),
                blurRadius: 15,
                spreadRadius: 0
              )
            ]
          ),
          child: Center(
            child: Icon(icon, size: 40.sp, color: border??true ? ThemeColor.blackColor : ThemeColor.whiteColor),
          ),
        ),
      ),
    );
  }

  Widget _infoBase(IconData iconData, String data) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.w),
      child: Row(
        children: [
          Icon(iconData, color: themeNotifier.systemText.withOpacity(0.5)),
          SizedBox(width: 10.w),
          Text(data.isNotEmpty ? data : '', style: TextStyles.defaultStyle.setColor(themeNotifier.systemText))
        ],
      ),
    );
  }
}
