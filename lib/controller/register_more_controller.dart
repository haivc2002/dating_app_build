import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';

import '../argument_model/argument_register_info.dart';
import '../bloc/bloc_all_tap/api_all_tap_bloc.dart';
import '../bloc/bloc_auth/api_register_bloc.dart';
import '../bloc/bloc_auth/register_bloc.dart';
import '../bloc/bloc_profile/edit_bloc.dart';
import '../common/remove_province.dart';
import '../common/scale_screen.dart';
import '../common/textstyles.dart';
import '../model/model_base.dart';
import '../model/model_req_register_info.dart';
import '../model/model_request_auth.dart';
import '../model/model_request_image.dart';
import '../service/location/api_location_current.dart';
import '../service/service_add_image.dart';
import '../service/service_register.dart';
import '../theme/theme_color.dart';
import '../tool_widget_custom/bottom_sheet_custom.dart';
import '../tool_widget_custom/button_widget_custom.dart';
import '../tool_widget_custom/list_tile_custom.dart';
import '../tool_widget_custom/popup_custom.dart';
import 'all_tap_controller.dart';
import 'login_controller.dart';
import 'profile_controller/model_list_purpose.dart';

class RegisterMoreController {
  BuildContext context;
  RegisterMoreController(this.context);

  ApiLocationCurrent apiLocation = ApiLocationCurrent();
  ServiceRegister register = ServiceRegister();
  ModelReqRegisterInfo req = ModelReqRegisterInfo();
  ModelRequestImage reqImage = ModelRequestImage();
  ServiceAddImage serviceAddImage = ServiceAddImage();

  DateTime? selectedDate;
  double _blurValue = 0.0;
  bool isGranted = false;
  double appBarHeightFactor = 0.35;
  TextEditingController nameController = TextEditingController();
  DraggableScrollableController draggableScrollableController = DraggableScrollableController();
  ModelRequestAuth reqLogin = ModelRequestAuth();
  bool isLoading = false;

  List<ModelListPurpose> listPurpose = [
    ModelListPurpose('Dating', Icons.wine_bar_sharp, 'I want to date and have fun with that person. That\'s all'),
    ModelListPurpose('Talk', Icons.chat_bubble, 'I want to chat and see where the relationship goes'),
    ModelListPurpose('Relationship', Icons.favorite, 'Find a long term relationship'),
  ];

  String missingFields = '';


  Future<void> selectDate() async {
    FocusManager.instance.primaryFocus?.unfocus();

    _blurValue = 5.0;
    context.read<RegisterBloc>().add(RegisterEvent(blurValue: _blurValue));

    final DateTime? picked = await showCupertinoDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime tempPickedDate = selectedDate ?? DateTime.now();
        return BlocBuilder<RegisterBloc, RegisterState>(
          builder: (context, store) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: store.blurValue),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    backgroundColor: ThemeColor.whiteIos,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CalendarDatePicker(
                          initialDate: tempPickedDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          onDateChanged: (DateTime date) {
                            tempPickedDate = date;
                          },
                        ),
                        ButtonWidgetCustom(
                          textButton: 'Yes',
                          color: ThemeColor.blackColor,
                          radius: 100.w,
                          onTap: ()=> Navigator.of(context).pop(tempPickedDate),
                          styleText: TextStyles.defaultStyle.bold.whiteText,
                          symmetric: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      if(context.mounted) {
        context.read<RegisterBloc>().add(RegisterEvent(birthdayValue: selectedDate));
      }
    }

    _blurValue = 0.0;
    if(context.mounted) {
      context.read<RegisterBloc>().add(RegisterEvent(blurValue: _blurValue));
    }
  }

  void checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted) {
      isGranted = status.isGranted;
      getLocation();
    }
  }

  void getLocation() async {
    AllTapController allTapController = AllTapController(context);
    allTapController.getData();
  }

  String city(SuccessApiAllTapState state) {
    if(state.response?[0].state != null) {
      return RemoveProvince.cancel('${state.response?[0].state}');
    } else if(state.response?[0].city != null) {
      return '${state.response?[0].city}';
    } else {
      return 'Unknown';
    }
  }

  void scrollListener() {
    tapDismiss();
    double extent = draggableScrollableController.size;
    appBarHeightFactor = 0.35 - (0.15 * (extent - 0.65) / (1 - 0.65));
    if (appBarHeightFactor < 0.2) {
      appBarHeightFactor = 0.2;
    }
    context.read<RegisterBloc>().add(RegisterEvent(appBarHeightFactor: appBarHeightFactor));
  }

  void popupPurpose() {
    BottomSheetCustom.showCustomBottomSheet(context,
      height: widthScreen(context)*1.2,
      backgroundColor: ThemeColor.whiteIos.withOpacity(0.5),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(listPurpose.length, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.w),
                child: BlocBuilder<EditBloc, EditState>(
                  builder: (context, state) {
                    return ListTileCustom(
                      color: state.indexPurpose == index ? ThemeColor.pinkColor.withOpacity(0.5) : ThemeColor.whiteColor.withOpacity(0.3),
                      title: listPurpose[index].title,
                      iconLeading: listPurpose[index].iconLeading,
                      subtitle: listPurpose[index].subtitle,
                      onTap: ()=> context.read<EditBloc>().add(EditEvent(indexPurpose: index, purposeValue: listPurpose[index].title)),
                    );
                  }
                ),
              );
            })
          ),
        ),
      )
    );
  }

  void tapDismiss() {
    FocusScopeNode current = FocusScope.of(context);
    if (current.focusedChild != null && !current.hasPrimaryFocus) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  void registerInfo(setState) async {
    setState(() => isLoading = true);
    initModelReqRegisterInfo();
    if(isEmpty() == false) {
      setState(() => isLoading = false);
      PopupCustom.showPopup(
        context,
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Missing information: ',
            style: TextStyles.defaultStyle,
            children: [
              TextSpan(
                text: missingFields,
                style: TextStyles.defaultStyle.setColor(ThemeColor.redColor)
              ),
              const TextSpan(
                text: ' Please check again.',
              )
            ]
          ),
        ),
        listOnPress: [()=> Navigator.pop(context)],
        listAction: [Text('Ok', style: TextStyles.defaultStyle.bold.setColor(ThemeColor.blueColor))]
      );
    } else {
      ModelBase response = await register.registerInfo(req, context);
      if(response.result == 'Success') {
        addImage(setState);
      } else {
        onError(response.message??'');
      }
    }
  }

  void addImage(setState) async {
    final ArgumentRegisterInfo args = ModalRoute.of(context)!.settings.arguments as ArgumentRegisterInfo;
    LoginController loginController = LoginController(context);
    final photo = context.read<EditBloc>().state.imageUpload;
    for(int i = 0; i < (photo??[]).length; i++) {
      initModelReqAddImage(i);
      ModelBase response = await serviceAddImage.addImage(reqImage, context);
      if(response.result == 'Success' && context.mounted) {
        setState(() => isLoading = false);
        loginController.login(args.email!, args.password!);
      }
    }
  }

  bool isEmpty() {
    List missing = [];
    final photo = context.read<EditBloc>().state.imageUpload;

    if (req.birthday == null) missing.add('Birthday');
    if (req.name == null || req.name!.isEmpty) missing.add('Name');
    if (req.idUser == null) missing.add('ID User');
    if (req.gender == null || req.gender!.isEmpty) missing.add('Gender');
    if (req.desiredState == null || req.desiredState!.isEmpty) missing.add('Desired State');
    if (req.lon == null) missing.add('Longitude');
    if (req.lat == null) missing.add('Latitude');
    if(photo == null) missing.add('Image');

    missingFields = missing.join(', ');

    return missing.isEmpty;
  }

  void initModelReqRegisterInfo() {
    final registerBlocState = context.read<RegisterBloc>().state;
    final editBlocState = context.read<EditBloc>().state;
    final apiRegisterState = context.read<ApiRegisterBloc>().state;
    if(apiRegisterState is SuccessApiRegisterState) {
      req = ModelReqRegisterInfo(
        birthday: registerBlocState.birthdayValue != null ? DateFormat('dd/MM/yyyy').format(registerBlocState.birthdayValue!) : null,
        name: nameController.text,
        idUser: apiRegisterState.response?.idUser,
        gender: registerBlocState.genderValue,
        desiredState: editBlocState.purposeValue,
        lon: registerBlocState.lon,
        lat: registerBlocState.lat,
      );
    }
  }

  void initModelReqAddImage(int index) {
    final state = context.read<ApiRegisterBloc>().state;
    final photo = context.read<EditBloc>().state.imageUpload;
    if(state is SuccessApiRegisterState) {
      reqImage = ModelRequestImage(
        idUser: state.response?.idUser,
        image: photo?[index]
      );
    }
  }

  void onError(String content) {
    PopupCustom.showPopup(context,
        content: Text(content, style: TextStyles.defaultStyle),
        listOnPress: [()=>Navigator.pop(context)],
        listAction: [Text('Ok', style: TextStyles.defaultStyle.setColor(ThemeColor.blueColor).bold)]
    );
  }

}