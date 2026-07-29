import 'package:flutter/material.dart';

import '../../extensions/build_context_extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.titleStyle,
    this.leading,
  });

  final String title;
  final TextStyle? titleStyle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: titleStyle ?? context.textTheme.displayMedium),
      leading: leading,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
