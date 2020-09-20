import 'package:course_timetable_remake/EdgeFadingListView.dart';
import 'package:course_timetable_remake/Resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MaterialColorPicker extends StatefulWidget {
  final Color color;
  final CourseLayout courseLayout;
  final Function(Color) onColorChanged;
  MaterialColorPicker(this.color, {this.courseLayout=const CourseLayout.light(), this.onColorChanged, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<MaterialColorPicker> {
  int colorRootIndex = 0;
  int colorGradeIndex = 0;
  bool isAccent = false;

  static const List<Map<String, Color>> _colorRoot = [
    {
      'root': Colors.pink,
      'accent': Colors.pinkAccent,
    },
    {
      'root': Colors.red,
      'accent': Colors.redAccent,
    },
    {
      'root': Colors.deepOrange,
      'accent': Colors.deepOrangeAccent,
    },
    {
      'root': Colors.orange,
      'accent': Colors.orangeAccent,
    },
    {
      'root': Colors.amber,
      'accent': Colors.amberAccent,
    },
    {
      'root': Colors.yellow,
      'accent': Colors.yellowAccent,
    },
    {
      'root': Colors.lime,
      'accent': Colors.limeAccent,
    },
    {
      'root': Colors.lightGreen,
      'accent': Colors.lightGreenAccent,
    },
    {
      'root': Colors.green,
      'accent': Colors.greenAccent,
    },
    {
      'root': Colors.teal,
      'accent': Colors.tealAccent,
    },
    {
      'root': Colors.cyan,
      'accent': Colors.cyanAccent,
    },
    {
      'root': Colors.lightBlue,
      'accent': Colors.lightBlueAccent,
    },
    {
      'root': Colors.blue,
      'accent': Colors.blueAccent,
    },
    {
      'root': Colors.indigo,
      'accent': Colors.indigoAccent,
    },
    {
      'root': Colors.purple,
      'accent': Colors.purpleAccent,
    },
    {
      'root': Colors.deepPurple,
      'accent': Colors.deepPurpleAccent,
    },
    {
      'root': Colors.blueGrey,
    },
    {
      'root': Colors.brown,
    },
    {
      'root': Colors.grey,
    },
  ];

  static const List<int> _colorGradeRoot = [
    50,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
  ];

  static const List<int> _colorGradeAccent = [
    100,
    200,
    400,
    700,
  ];

  void initColor() {
    int rootIndex;
    int gradeIndex;
    int accentIndex;
    bool found = false;
    for(rootIndex = 0; rootIndex < _colorRoot.length; rootIndex++) {
      for (accentIndex = 0; accentIndex < 2; accentIndex++) {
        for (gradeIndex = 0; gradeIndex < (accentIndex == 0 ? _colorGradeRoot : _colorGradeAccent).length; gradeIndex++) {
          Color c = _colorRoot[rootIndex][accentIndex == 0 ? 'root' : 'accent'];
          if(c == null) continue;
          if (c is MaterialColor)
            c = (c as MaterialColor)[_colorGradeRoot[gradeIndex]];
          else
            c = (c as MaterialAccentColor)[_colorGradeAccent[gradeIndex]];
          if (c.value == widget.color.value) {
            found = true;
            break;
          }
        }
        if(found) break;
      }
      if(found) break;
    }
    colorRootIndex = rootIndex;
    colorGradeIndex = gradeIndex;
    isAccent = accentIndex == 1;
  }

  @override
  void initState() {
    super.initState();
    initColor();
  }

  Widget getColoredCircle(Color color, GestureTapCallback onTap) => Padding(
        padding: EdgeInsets.all(4),
        child: GestureDetector(
          onTap: color != null ? onTap : null,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color != null ? color : Colors.transparent,
              boxShadow: color != null
                  ? [
                      BoxShadow(
                        color: Color.fromARGB(150, 70, 70, 70),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Color pickedMaterialColor = _colorRoot[colorRootIndex][isAccent ? 'accent' : 'root'];
    Color pickedColor = isAccent
        ? (pickedMaterialColor as MaterialAccentColor)[_colorGradeAccent[colorGradeIndex]]
        : (pickedMaterialColor as MaterialColor)[_colorGradeRoot[colorGradeIndex]];

    return Container(
      width: 300,
      height: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 4, 0, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COLOR :',
                  style: Theme.of(context).textTheme.headline6.apply(color: widget.courseLayout.secondaryColor),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      height: 50,
                      color: pickedColor,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                          child: Text(
                            '#' + (pickedColor.value).toRadixString(16).substring(2).toUpperCase(),
                            style: Theme.of(context).textTheme.headline6.apply(color: useWhiteForeground(pickedColor) ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: EdgeFadingListView(
                    children: _colorRoot.asMap().entries.map((e) {
                      int idx = e.key;
                      Color color = e.value['root'];
                      return getColoredCircle(color, () {
                        setState(() {
                          colorRootIndex = idx;
                          isAccent = false;
                        });
                      });
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: EdgeFadingListView(
                    children: [
                      getColoredCircle(_colorRoot[colorRootIndex]['root'], () {
                        setState(() {
                          isAccent = false;
                          colorGradeIndex = 0;
                        });
                      }),
                      getColoredCircle(_colorRoot[colorRootIndex]['accent'], () {
                        setState(() {
                          isAccent = true;
                          colorGradeIndex = 0;
                        });
                      }),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: EdgeFadingListView(
                      enabled: !isAccent,
                      children: (isAccent ? _colorGradeAccent : _colorGradeRoot).asMap().entries.map((element) {
                        int idx = element.key;
                        int grade = element.value;
                        return Padding(
                          padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                colorGradeIndex = idx;
                                widget.onColorChanged?.call(isAccent
                                    ? (_colorRoot[colorRootIndex]['accent'] as MaterialAccentColor)[grade]
                                    : (_colorRoot[colorRootIndex]['root'] as MaterialColor)[grade],);
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 250),
                              height: 50,
                              decoration: BoxDecoration(
                                color: isAccent
                                    ? (_colorRoot[colorRootIndex]['accent'] as MaterialAccentColor)[grade]
                                    : (_colorRoot[colorRootIndex]['root'] as MaterialColor)[grade],
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(150, 70, 70, 70),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
