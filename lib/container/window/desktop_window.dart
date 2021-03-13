import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../window_container.dart';

/// 桌面窗口,始终位于最底层
class DesktopWindow extends StatefulWidget {
  @override
  _DesktopWindowState createState() => _DesktopWindowState();
}

class _DesktopWindowState extends State<DesktopWindow> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        _DesktopWindowBackground(),
        //
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                child: Text('open'),
                onPressed: () {
                  WindowContainer.of(context).open(
                    WindowConfiguration(
                      title: '测试',
                      position: Offset(50, 20),
                      builder: (_) {
                        return Container(
                          color: Colors.redAccent,
                          child: FlutterLogo(size: 280),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 桌面窗口背景
class _DesktopWindowBackground extends StatefulWidget {
  @override
  __DesktopWindowBackgroundState createState() =>
      __DesktopWindowBackgroundState();
}

class __DesktopWindowBackgroundState extends State<_DesktopWindowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late int _startTime;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(seconds: 10), vsync: this);
    _animationController.repeat();
    _startTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _CirclePainter(
              DateTime.now().millisecondsSinceEpoch - _startTime,
            ),
          );
        },
      ),
    );
  }
}

/// 圆
class _Circle {
  final double radius;
  final Color color;
  final Offset begin;
  final Offset end;
  final int startTime;
  final int endTime;

  _Circle({
    required this.radius,
    required this.color,
    required this.begin,
    required this.end,
    required this.startTime,
    required this.endTime,
  });
}

List<_Circle> _circles = [];

/// 窗口背景绘制
class _CirclePainter extends CustomPainter {
  final Paint _circlePaint = Paint()..isAntiAlias = true;
  final int time;

  _CirclePainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    while (_circles.length < 80) {
      _circles.add(_createCircle(size));
    }
    _circlePaint.blendMode = BlendMode.multiply;
    _circles.forEach((circle) {
      double progress =
          (time - circle.startTime) / (circle.endTime - circle.startTime);
      double opacity = progress < 0.5 ? progress : (1.0 - progress);
      opacity = opacity.clamp(0.0, 1.0);
      _circlePaint.color = circle.color.withOpacity(opacity);
      canvas.drawCircle(
        Offset.lerp(
          circle.begin,
          circle.end,
          progress,
        )!,
        circle.radius,
        _circlePaint,
      );
    });
    _circles.removeWhere((circle) => circle.endTime <= time);
  }

  _Circle _createCircle(Size size) {
    return _Circle(
      startTime: time,
      endTime: time + Random().nextInt(30000) + 15000,
      radius: Random().nextInt(80) + size.width / 8.0,
      color: Colors.accents[Random().nextInt(Colors.accents.length)],
      begin: Offset(
        Random().nextInt(size.width.toInt() * 2).toDouble() - size.width / 2.0,
        Random().nextInt(size.height.toInt() * 2).toDouble() -
            size.height / 2.0,
      ),
      end: Offset(
        Random().nextInt(size.width.toInt() * 2).toDouble() - size.width / 2.0,
        Random().nextInt(size.height.toInt() * 2).toDouble() -
            size.height / 2.0,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
