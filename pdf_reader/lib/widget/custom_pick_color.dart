
// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:painter/painter.dart';

class ColorPickerButton extends StatefulWidget {
  PainterController controller;
  bool background;
  double opacity;

  ColorPickerButton(
      {required this.controller,
      required this.background,
      required this.opacity});

  @override
  _ColorPickerButtonState createState() => new _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: InkWell(
          onTap: () => pickColor(
              callbackColor: (color) => setState(() => _color = color)),
          child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(100),
                color: _color,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/rainbow.png', width: 22),
                  Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          color: Colors.white),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            color: _color),
                      )),
                ],
              )),
        ));
  }

  void pickColor({required Function callbackColor}) {
    Color pickerColor = _color;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[50],
              content: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text("Choose color",
                        style: TextStyle(color: Colors.black)),
                  ),
                  BlockPicker(
                    pickerColor: pickerColor, //default color
                    onColorChanged: (Color color) {
                      setState(() => _color = color);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("Gray scale",
                        style: TextStyle(color: Colors.black)),
                  ),
                  Container(
                    width: 350,
                    child: new StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return new Slider(
                        value: widget.opacity,
                        onChanged: (double value) => setState(() {
                          widget.opacity = value;
                          _color = _color.withOpacity(value);
                        }),
                        min: 0.0,
                        max: 1.0,
                        activeColor: _color.withOpacity(widget.opacity),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("Size", style: TextStyle(color: Colors.black)),
                  ),
                  Row(children: [
                    InkWell(
                      onTap: () => setState(() {
                        widget.controller.thickness = 1.0;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: _color.withOpacity(0.0),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                color: widget.controller.thickness == 1.0
                                    ? _color
                                    : Colors.white),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  color: _color),
                            )),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() {
                        widget.controller.thickness = 4.0;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: _color.withOpacity(0.0),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                color: widget.controller.thickness == 4.0
                                    ? _color
                                    : Colors.white),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  color: _color),
                            )),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() {
                        widget.controller.thickness = 12.0;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: _color.withOpacity(0.0),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                color: widget.controller.thickness == 12.0
                                    ? _color
                                    : Colors.white),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  color: _color),
                            )),
                      ),
                    ),
                  ])
                ],
              )),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 35,
                          width: 100,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text("Cancel"),
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: InkWell(
                          onTap: () {
                            callbackColor.call(_color);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 35,
                            width: 100,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                              color: _color.withOpacity(1.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text("Confirm",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          )),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  Color get _color => widget.controller.drawColor.withOpacity(widget.opacity);

  IconData get _iconData =>
      widget.background ? Icons.format_color_fill : Icons.brush;

  set _color(Color color) {
    widget.controller.drawColor = color.withOpacity(widget.opacity);
  }
}
