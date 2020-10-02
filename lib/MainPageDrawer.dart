import 'dart:typed_data';
import 'dart:ui' as ui;

import 'DBPreference.dart';
import 'Dialog.dart';
import 'Resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'generated/l10n.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MainPageDrawer extends StatefulWidget {
  final void Function(MainPageCallBackMSG msg, [dynamic arg]) callback;
  final bool darkMode;
  final CourseLayout courseLayout;
  final PreferenceProvider preferenceProvider;
  final GlobalKey timetableKey;
  final GlobalKey weekBarKey;

  MainPageDrawer({Key key, this.weekBarKey, this.timetableKey, this.preferenceProvider, this.callback, this.darkMode, this.courseLayout=const CourseLayout.light()}) : super(key: key);

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
          onTap: () async {
            await TimetableDialog.showSessionSettingDialog(context, widget.courseLayout);
            widget.callback(MainPageCallBackMSG.SET_SESSION);
          }
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerGeneralSettings,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: Icons.settings,
          onTap: () {
            Navigator.pop(context);
            TimetableDialog.showContextSettingDialog(context, widget.callback, widget.courseLayout);
          },
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerWidgetSettings,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: OMIcons.settingsApplications,
          onTap: () {
            Navigator.pop(context);
            TimetableDialog.showWidgetSettingDialog(context, widget.courseLayout);
          }
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerOutputAsImage,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: Icons.add_photo_alternate,
          onTap: () async {
            RenderRepaintBoundary boundary = widget.timetableKey.currentContext.findRenderObject();
            RenderRepaintBoundary weekBar = widget.weekBarKey.currentContext.findRenderObject();

            ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
            Canvas canvas = Canvas(pictureRecorder);
            canvas.drawRect(Rect.fromLTWH(0, 0, boundary.size.width, boundary.size.height+35), Paint()..color=darkMode ? Color.fromARGB(255, 250, 250, 250) : Color.fromARGB(255, 50, 50, 50,));
            canvas.drawImage(await boundary.toImage(), Offset(0, 35), Paint());
            canvas.drawImage(await weekBar.toImage(), Offset.zero, Paint());

            Size size = Size(weekBar.size.width, boundary.size.height + 35);
            ui.Image image = await pictureRecorder.endRecording().toImage(size.width.floor(), size.height.floor());
            ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            Uint8List pngBytes = byteData.buffer.asUint8List();
            if(await Permission.storage.request().isGranted) {
              print(await ImageGallerySaver.saveImage(pngBytes, quality: 100, name: 'Timetable_' + DateFormat('yyyyMMddHHmmss').format(DateTime.now())));
            }
          }
        ),
      )
      ..add(
        getConstrainedListTile(
          title: S.of(context).mainPageDrawerSaveLoadProfile,
          titleStyle: Theme.of(context).textTheme.subtitle2,
          icon: OMIcons.save,
          onTap: () {
            Navigator.pop(context);
            TimetableDialog.showPathConfigDialog(context, widget.courseLayout, widget.callback);
          }
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
