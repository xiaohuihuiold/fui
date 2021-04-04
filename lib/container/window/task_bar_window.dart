import 'package:flutter/material.dart';

import '../window_container.dart';

const kTaskBarHeight = 48.0;

/// 任务栏窗口
class TaskBarWindow extends StatefulWidget {
  @override
  _TaskBarWindowState createState() => _TaskBarWindowState();
}

class _TaskBarWindowState extends State<TaskBarWindow> {
  @override
  Widget build(BuildContext context) {
    // 任务栏分隔
    Widget result = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _TaskBarWindowStart(),
        Expanded(child: _TaskBarWindowList()),
      ],
    );
    return Container(
      height: kTaskBarHeight,
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: result,
    );
  }
}

/// 开始菜单
class _TaskBarWindowStart extends StatefulWidget {
  @override
  __TaskBarWindowStartState createState() => __TaskBarWindowStartState();
}

class __TaskBarWindowStartState extends State<_TaskBarWindowStart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FlutterLogo(),
      ),
    );
  }
}

/// 窗口管理
class _TaskBarWindowList extends StatefulWidget {
  @override
  __TaskBarWindowListState createState() => __TaskBarWindowListState();
}

class __TaskBarWindowListState extends State<_TaskBarWindowList> {
  @override
  Widget build(BuildContext context) {
    WindowContainerStatus windowContainerStatus = WindowContainerStatus.of(context);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: windowContainerStatus.groupList.length,
      itemBuilder: (_, index) {
        MapEntry<String, List<WindowConfigureData>> group =
            windowContainerStatus.groupList[index];
        bool focused = group.value.indexWhere(
                (window) => window == windowContainerStatus.topWindow) !=
            -1;
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            onTap: () {
              group.value.first.minimize();
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: focused ? Colors.white60 : Colors.black26,
              ),
              child: Text(group.value.first.title),
            ),
          ),
        );
      },
    );
  }
}
