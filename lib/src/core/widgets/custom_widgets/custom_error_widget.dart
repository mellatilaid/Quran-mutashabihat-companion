import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({super.key, required this.errString});

  final String errString;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(errString));
  }
}
