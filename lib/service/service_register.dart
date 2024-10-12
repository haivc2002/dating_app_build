
import 'package:dating_build/service/url/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../common/textstyles.dart';
import '../model/model_base.dart';
import '../model/model_req_register_info.dart';
import '../model/model_request_auth.dart';
import '../theme/theme_color.dart';
import '../tool_widget_custom/popup_custom.dart';

class ServiceRegister {
  String url = Api.register;
  String urlApiRegisterInfo = Api.registerInfo;

  late Dio dio;
  ServiceRegister() {
    dio = Dio();
    dio.interceptors.add(PrettyDioLogger());
  }

  Future<ModelBase> register(ModelRequestAuth req, BuildContext context) async {
    final request = await dio.post(url, data: req.toJson());
    if(request.statusCode == 200) {
      return ModelBase.fromJson(request.data);
    } else {
      if(context.mounted) {
        PopupCustom.showPopup(context,
            content: Text('Error!', style: TextStyles.defaultStyle.setColor(ThemeColor.redColor)),
            listOnPress: [()=>Navigator.pop(context)],
            listAction: [Text('Ok', style: TextStyles.defaultStyle.setColor(ThemeColor.blueColor))]
        );
      }
      throw Exception('Failed to request data');
    }
  }

  Future<ModelBase> registerInfo(ModelReqRegisterInfo req, BuildContext context) async {
    final request = await dio.post(urlApiRegisterInfo, data: req.toJson());
    if(request.statusCode == 200) {
      return ModelBase.fromJson(request.data);
    } else {
      if(context.mounted) {
        PopupCustom.showPopup(context,
          content: Text('Error!', style: TextStyles.defaultStyle.setColor(ThemeColor.redColor)),
          listOnPress: [()=>Navigator.pop(context)],
          listAction: [Text('Ok', style: TextStyles.defaultStyle.setColor(ThemeColor.blueColor))]
        );
      }
      throw Exception('Failed to request data');
    }
  }

}