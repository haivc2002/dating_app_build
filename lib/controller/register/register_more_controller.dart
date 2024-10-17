import 'package:dating_build/controller/register/register_info_binding.dart';
import 'package:flutter/material.dart';

import '../../bloc/bloc_all_tap/api_all_tap_bloc.dart';
import '../profile_controller/model_list_purpose.dart';

class RegisterMoreController with RegisterInfoBinding {
  @override
  BuildContext context;

  RegisterMoreController(this.context);

  List<ModelListPurpose> listPurpose = [
    ModelListPurpose('Dating', Icons.wine_bar_sharp,
        'I want to date and have fun with that person. That\'s all'),
    ModelListPurpose('Talk', Icons.chat_bubble,
        'I want to chat and see where the relationship goes'),
    ModelListPurpose(
        'Relationship', Icons.favorite, 'Find a long term relationship'),
  ];

  Future<void> selectDate() async => selectDateBinding();

  void checkLocationPermission() async => checkLocationPermissionBiding();

  void getLocation() => getLocationBinding();

  String city(SuccessApiAllTapState state) => cityBinding(state);

  void scrollListener() => scrollListenerBinding();

  void popupPurpose() => popupPurposeBinding(listPurpose);

  void tapDismiss() => tapDismissBiding();

  void registerInfo(setState) => registerInfoBinding(setState);

}