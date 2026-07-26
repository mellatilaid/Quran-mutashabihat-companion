import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App top bar (AppBar) for the Mutashabihat app.
/// 56px height with optional back button and trailing action button.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBackPressed;
  final Widget? trailingAction;
  final bool showBack;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppTopBar({
    super.key,
    this.title,
    this.onBackPressed,
    this.trailingAction,
    this.showBack = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark ? const Color(0xFF1B5E20) : const Color(0xFF1B5E20));
    final fgColor = foregroundColor ?? Colors.white;

    return AppBar(
      elevation: 0,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.newsreader(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            )
          : null,
      actions: trailingAction != null ? [trailingAction!] : null,
    );
  }
}
