import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App toast notification widget.
/// Bottom-fixed 76px height with 4s auto-dismiss and optional Undo button.
class AppToast extends StatefulWidget {
  final String message;
  final VoidCallback? onUndo;
  final Duration duration;
  final VoidCallback? onDismiss;

  const AppToast({
    super.key,
    required this.message,
    this.onUndo,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
  });

  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _animationController.reverse();
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF2D3F3A)
        : const Color(0xFF0F6B62); // dark teal
    final fgColor = Colors.white;

    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: fgColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.onUndo != null)
                TextButton(
                  onPressed: widget.onUndo,
                  child: Text(
                    'Undo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE3B45C), // gold
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper to show app toast at bottom of screen.
void showAppToast(
  BuildContext context, {
  required String message,
  VoidCallback? onUndo,
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      left: 16,
      right: 16,
      child: AppToast(
        message: message,
        onUndo: onUndo,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    ),
  );

  overlay.insert(overlayEntry);
}
