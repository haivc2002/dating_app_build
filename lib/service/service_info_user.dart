import 'package:dating_build/service/url/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../common/textstyles.dart';
import '../model/model_info_user.dart';
import '../theme/theme_color.dart';
import '../tool_widget_custom/popup_custom.dart';

class ServiceInfoUser {
  String url = Api.getInfo;

  late Dio dio;
  ServiceInfoUser() {
    dio = Dio();
    dio.interceptors.add(PrettyDioLogger());
  }

  Future<ModelInfoUser> info(int idUser, BuildContext context) async {
    final response = await dio.get('$url?idUser=$idUser');
    if(response.statusCode == 200) {
      return ModelInfoUser.fromJson(response.data);
    } else {
      if(context.mounted) {
        PopupCustom.showPopup(
          context,
          listOnPress: [()=> Navigator.pop(context)],
          listAction: [Text('Ok', style: TextStyles.defaultStyle.bold.setColor(ThemeColor.blueColor))]
        );
      }
      throw Exception('failed to load data');
    }
  }
}