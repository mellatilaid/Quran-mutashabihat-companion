import 'package:flutter/material.dart';

/// Audio play button with play/pause and progress bar.
/// 40px progress bar with 100ms increment controls.
class AudioPlayButton extends StatefulWidget {
  final VoidCallback? onPlayPressed;
  final VoidCallback? onPausePressed;
  final ValueChanged<Duration>? onProgressChanged;
  final Duration totalDuration;
  final Duration currentPosition;
  final bool isPlaying;

  const AudioPlayButton({
    Key? key,
    this.onPlayPressed,
    this.onPausePressed,
    this.onProgressChanged,
    this.totalDuration = const Duration(minutes: 5),
    this.currentPosition = const Duration(seconds: 0),
    this.isPlaying = false,
  }) : super(key: key);

  @override
  State<AudioPlayButton> createState() => _AudioPlayButtonState();
}

class _AudioPlayButtonState extends State<AudioPlayButton> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _updateSliderValue();
  }

  @override
  void didUpdateWidget(AudioPlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPosition != widget.currentPosition) {
      _updateSliderValue();
    }
  }

  void _updateSliderValue() {
    _sliderValue = widget.totalDuration.inMilliseconds > 0
        ? widget.currentPosition.inMilliseconds.toDouble() /
            widget.totalDuration.inMilliseconds.toDouble()
        : 0.0;
  }

  void _onSliderChanged(double value) {
    final newPosition =
        Duration(milliseconds: (value * widget.totalDuration.inMilliseconds).toInt());
    widget.onProgressChanged?.call(newPosition);
  }

  void _incrementProgress() {
    final newPosition = widget.currentPosition + const Duration(milliseconds: 100);
    if (newPosition <= widget.totalDuration) {
      widget.onProgressChanged?.call(newPosition);
    }
  }

  void _decrementProgress() {
    final newPosition = widget.currentPosition - const Duration(milliseconds: 100);
    if (newPosition >= Duration.zero) {
      widget.onProgressChanged?.call(newPosition);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0F6B62); // teal

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2422) : const Color(0xFFFFFFFF),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3428) : const Color(0xFFE2DAC7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button and increment/decrement controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _decrementProgress,
                color: primaryColor,
                tooltip: 'Back 100ms',
              ),
              IconButton(
                icon: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: widget.isPlaying
                    ? widget.onPausePressed
                    : widget.onPlayPressed,
                color: primaryColor,
                iconSize: 32,
                tooltip: widget.isPlaying ? 'Pause' : 'Play',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _incrementProgress,
                color: primaryColor,
                tooltip: 'Forward 100ms',
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          SizedBox(
            height: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Slider(
                  value: _sliderValue,
                  onChanged: _onSliderChanged,
                  min: 0,
                  max: 1,
                  activeColor: primaryColor,
                  inactiveColor: primaryColor.withValues(alpha: 0.3),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(widget.currentPosition),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _formatDuration(widget.totalDuration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
