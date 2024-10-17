
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_notifier.dart';
import '../../bloc/bloc_home/home_bloc.dart';
import '../../bloc/bloc_profile/edit_bloc.dart';
import '../../common/city_cover.dart';
import '../../common/scale_screen.dart';
import '../../common/textstyles.dart';
import '../../controller/profile_controller/edit_profile_controller.dart';
import '../../controller/profile_controller/update_model.dart';
import '../../model/model_info_user.dart';
import '../../service/access_photo_gallery.dart';
import '../../theme/theme_color.dart';
import '../../theme/theme_image.dart';
import '../../tool_widget_custom/appbar_custom.dart';
import '../../tool_widget_custom/item_card.dart';
import '../../tool_widget_custom/press_hold.dart';
import '../../tool_widget_custom/press_hold_menu.dart';
import 'edit_more_info_screen.dart';
import 'item_photo.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = 'editProfileScreen';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late AccessPhotoGallery accessPhotoGallery;
  late EditProfileController controller;

  @override
  void initState() {
    super.initState();
    accessPhotoGallery = AccessPhotoGallery(context);
    controller = EditProfileController(context);
    UpdateModel.modelInfoUser = ModelInfoUser();
  }

  @override
  void dispose() {
    super.dispose();
    controller.timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: themeNotifier.systemTheme,
        body: Stack(
          children: [
            AppBarCustom(
              title: 'Edit profile',
              textStyle: TextStyles.defaultStyle.bold.appbarTitle,
              leadingIcon: IconButton(
                onPressed: () => controller.backAndUpdate(setState),
                icon: Icon(CupertinoIcons.back, color: themeNotifier.systemText),
              ),
              bodyListWidget: [
                BlocBuilder<HomeBloc, HomeState>(builder: (context, homeState) {
                  if(homeState.info?.info?.name == null || homeState.info?.info?.name == '') {
                    return _error();
                  } else {
                    return Column(
                      children: [
                        _boxImage(homeState.info!.listImage!),
                        itemInfo(homeState),
                        itemInfoMore(themeNotifier, homeState),
                      ],
                    );
                  }
                })
              ],
            ),
            _loadUpdate(themeNotifier)
          ],
        ),
      ),
    );
  }

  Widget itemInfo(HomeState homeState) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PressHold(
            function: ()=> controller.popupName(homeState),
            child: ItemCard(
                titleCard: '${homeState.info?.info?.name}',
                listWidget: [Text(cityCover(homeState), style: TextStyles.defaultStyle.setColor(themeNotifier.systemText))],
                iconRight: Icons.arrow_forward_ios,
                onTap: ()=> controller.popupName(homeState)
            ),
          ),
          PressHold(
            function: ()=> controller.popupWork(homeState),
            child: ItemCard(
              iconTitle: Icon(Icons.work_outline, color: themeNotifier.systemText.withOpacity(0.4)),
              titleCard: 'Work',
              listWidget: [Text('${homeState.info?.info?.word}', style: TextStyles.defaultStyle.setColor(themeNotifier.systemText))],
              iconRight: Icons.arrow_forward_ios,
              onTap: ()=> controller.popupWork(homeState),
            ),
          ),
          PressHoldMenu(
            onPressedList: List.generate(5, (index) => ()=> controller.activatedAcademicLevel(index, homeState)),
            menuAction: controller.listAcademicLevel,
            onTap: ()=> controller.popupAcademicLevel(),
            child: ItemCard(
              iconTitle: Icon(Icons.home_work_outlined, color: themeNotifier.systemText.withOpacity(0.4)),
              titleCard: 'Academic level',
              listWidget: [Text('${homeState.info?.info?.academicLevel}', style: TextStyles.defaultStyle.setColor(themeNotifier.systemText))],
              iconRight: Icons.arrow_forward_ios,
            ),
          ),
          PressHoldMenu(
            onPressedList: List.generate(controller.listPurpose.length,
              (index) => ()=> controller.activatedPurpose(index, homeState)
            ),
            onTap: ()=> controller.popupPurpose(),
            menuAction: const ['Dating', 'Talk', 'Relationship'],
            child: ItemCard(
              iconTitle: Icon(CupertinoIcons.square_stack_3d_up, color: themeNotifier.systemText.withOpacity(0.4)),
              titleCard: 'Why are you here?',
              listWidget: [Text('${homeState.info?.info?.desiredState}', style: TextStyles.defaultStyle.setColor(themeNotifier.systemText))],
              iconRight: Icons.arrow_forward_ios,
            )
          ),
          PressHold(
            function: ()=> controller.popupAbout(homeState),
            child: ItemCard(
              iconTitle: Icon(Icons.edit_outlined, color: themeNotifier.systemText.withOpacity(0.4)),
              titleCard: 'A little about yourself',
              listWidget: [Text('${homeState.info?.info?.describeYourself}', style: TextStyles.defaultStyle.setColor(themeNotifier.systemText))],
              iconRight: Icons.arrow_forward_ios,
              onTap: ()=> controller.popupAbout(homeState),
            ),
          ),
          Text('More information about me', style: TextStyles.defaultStyle.bold.setTextSize(17.sp).setColor(ThemeColor.pinkColor)),
        ],
      ),
    );
  }

  Widget itemInfoMore(ThemeNotifier themeNotifier, HomeState state) {
    final infoMore = state.info?.infoMore;
    return GestureDetector(
      onTap: ()=> Navigator.pushNamed(context, EditMoreInfoScreen.routeName),
      child: Container(
        color: themeNotifier.systemThemeFade,
        child: Column(
          children: [
            SizedBox(height: 10.w),
            itemComponentInfoMore(Icons.height, 'height', '${infoMore?.height}'),
            itemComponentInfoMore(Icons.wine_bar, 'wine', '${infoMore?.wine}'),
            itemComponentInfoMore(Icons.smoking_rooms, 'smoking', '${infoMore?.smoking}'),
            itemComponentInfoMore(Icons.ac_unit_sharp, 'Zodiac', '${infoMore?.zodiac}'),
            itemComponentInfoMore(Icons.account_balance, 'Religion', '${infoMore?.religion}'),
            itemComponentInfoMore(Icons.person, 'Character', 'not'),
            itemComponentInfoMore(Icons.home, 'Hometown', '${infoMore?.hometown}'),
            SizedBox(height: 10.w),
          ],
        ),
      ),
    );
  }

  Widget itemComponentInfoMore(IconData iconData, String title, String data) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
      child: Row(
        children: [
          Icon(iconData, color: themeNotifier.systemText.withOpacity(0.4)),
          SizedBox(width: 20.w),
          Text(title, style: TextStyles.defaultStyle.bold.setColor(themeNotifier.systemText)),
          const Spacer(),
          Text(data, style: TextStyles.defaultStyle.setColor(themeNotifier.systemText))
        ],
      ),
    );
  }

  Widget _error() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Column(
      children: [
        SizedBox(height: heightScreen(context)/5),
        SizedBox(
          width: widthScreen(context)*0.7,
          child: Image.asset(ThemeImage.error),
        ),
        SizedBox(height: 20.w),
        Text('Error! Failed to load data!', style: TextStyles.defaultStyle.setColor(themeNotifier.systemText))
      ],
    );
  }

  Widget _boxImage(List<ListImage> listImage) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    List<ListImage> preparedListImage = List<ListImage>.generate(6, (index) {
      return index < listImage.length ? listImage[index] : ListImage(id: null, idUser: null, image: null);
    });
    return Container(
        height: widthScreen(context),
        width: widthScreen(context),
        padding: EdgeInsets.all(10.w),
        color: themeNotifier.systemThemeFade,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: BlocBuilder<EditBloc, EditState>(
                        builder: (context, state) {
                          return Center(
                            child: Hero(
                              tag: 'keyAVT',
                              child: ItemPhoto(
                                size: widthScreen(context)*0.60,
                                backgroundUpload: preparedListImage[0].image,
                                onTap: ()=> preparedListImage[0].image == null
                                    ? accessPhotoGallery.updateImage(0)
                                    : controller.onOption(preparedListImage[0], 0, preparedListImage[0].id)
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                  Expanded(
                      child: Column(
                        children: [
                          itemAddImage(1, preparedListImage),
                          itemAddImage(2, preparedListImage),
                        ],
                      )
                  )
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  itemAddImage(3, preparedListImage),
                  itemAddImage(4, preparedListImage),
                  itemAddImage(5, preparedListImage),
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget itemAddImage(int index, List<ListImage> preparedListImage) {
    return Expanded(
      child: BlocBuilder<EditBloc, EditState>(
        builder: (context, state) {
          return Center(
            child: ItemPhoto(
              size: widthScreen(context) * 0.28,
              backgroundUpload: preparedListImage[index].image,
              onTap: ()=> preparedListImage[index].image == null
                ? accessPhotoGallery.updateImage(index)
                : controller.onOption(preparedListImage[index], index, preparedListImage[index].id)
            ),
          );
        },
      ),
    );
  }

  Widget _loadUpdate(ThemeNotifier themeNotifier) {
    return Visibility(
      visible: controller.isLoading,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
        child: Center(
          child: SizedBox(
            height: 6.w,
            width: 160.w,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.w),
                  border: Border.all(color: themeNotifier.systemText)
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100.w),
                        child: SizedBox(
                          height: 3.w, width: controller.valueLoading/5.w,
                          child: ColoredBox(
                            color: themeNotifier.systemText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
