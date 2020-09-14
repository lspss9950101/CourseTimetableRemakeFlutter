import 'package:flutter/material.dart';
import 'generated/l10n.dart';

class MainPageDrawer extends StatefulWidget {
  @override
  State createState() => _MainPageDrawerState();
}

class _MainPageDrawerState extends State {
  bool darkMode = false;

  List<Widget> getCoursesOperations(List copiedCourses, List selectedSession) {
    List result = List<Widget>()
      ..add(
        ListTile(
          title: Text(
            selectedSession.length > 1
                ? S.of(context).mainPageDrawerAddEdit
                : S.of(context).mainPageDrawerAddEditSingle,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(
            Icons.edit,
          ),
        ),
      )
      ..add(
        ListTile(
          title: Text(
            S.of(context).mainPageDrawerCopy,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(
            Icons.content_copy,
          ),
        ),
      )
      ..add(
        ListTile(
          title: Text(
            selectedSession.length > 1
                ? S.of(context).mainPageDrawerPaste
                : S.of(context).mainPageDrawerPasteSingle,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(
            Icons.content_paste,
          ),
        ),
      )
      ..add(
        ListTile(
          title: Text(
            selectedSession.length > 1
                ? S.of(context).mainPageDrawerDelete
                : S.of(context).mainPageDrawerDeleteSingle,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(
            Icons.delete,
          ),
        ),
      )
      ..add(
        ListTile(
          title: Text(
            S.of(context).mainPageDrawerDeleteAll,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(Icons.delete_forever),
        ),
      );
    if (copiedCourses.length <= 0) result.removeAt(2);

    return result;
  }

  List<Widget> getSettings() {
    List result = List<Widget>()
      ..add(
        ListTile(
          title: Text(
            S.of(context).mainPageDrawerDarkMode,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(Icons.brightness_3),
          trailing: Switch(
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
          ),
        ),
      )
      ..add(
        ListTile(
          title: Text(
            S.of(context).mainPageDrawerSessionSetting,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(Icons.event_note),
        ),
      )
      ..add(
        ListTile(
          title: Text(
            S.of(context).mainPageDrawerGeneralSettings,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(Icons.settings),
        ),
      )
      ..add(
        ListTile(
          title: Text(
            S.of(context).mainPageDrawerWidgetSettings,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(Icons.settings_applications),
        ),
      )
      ..add(
        ListTile(
          title: Text(
            S.of(context).mainPageDrawerOutputAsImage,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          leading: Icon(Icons.add_photo_alternate),
        ),
      );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(S.of(context).appTitle),
          ),
          ListTile(
            title: Text(S.of(context).mainPageDrawerGeneralOperations,
                style: Theme.of(context).textTheme.subtitle1),
          ),
          ...getCoursesOperations([], []),
          ListTile(
            title: Text(
              S.of(context).mainPageDrawerSetting,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ...getSettings(),
        ],
      ),
    );
  }
}
