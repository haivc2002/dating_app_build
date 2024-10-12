import 'dart:async';

import 'package:dating_build/controller/premium/premium_binding.dart';
import 'package:flutter/material.dart';

import '../../bloc/bloc_premium/premium_bloc.dart';


class PremiumController with PremiumBinding {
  @override
  BuildContext context;
  PremiumController(this.context);

  Future<void> getMatches() => getMatchesBinding();

  void getEnigmatic() => getEnigmaticBinding();

  void gotoDetail(SuccessPremiumState state, int index) => gotoDetailBinDing(state, index);

  void getGotoViewChat(SuccessPremiumState state, int index) => getGotoViewChatBinding(state, index);

  void getUrlPayment() => getUrlPaymentBinding();

  void lifecycleState(AppLifecycleState state) => lifecycleStateBinding(state);

  void toDetailEnigmatic(SuccessPremiumState state, int index) => toDetailEnigmaticBiding(state, index);
}