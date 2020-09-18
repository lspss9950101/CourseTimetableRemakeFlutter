import 'package:course_timetable_remake/Resources.dart';
import 'package:flutter/material.dart';
import 'generated/l10n.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MainPageDrawer extends StatefulWidget {
  final void Function(MainPageCallBackMSG msg, dynamic arg) callback;
  final bool darkMode;
  final CourseLayout courseLayout;

  MainPageDrawer({Key key, this.callback, this.darkMode, this.courseLayout=const CourseLayout.light()}) : super(key: key);

  @override
  State createState() => _MainPageDrawerState();
}

class _MainPageDrawerState extends State<MainPageDrawer> {
  bool darkMode;

  Widget getConstrainedListTile(
          {String title,
          TextStyle titleStyle,
          IconData icon,
          Widget trailing,
          GestureTapCallback onTap}) =>
      Container(
        height: 45,
        child: ListTile(
          title: Text(
            title,
            style: titleStyle.apply(color: widget.courseLayout.secondaryColor),
          ),
          leading: icon == null
              ? null
              : Icon(
                  icon,
                  color: widget.courseLayout.secondaryColor,
                ),
          trailing: trailing,
          onTap: onTap,
        ),
      );

  List<Widget> getCoursesOperations(List copiedCourses, List selectedSession) {
    List result = List<Widget>()
      ..add(
        getConstrainedListTile(
          title: selectedSession.length > 1
              ? S.of(context).mainPageDrawerAddEdit
              : S.of(context).mainPageDrawerAddEditSingle,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: OMIcons.edit,
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerCopy,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: Icons.content_copy,
        ),
      )
      ..add(
        getConstrainedListTile(
          title: selectedSession.length > 1
              ? S.of(context).mainPageDrawerPaste
              : S.of(context).mainPageDrawerPasteSingle,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: Icons.content_paste,
        ),
      )
      ..add(
        getConstrainedListTile(
          title: selectedSession.length > 1
              ? S.of(context).mainPageDrawerDelete
              : S.of(context).mainPageDrawerDeleteSingle,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: OMIcons.delete,
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerDeleteAll,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: OMIcons.deleteForever,
        ),
      );
    if (copiedCourses.length <= 0) result.removeAt(2);

    return result;
  }

  List<Widget> getSettings() {
    List result = List<Widget>()
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerDarkMode,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: OMIcons.brightness2,
          trailing: Switch(
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
                widget.callback(
                    MainPageCallBackMSG.SET_DARK_MODE, darkMode);
              });
            },
          ),
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerSessionSetting,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: Icons.event_note,
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerGeneralSettings,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: Icons.settings,
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerWidgetSettings,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: OMIcons.settingsApplications,
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerOutputAsImage,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: Icons.add_photo_alternate,
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerSaveLoadProfile,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: OMIcons.save,
        ),
      );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    darkMode = widget.darkMode;
    return Drawer(
      child: Container(
        color: widget.courseLayout.primaryColor,
        child: ScrollConfiguration(
        behavior: _DrawerListViewBehaviour(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(S.of(context).appTitle),
            ),
            /*getConstrainedListTile(
                title: S.of(context).mainPageDrawerGeneralOperations,
                titleStyle: Theme.of(context).textTheme.subtitle1),
            ...getCoursesOperations([], []),*/
            getConstrainedListTile(
              title: S.of(context).mainPageDrawerSetting,
              titleStyle: Theme.of(context).textTheme.subtitle1,
            ),
            ...getSettings(),
          ],
        ),
      ),),
    );
  }
}

class _DrawerListViewBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
