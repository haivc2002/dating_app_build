
import 'package:dating_build/service/url/api.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../model/model_info_user.dart';
import '../model/model_request_auth.dart';

class ServiceLogin {
  String url = Api.login;
  String urlLogout = Api.logout;
  String urlLoginWithGoogle = Api.loginWithGoogle;

  late Dio dio;
  ServiceLogin() {
    dio = Dio();
    dio.interceptors.add(PrettyDioLogger());
  }

  Future<ModelInfoUser> login(ModelRequestAuth req) async {
    final request = await dio.post(url,
      data: req.toJson()
    );
    if(request.statusCode == 200) {
      return ModelInfoUser.fromJson(request.data);
    } else {
      throw Exception('Failed to request Data');
    }
  }

  Future<ModelInfoUser> logout(int idUser) async {
    final request = await dio.post(urlLogout, data: {"idUser": idUser});
    if(request.statusCode == 200) {
      return ModelInfoUser.fromJson(request.data);
    } else {
      throw Exception('Failed to request Data');
    }
  }

  Future<ModelInfoUser> loginWithGoogle(String? email) async {
    final request = await dio.post(urlLoginWithGoogle, data: {"email": email});
    if(request.statusCode == 200) {
      return ModelInfoUser.fromJson(request.data);
    } else {
      throw Exception('Failed to request Data');
    }
  }
}