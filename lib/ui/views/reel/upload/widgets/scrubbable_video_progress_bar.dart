import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ScrubbableVideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final double barHeight;
  final double knobRadius;
  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const ScrubbableVideoProgressBar({
    Key? key,
    required this.controller,
    this.barHeight = 3.0,
    this.knobRadius = 6.0,
    required this.playedColor,
    required this.bufferedColor,
    required this.backgroundColor,
    this.onDragStart,
    this.onDragEnd,
  }) : super(key: key);

  @override
  _ScrubbableVideoProgressBarState createState() =>
      _ScrubbableVideoProgressBarState();
}

class _ScrubbableVideoProgressBarState
    extends State<ScrubbableVideoProgressBar> {
  late VoidCallback _listener;
  bool _isDragging = false;
  double _dragPositionFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (!_isDragging && mounted) {
        setState(() {});
      }
    };
    if (widget.controller.value.isInitialized) {
      widget.controller.addListener(_listener);
    } else {
      widget.controller.removeListener(_listener);
      widget.controller.addListener(_listener);
    }
  }

  @override
  void didUpdateWidget(ScrubbableVideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_listener);
      if (widget.controller.value.isInitialized) {
        widget.controller.addListener(_listener);
      } else {
        widget.controller.addListener(_listener);
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  double get _playedFraction {
    if (!widget.controller.value.isInitialized ||
        widget.controller.value.duration.inMilliseconds == 0) return 0.0;
    final positionMs = widget.controller.value.position.inMilliseconds;
    final durationMs = widget.controller.value.duration.inMilliseconds;
    return positionMs / durationMs;
  }

  List<DurationRange> get _bufferedRanges {
    if (!widget.controller.value.isInitialized ||
        widget.controller.value.duration.inMilliseconds == 0) return [];
    final durationMs = widget.controller.value.duration.inMilliseconds;
    return widget.controller.value.buffered.map((range) {
      return DurationRange(
        Duration(milliseconds: range.start.inMilliseconds),
        Duration(milliseconds: range.end.inMilliseconds),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final bool hasDuration =
        widget.controller.value.duration.inMilliseconds > 0;
    final double currentFraction =
        _isDragging ? _dragPositionFraction : _playedFraction;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final knobPositionX = (currentFraction * barWidth).clamp(0.0, barWidth);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: hasDuration
              ? (details) {
                  widget.onDragStart?.call();
                  setState(() {
                    _isDragging = true;
                    _dragPositionFraction =
                        (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
                  });
                  _seekToPosition(_dragPositionFraction);
                }
              : null,
          onHorizontalDragUpdate: hasDuration
              ? (details) {
                  if (!_isDragging) return;
                  final double newDragFraction =
                      (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
                  setState(() {
                    _dragPositionFraction = newDragFraction;
                  });
                  _seekToPosition(newDragFraction);
                }
              : null,
          onHorizontalDragEnd: hasDuration
              ? (details) {
                  if (!_isDragging) return;
                  setState(() {
                    _isDragging = false;
                  });
                  widget.onDragEnd?.call();
                }
              : null,
          child: Center(
            child: Container(
              height: max(widget.barHeight, widget.knobRadius * 2),
              width: barWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: (max(widget.barHeight, widget.knobRadius * 2) / 2) -
                        (widget.barHeight / 2),
                    height: widget.barHeight,
                    child: Container(
                      color: widget.backgroundColor,
                    ),
                  ),
                  ..._bufferedRanges.map((range) {
                    final startFraction = range.start.inMilliseconds /
                        widget.controller.value.duration.inMilliseconds;
                    final endFraction = range.end.inMilliseconds /
                        widget.controller.value.duration.inMilliseconds;
                    final startX =
                        (startFraction * barWidth).clamp(0.0, barWidth);
                    final endX = (endFraction * barWidth).clamp(0.0, barWidth);

                    return Positioned(
                      left: startX,
                      width: max(0.0, endX - startX),
                      top: (max(widget.barHeight, widget.knobRadius * 2) / 2) -
                          (widget.barHeight / 2),
                      height: widget.barHeight,
                      child: Container(
                        color: widget.bufferedColor,
                      ),
                    );
                  }).toList(),
                  Positioned(
                    left: 0,
                    width: currentFraction * barWidth,
                    top: (max(widget.barHeight, widget.knobRadius * 2) / 2) -
                        (widget.barHeight / 2),
                    height: widget.barHeight,
                    child: Container(
                      color: widget.playedColor,
                    ),
                  ),
                  if (hasDuration)
                    Positioned(
                      left: knobPositionX - widget.knobRadius,
                      top: (max(widget.barHeight, widget.knobRadius * 2) / 2) -
                          widget.knobRadius,
                      child: Container(
                        width: widget.knobRadius * 2,
                        height: widget.knobRadius * 2,
                        decoration: BoxDecoration(
                          color: widget.playedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _seekToPosition(double fraction) {
    if (!widget.controller.value.isInitialized ||
        widget.controller.value.duration.inMilliseconds == 0) return;

    final Duration newPosition = Duration(
      milliseconds:
          (widget.controller.value.duration.inMilliseconds * fraction).round(),
    );

    widget.controller.seekTo(newPosition);

    if (widget.controller.value.isPlaying == false && !_isDragging) {}
  }
}
