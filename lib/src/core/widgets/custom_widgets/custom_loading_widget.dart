import 'package:flutter/material.dart';
import 'package:quran_mutashibihat_app/src/core/extensions/build_context_extensions.dart';

class CustomLoadingWidget extends StatelessWidget {
  final bool transparentBackground;
  const CustomLoadingWidget({super.key, this.transparentBackground = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(context.colorScheme.primary),
        backgroundColor: context.colorScheme.onPrimary,
      ),
    );
  }
}

class CustomCircularIndicatorWithOverlay extends StatelessWidget {
  const CustomCircularIndicatorWithOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: CustomLoadingWidget(transparentBackground: true),
    );
  }
}
