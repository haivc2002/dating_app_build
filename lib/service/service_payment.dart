import 'package:dating_build/service/url/api.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../model/model_create_payment.dart';
import 'exception.dart';

class ServicePayment {
  String urlCreate = Api.createPayment;

  late Dio dio;
  ServicePayment() {
    dio = Dio();
    dio.interceptors.add(PrettyDioLogger());
  }

  Future<Result<ModelCreatePayment, Exception>> create(String? idUser) async {
    final response = await dio.post(urlCreate, data: {"idUser": idUser});
    if(response.statusCode == 200) {
      final modelCreatePayment = ModelCreatePayment.fromJson(response.data);
      return Success(modelCreatePayment);
    } else {
      return Failure(Exception('Fail to request ${response.statusCode}'));
    }
  }
}