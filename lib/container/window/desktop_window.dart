import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fui/container/window_container_theme.dart';

import '../../provider/theme_provider.dart';
import '../window_container.dart';

/// 桌面窗口,始终位于最底层
class DesktopWindow extends StatefulWidget {
  @override
  _DesktopWindowState createState() => _DesktopWindowState();
}

class _DesktopWindowState extends State<DesktopWindow> {
  void _openAWindow() {
    ThemeProvider.read(context).isDark = true;
    WindowContainer.of(context).open(
      WindowConfigureData(
        title: 'A Window',
        size: Size(500, 300),
        builder: (_) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              mini: true,
              child: Icon(Icons.add),
              onPressed: () {},
            ),
            body: Center(
              child: Text('count: 0'),
            ),
          );
        },
      ),
    );
  }

  void _openBWindow() {
    WindowContainer.of(context).open(
      WindowConfigureData(
        title: 'B Window',
        size: Size(150, 150),
        builder: (_) {
          return Center(
            child: Container(
              width: 50,
              height: 50,
              child: FlutterLogo(),
            ),
          );
        },
      ),
    );
  }

  void _openCWindow() {
    WindowContainer.of(context).open(
      WindowConfigureData(
        title: 'C Window',
        size: Size(400, 400),
        builder: (_) {
          return _DesktopWindowBackground();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = ThemeProvider.watch(context);
    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (themeProvider.showWallpaper) _DesktopWindowBackground(),
        _DesktopWindowApplications(),
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
    while (_circles.length < 40) {
      _circles.add(_createCircle(size));
    }
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
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
    canvas.drawRect(
        Offset.zero & size, Paint()..color = Colors.white.withOpacity(0.4));
  }

  _Circle _createCircle(Size size) {
    return _Circle(
      startTime: time,
      endTime: time + Random().nextInt(30000) + 15000,
      radius: Random().nextInt(120) + size.width / 4.0,
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

/// 应用列表
class _DesktopWindowApplications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WindowContainerStatus status = WindowContainerStatus.of(context);
    WindowContainerThemeData theme = WindowContainerTheme.of(context);
    return GridView.builder(
      itemCount: status.applications.length,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
      itemBuilder: (_, index) {
        WindowApplicationManifest application = status.applications[index];
        return InkWell(
          onDoubleTap: () {
            WindowContainer.of(context)
                .openApplication(application.applicationId);
          },
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: application.icon != null
                      ? Icon(
                          application.icon,
                          size: 48.0,
                          color: Colors.blue,
                        )
                      : FlutterLogo(),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      application.applicationName,
                      style: TextStyle(
                        color: theme.textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
