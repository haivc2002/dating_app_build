import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/bloc_home/home_bloc.dart';

bool isPremium(BuildContext context) {
  final home = context.read<HomeBloc>().state;
  String? value = home.info?.info?.deadline;
  print("value $value");
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
