import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Share note button with copy to clipboard functionality.
/// Shows "Copied" checkmark for 1.5 seconds after copying.
class ShareNoteButton extends StatefulWidget {
  final String textToCopy;
  final VoidCallback? onCopied;
  final String label;

  const ShareNoteButton({
    super.key,
    required this.textToCopy,
    this.onCopied,
    this.label = 'Share',
  });

  @override
  State<ShareNoteButton> createState() => _ShareNoteButtonState();
}

class _ShareNoteButtonState extends State<ShareNoteButton> {
  bool _isCopied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.textToCopy));

    setState(() {
      _isCopied = true;
    });

    widget.onCopied?.call();

    // Reset after 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isCopied = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0F6B62); // teal
    final successColor = const Color(0xFF4CAF50); // green

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _copyToClipboard,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isCopied ? successColor : primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isCopied ? Icons.check : Icons.share,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                _isCopied ? 'Copied' : widget.label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
