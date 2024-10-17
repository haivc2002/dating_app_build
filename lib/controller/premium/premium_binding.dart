import 'package:dating_build/argument_model/argument_match.dart';
import 'package:dating_build/bloc/bloc_home/home_bloc.dart';
import 'package:dating_build/bloc/bloc_message/detail_message_bloc.dart';
import 'package:dating_build/bloc/bloc_premium/premium_bloc.dart';
import 'package:dating_build/common/global.dart';
import 'package:dating_build/model/model_create_payment.dart';
import 'package:dating_build/model/model_is_check_new_state.dart';
import 'package:dating_build/model/model_req_match.dart';
import 'package:dating_build/model/model_response_list_pairing.dart';
import 'package:dating_build/model/model_response_match.dart';
import 'package:dating_build/model/model_unmatched_users.dart';
import 'package:dating_build/service/exception.dart';
import 'package:dating_build/service/service_match.dart';
import 'package:dating_build/service/service_payment.dart';
import 'package:dating_build/service/service_update.dart';
import 'package:dating_build/theme/theme_config.dart';
import 'package:dating_build/tool_widget_custom/bottom_sheet_custom.dart';
import 'package:dating_build/tool_widget_custom/popup_custom.dart';
import 'package:dating_build/ui/detail/detail_enigmatic_screen.dart';
import 'package:dating_build/ui/home/match_popup_screen.dart';
import 'package:dating_build/ui/message/view_chat_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../argument_model/arguments_detail_model.dart';
import '../../common/format_amount.dart';
import '../../common/textstyles.dart';
import '../../model/model_info_user.dart' as info_user;
import '../../theme/theme_color.dart';
import '../../theme/theme_icon.dart';
import '../../tool_widget_custom/button_widget_custom.dart';
import '../../ui/detail/detail_screen.dart';

mixin PremiumBinding {
  BuildContext get context;

  ServiceMatch service = ServiceMatch();
  ServiceUpdate serviceUpdate = ServiceUpdate();
  ServicePayment servicePayment = ServicePayment();
  int idUser = Global.getInt(ThemeConfig.idUser);
  late AnimationController controller;
  late Animation<double> blurAnimation;
  double scaleValue = 1.0;
  bool _isScaled = false;
  bool isVisible = false;

  final durationDefault = 500;
  bool _openedPaymentURL = false;

  // todo: public

  void gotoDetailBinDing(SuccessPremiumState state, int index) async {
    final dataInfo = state.resMatches?[index].info;
    final dataListImage = state.resMatches?[index].listImage;
    final dataInfoMore = state.resMatches?[index].infoMore;

    info_user.Info info = info_user.Info(
      lon: dataInfo?.lon,
      lat: dataInfo?.lat,
      name: dataInfo?.name,
      word: dataInfo?.word,
      describeYourself: dataInfo?.describeYourself,
      birthday: dataInfo?.birthday,
      academicLevel: dataInfo?.academicLevel,
      desiredState: dataInfo?.desiredState,
    );

    List<info_user.ListImage> listImage = [];
    for(int i=0; i< dataListImage!.length; i++) {
      listImage.add(info_user.ListImage(
        image: dataListImage[i].image,
      ));
    }

    info_user.InfoMore infoMore = info_user.InfoMore(
        hometown: dataInfoMore?.hometown,
        height: dataInfoMore?.height,
        zodiac: dataInfoMore?.zodiac,
        smoking: dataInfoMore?.smoking,
        wine: dataInfoMore?.wine,
        religion: dataInfoMore?.religion
    );
    await Navigator.pushNamed(context, DetailScreen.routeName,
        arguments: ArgumentsDetailModel(
            idUser: state.resMatches?[index].idUser,
            info: info,
            infoMore: infoMore,
            listImage: listImage,
            keyHero: index,
            notFeedback: false
        )
    );
    await Future.delayed(const Duration(milliseconds: 500));
    _isCheckNewState(state.resMatches?[index].idUser ?? 0, state, index);
  }

  Future<void> getMatchesBinding() async {
    _onLoad();
    ModelResponseListPairing response = await service.listPairing(idUser);
    if(response.result == 'Success') {
      List<Matches> matches = response.matches ?? [];
      _onSuccess(matches: matches);
    } else {
      _onError();
    }
  }

  void getEnigmaticBinding() async {
    ModelUnmatchedUsers response =  await service.listUnmatchedUsers(idUser);
    if(response.result == 'Success') {
      List<UnmatchedUsers> enigmatic = response.unmatchedUsers ?? [];
      if(context.mounted) _onSuccess(enigmatic: enigmatic);
    } else {
      _onError();
    }
  }

  void getGotoViewChatBinding(SuccessPremiumState state, int index) async {
    final dataInfo = state.resMatches?[index].info;
    final list = state.resMatches?[index].listImage;
    final dataInfoMore = state.resMatches?[index].infoMore;
    info_user.Info info = info_user.Info(
      lon: dataInfo?.lon,
      lat: dataInfo?.lat,
      name: dataInfo?.name,
      word: dataInfo?.word,
      describeYourself: dataInfo?.describeYourself,
      birthday: dataInfo?.birthday,
      academicLevel: dataInfo?.academicLevel,
      desiredState: dataInfo?.desiredState,
    );

    List<info_user.ListImage> listImage = [];
    for(int i=0; i< list!.length; i++) {
      listImage.add(info_user.ListImage(
        image: list[i].image,
      ));
    }

    info_user.InfoMore infoMore = info_user.InfoMore(
        hometown: dataInfoMore?.hometown,
        height: dataInfoMore?.height,
        zodiac: dataInfoMore?.zodiac,
        smoking: dataInfoMore?.smoking,
        wine: dataInfoMore?.wine,
        religion: dataInfoMore?.religion
    );
    if(context.mounted) context.read<DetailMessageBloc>().add(DetailMessageEvent(response: []));
    await Navigator.pushNamed(context, ViewChatScreen.routeName, arguments: ArgumentsDetailModel(
        keyHero: 0,
        idUser: state.resMatches?[index].idUser,
        info: info,
        listImage: listImage,
        infoMore: infoMore,
        notFeedback: false
    ));
    await Future.delayed(const Duration(milliseconds: 500));
    _isCheckNewState(state.resMatches?[index].idUser ?? 0, state, index);
  }

  void getUrlPaymentBinding() async {
    final response = await servicePayment.create(Global.getInt(ThemeConfig.idUser).toString());
    if(response is Success<ModelCreatePayment, Exception>) {
      if(response.value.amount != null) {
        ModelCreatePayment data = response.value;
        _onSuccess(responsePayment: data);
        _popupPayment(response.value.amount??0, response.value.source??'');
      } else {
        _onError();
      }
    }
  }

  void lifecycleStateBinding(AppLifecycleState state, setState) {
    if(state == AppLifecycleState.resumed && _openedPaymentURL) {
      _checkPaymentBinding(setState);
      _openedPaymentURL = false;
    }
  }

  void toDetailEnigmaticBiding(SuccessPremiumState state, int index) {
    final dataInfo = state.resEnigmatic?[index].info;
    final list = state.resEnigmatic?[index].listImage;
    final dataInfoMore = state.resEnigmatic?[index].infoMore;
    info_user.Info info = info_user.Info(
      lon: dataInfo?.lon,
      lat: dataInfo?.lat,
      name: dataInfo?.name,
      word: dataInfo?.word,
      describeYourself: dataInfo?.describeYourself,
      birthday: dataInfo?.birthday,
      academicLevel: dataInfo?.academicLevel,
      desiredState: dataInfo?.desiredState,
    );

    List<info_user.ListImage> listImage = [];
    for(int i=0; i< list!.length; i++) {
      listImage.add(info_user.ListImage(
        image: list[i].image,
      ));
    }

    info_user.InfoMore infoMore = info_user.InfoMore(
        hometown: dataInfoMore?.hometown,
        height: dataInfoMore?.height,
        zodiac: dataInfoMore?.zodiac,
        smoking: dataInfoMore?.smoking,
        wine: dataInfoMore?.wine,
        religion: dataInfoMore?.religion
    );

    Navigator.pushNamed(context, DetailEnigmaticScreen.routeName,
        arguments: ArgumentsDetailModel(
            keyHero: 0,
            idUser: state.resEnigmatic?[index].idUser,
            info: info,
            listImage: listImage,
            infoMore: infoMore,
            notFeedback: null
        )
    ).then((id) {
      if (id != null) _onMatch(id as int, state, index);
    });
  }

  void initEffectPremiumBinding(TickerProvider vsync) {
    controller = AnimationController(
      duration: Duration(milliseconds: durationDefault),
      vsync: vsync,
    );
    blurAnimation = Tween<double>(begin: 0, end: 50).animate(controller);
  }

  // todo: private

  void _onLoad() => context.read<PremiumBloc>().add(LoadPremiumEvent());

  void _onSuccess({List<Matches>? matches, List<UnmatchedUsers>? enigmatic, ModelCreatePayment? responsePayment}) {
    if(context.mounted) {
      context.read<PremiumBloc>().add(SuccessPremiumEvent(
          resMatches: matches,
          resEnigmatic: enigmatic,
          responsePayment: responsePayment
      ));
    }
  }

  void _onError() {}

  Future<void> _isCheckNewState(int keyMatchValue, SuccessPremiumState state, int index) async {
    ModelIsCheckNewState req = ModelIsCheckNewState(keyMatch: keyMatchValue, idUser: idUser);
    final response = await serviceUpdate.checkNewState(req);
    if(response is Success<void, Exception>) {
      List<Matches> repo = List.from(state.resMatches ?? []);
      repo[index].newState = 0;
      _onSuccess(matches: repo);
    } else if (response is Failure<void, Exception>){
      final error = response.exception;
      if (kDebugMode) print(error);
    }
  }

  void _popupPayment(int amount, String url) {
    BottomSheetCustom.showCustomBottomSheet(context,
        backgroundColor: ThemeColor.blackColor,
        circular: 0,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Divider(color: ThemeColor.blackColor.withOpacity(0.1)),
                SizedBox(height: 20.w),
                Row(
                  children: [
                    Image.asset(ThemeIcon.iconApp, height: 50.w, width: 50.w, fit: BoxFit.cover),
                    SizedBox(width: 20.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date date premium', style: TextStyles.defaultStyle.bold.setColor(ThemeColor.whiteColor).setTextSize(17.sp)),
                        Text('Date date - make friends and date', style: TextStyles.defaultStyle.setColor(ThemeColor.whiteColor))
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(
                      'Start date today', style: TextStyles.defaultStyle.bold.setColor(ThemeColor.whiteColor),
                    )),
                    Expanded(child: Text(
                      '${formatAmount(amount)}VNĐ\n+vat', style: TextStyles.defaultStyle.setColor(ThemeColor.whiteColor),
                      textAlign: TextAlign.end,
                    ))
                  ],
                ),
                Divider(color: ThemeColor.whiteColor.withOpacity(0.3)),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.w),
                  child: Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(ThemeIcon.iconVnpay, height: 40, width: 40, fit: BoxFit.cover)
                      ),
                      SizedBox(width: 20.w),
                      Text('Vnpay e-wallet', style: TextStyles.defaultStyle.setColor(ThemeColor.whiteColor))
                    ],
                  ),
                ),
                Divider(color: ThemeColor.blackColor.withOpacity(0.3)),
                const Spacer(),
                ButtonWidgetCustom(
                    textButton: 'register',
                    color: ThemeColor.whiteColor,
                    radius: 100.w,
                    styleText: TextStyles.defaultStyle.bold.setColor(ThemeColor.blackColor),
                    onTap: () => _actionUrlToViewWeb(url)
                )
              ],
            ),
          ),
        )
    );
  }

  void _actionUrlToViewWeb(url) async {
    Navigator.pop(context);
    final action = Uri.parse(url);
    _openedPaymentURL = true;
    await launchUrl(action);
  }

  void _onMatch(int id, SuccessPremiumState state, int index) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if(id >= 0) {
      ServiceMatch addMatch = ServiceMatch();
      ModelReqMatch requestMatch = ModelReqMatch(
        idUser: Global.getInt(ThemeConfig.idUser),
        keyMatch: id,
      );
      ModelResponseMatch response = await addMatch.match(requestMatch);
      if(response.result == 'Success' && context.mounted) {
        if(response.newState == true) {
          int index = state.resEnigmatic?.indexWhere((value)=> id == value.idUser) ?? 0;
          String image = state.resEnigmatic?[index].listImage?[0].image ?? '';
          Navigator.pushNamed(context, MatchPopupScreen.routeName,
              arguments: ArgumentMatch(image: image, idUser: id)
          );
        }
        List<UnmatchedUsers> resEnigmatic = List.from(state.resEnigmatic ?? []);
        resEnigmatic.removeAt(index);
        context.read<PremiumBloc>().add(SuccessPremiumEvent(resEnigmatic: resEnigmatic));
      } else {
        if(context.mounted) {
          PopupCustom.showPopup(context,
              content: const Text('The server is busy!'),
              listOnPress: [(context)=> Navigator.pop(context)],
              listAction: [Text('Ok', style: TextStyles.defaultStyle.bold.setColor(ThemeColor.blueColor))]
          );
        }
      }
    }
  }

  void _isPremiumEffect(setState) {
    setState(() {
      _isScaled = !_isScaled;
      scaleValue = _isScaled ? 1.5 : 1.0;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _isScaled = !_isScaled;
      setState(() => scaleValue = 1.0);
    });
  }

  void _onVisible(setState) async {
    setState(()=> isVisible = true);
    await Future.delayed(Duration(milliseconds: durationDefault*2));
    setState(()=> isVisible = false);
  }

  void _checkPaymentBinding(setState) async {
    final response = await servicePayment.checkPayment(idUser);
    if(response is Success<String, Exception> && context.mounted) {
      if(response.value != "Error") {
        final oldInfo = context.read<HomeBloc>().state.info;
        info_user.ModelInfoUser newInfo = oldInfo ?? info_user.ModelInfoUser();
        if(_isPremium(response.value)) {
          newInfo.info?.deadline = response.value;
          context.read<HomeBloc>().add(HomeEvent(info: oldInfo));
          _onVisible(setState);
          _isPremiumEffect(setState);
          controller.forward().then((_) {
            controller.reverse();
          });
        }
      } else {
        if(context.mounted) {
          PopupCustom.showPopup(
            context,
            content: Text("Payment failed, you have not made payment", style: TextStyles.defaultStyle),
            listOnPress: [(context)=> Navigator.pop(context)],
            listAction: [Text("Ok", style: TextStyles.defaultStyle.bold.setColor(ThemeColor.blueColor))]
          );
        }
      }
    } else {
      _onError();
    }
  }

  bool _isPremium(String? value) {
    if (value == null) {
      return false;
    }

    try {
      final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
      DateTime dateValue = dateFormat.parse(value);

      if (dateValue.isAfter(DateTime.now())) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}