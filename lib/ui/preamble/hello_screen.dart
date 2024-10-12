import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'animate_to_next_screen.dart';

class HelloScreen extends StatefulWidget {
  const HelloScreen({super.key});

  @override
  State<HelloScreen> createState() => _HelloScreenState();
}

class _HelloScreenState extends State<HelloScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2100), () async {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AnimateToNextScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: const rive.RiveAnimation.asset(
            'assets/n2.riv',
            fit: BoxFit.cover,
          )
      ),
    );
  }
}
