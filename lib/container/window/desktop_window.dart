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
    return Center(
      child: ElevatedButton(
        child: Text('open'),
        onPressed: () {
          WindowContainer.of(context).open(
            WindowConfiguration(
              title: '测试',
              position: Offset(50, 20),
              builder: (_) {
                return Container(
                  color: Colors.redAccent,
                  child: Text('Hello Window!'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
