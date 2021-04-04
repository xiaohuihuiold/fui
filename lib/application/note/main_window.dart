import 'package:flutter/material.dart';
import '/storage/local_storage.dart';

/// 记事本窗口
class MainWindow extends StatefulWidget {
  @override
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = LocalStorage.note.text ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    LocalStorage.note.text = _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      expands: true,
      maxLines: null,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(8.0),
        border: InputBorder.none,
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }
}
