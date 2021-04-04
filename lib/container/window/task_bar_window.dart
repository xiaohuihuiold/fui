import 'package:flutter/material.dart';
import 'package:fui/container/window_container_theme.dart';

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
    WindowContainerThemeData theme = WindowContainerTheme.of(context);
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
      color: theme.shadowColor.withOpacity(0.8),
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
    WindowContainerStatus windowContainerStatus =
        WindowContainerStatus.of(context);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: windowContainerStatus.applicationTasks.length,
      itemBuilder: (_, index) {
        WindowApplicationData application =
            windowContainerStatus.applicationTasks.values.toList()[index];
        bool focused =
            windowContainerStatus.topWindow?.group == application.taskId;
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: PopupMenuButton<WindowConfigureData>(
            onSelected: (WindowConfigureData window) {
              window.minimize();
            },
            itemBuilder: (BuildContext context) {
              return [
                for (WindowConfigureData window
                    in windowContainerStatus.groups[application.taskId] ?? [])
                  PopupMenuItem<WindowConfigureData>(
                    value: window,
                    child: Text(window.title),
                  ),
              ];
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: focused ? Colors.white60 : Colors.black26,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (application.icon != null ||
                      application.iconUrl != null) ...[
                    Icon(
                      application.icon,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 4.0),
                  ],
                  Text(application.applicationName),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
