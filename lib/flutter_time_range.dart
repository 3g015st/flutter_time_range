library flutter_time_range;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:toggle_switch/toggle_switch.dart';

typedef onSelectCallback = void Function(TimeOfDay from, TimeOfDay to);
typedef onCancelCallback = void Function();

class TimeRangePicker extends StatefulWidget {
  /// Initial value for first hour
  final int? initialFromHour;

  /// Initial value for second hour
  final int? initialToHour;

  /// Initial value for first minutes
  final int? initialFromMinutes;

  /// Initial value for second minutes
  final int? initialToMinutes;

  /// Callback which called when select button clicked / tapped
  final onSelectCallback? onSelect;

  /// Callback which called when cancel button clicked / tapped
  final onCancelCallback? onCancel;

  /// Caption for first tab
  /// default was "From"
  final String tabFromText;

  /// Caption for second tab
  /// default was "To"
  final String tabToText;

  /// Cancel button caption
  /// default was "Cancel"
  final String cancelText;

  /// Next button caption
  /// default was "Next"
  final String nextText;

  /// Back button caption
  /// default was "Back"
  final String backText;

  /// Select button caption
  /// default was select
  final String selectText;

  /// TextStyle for selected time
  final TextStyle selectedTimeStyle;

  /// TextStyle for nselected time
  final TextStyle unselectedTimeStyle;

  /// Style decoration for time container
  final BoxDecoration? timeContainerStyle;

  /// If true, user can change value of time manually with textfield
  final bool editable;

  /// If false, AM-PM toggle will show.
  /// initial time is normal DateTime and will convert into 12 hours format.
  /// output time is normal TimeOfDay
  final bool is24Format;

  /// Background color for active AM-PM toggle
  /// default was blue accent
  final Color activeBgColor;

  /// Background color for inactive AM-PM toggle
  /// default was grey
  final Color inactiveBgColor;

  /// Foreground color for active AM-PM toggle
  /// default was white
  final Color activeFgColor;

  /// Foreground color for inactive AM-PM toggle
  /// default was white
  final Color inactiveFgColor;

  /// Icon for cancel button
  final Icon? iconCancel;

  /// Icon for next button
  final Icon? iconNext;

  /// Icon for back button
  final Icon? iconBack;

  /// Icon for select button
  final Icon? iconSelect;

  /// If true, tab interaction e.g click and slide on tab will be disable
  /// default was true
  final bool disableTabInteraction;

  /// TextStyle of separator ":" in middle between hour and minutes
  final TextStyle separatorStyle;

  /// TextStyle of active tab bar
  final TextStyle activeTabStyle;

  /// TextStyle of inactive tab bar
  final TextStyle inactiveTabStyle;

  final TextStyle operationsTextStyle;

  /// Color of active tab label
  final Color activeLabelColor;

  /// Color of inactive tab label
  final Color inactiveLabelColor;

  /// Color of indicator active tab
  final Color indicatorColor;

  final int tabBarBorderRadius;

  final Color operationsOverlayColor;

  final double height;

  final TextStyle errorMessageTextStyle;

  TimeRangePicker(
      {Key? key,
      @required this.initialFromHour,
      @required this.initialToHour,
      @required this.initialFromMinutes,
      @required this.initialToMinutes,
      this.errorMessageTextStyle =
          const TextStyle(color: Colors.red, fontSize: 12),
      this.height = 400.0,
      this.tabBarBorderRadius = 0,
      this.onSelect,
      this.onCancel,
      this.tabFromText = "From",
      this.tabToText = "To",
      this.cancelText = "Cancel",
      this.nextText = "Next",
      this.backText = "Back",
      this.selectText = "Select",
      this.selectedTimeStyle =
          const TextStyle(color: Colors.blueAccent, fontSize: 30),
      this.unselectedTimeStyle =
          const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
      this.timeContainerStyle,
      this.editable = true,
      this.is24Format = true,
      this.activeBgColor = Colors.blueAccent,
      this.activeFgColor = Colors.white,
      this.inactiveBgColor = Colors.grey,
      this.inactiveFgColor = Colors.white,
      this.iconBack,
      this.iconNext,
      this.iconCancel,
      this.iconSelect,
      this.disableTabInteraction = true,
      this.separatorStyle = const TextStyle(color: Colors.black, fontSize: 30),
      this.activeTabStyle =
          const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      this.inactiveTabStyle =
          const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      this.operationsTextStyle =
          const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      this.operationsOverlayColor = Colors.blue,
      this.activeLabelColor = Colors.white,
      this.inactiveLabelColor = Colors.black,
      this.indicatorColor = Colors.blueAccent})
      : super(key: key);

  @override
  _TimeRangePickerState createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker>
    with SingleTickerProviderStateMixin {
  String errorMessage = "";
  double height = 400;
  int tabBarBorderRadius = 0;

  BorderRadius _tabBarBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(0), topRight: Radius.circular(0));

  BorderRadius _tabBarSplashBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(0), topRight: Radius.circular(0));

  late TabController _tabController;
  int _jamFrom = 0;
  int _menitFrom = 0;
  int _jamTo = 0;
  int _menitTo = 0;
  int _selectedTab = 0;
  int _maxJamValue = 23;
  int _minJamValue = 0;

  BoxDecoration defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: Colors.grey[500]!));
  var isEdit = List<bool>.empty(growable: true);
  var textControllers = List<TextEditingController>.empty(growable: true);
  var textFocus = List<FocusNode>.empty(growable: true);
  var fromIndex = 0;
  var toIndex = 0;

  @override
  void initState() {
    super.initState();

    height = widget.height;

    tabBarBorderRadius = widget.tabBarBorderRadius;

    _tabBarBorderRadius = BorderRadius.only(
        topLeft: Radius.circular(widget.tabBarBorderRadius.toDouble()),
        topRight: Radius.circular(0));

    _tabBarSplashBorderRadius = BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(widget.tabBarBorderRadius.toDouble()));

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;

        if (_selectedTab == 1) {
          _tabBarBorderRadius = BorderRadius.only(
              topRight: Radius.circular(tabBarBorderRadius.toDouble()),
              topLeft: Radius.circular(0));
          _tabBarSplashBorderRadius = BorderRadius.only(
              topRight: Radius.circular(0),
              topLeft: Radius.circular(tabBarBorderRadius.toDouble()));
        } else {
          _tabBarBorderRadius = BorderRadius.only(
              topLeft: Radius.circular(tabBarBorderRadius.toDouble()),
              topRight: Radius.circular(0));
          _tabBarSplashBorderRadius = BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(tabBarBorderRadius.toDouble()));
        }
      });
    });

    _jamFrom = widget.is24Format
        ? widget.initialFromHour!
        : widget.initialFromHour! > 12
            ? (widget.initialFromHour! - 12)
            : widget.initialFromHour!;

    _jamTo = widget.is24Format
        ? widget.initialToHour!
        : widget.initialToHour! > 12
            ? (widget.initialToHour! - 12)
            : widget.initialToHour!;

    _menitFrom = widget.initialFromMinutes!;
    _menitTo = widget.initialToMinutes!;

    if (!widget.is24Format) {
      _maxJamValue = 12;
      _minJamValue = 1;
      if (widget.initialFromHour! > 12) {
        fromIndex = 1;
      }
      if (widget.initialToHour! > 12) {
        toIndex = 1;
      }
    }

    for (int i = 0; i < 4; i++) {
      isEdit.add(false);
      textControllers.add(TextEditingController());
      textFocus.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < 4; i++) {
      textControllers[i].dispose();
      textFocus[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildContainer();
  }

  Widget buildContainer() {
    return Container(
      width: double.maxFinite,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.disableTabInteraction
              ? IgnorePointer(
                  child: Theme(
                      data: ThemeData().copyWith(
                          splashColor: widget.indicatorColor,
                          highlightColor: widget.indicatorColor),
                      child: TabBar(
                        controller: _tabController,
                        labelStyle: widget.activeTabStyle,
                        unselectedLabelStyle: widget.inactiveTabStyle,
                        indicatorColor: Colors.transparent,
                        labelColor: widget.activeLabelColor,
                        unselectedLabelColor: widget.inactiveLabelColor,
                        splashBorderRadius: _tabBarSplashBorderRadius,
                        indicator: BoxDecoration(
                            color: widget.indicatorColor,
                            borderRadius: _tabBarBorderRadius),
                        tabs: [
                          Tab(text: widget.tabFromText),
                          Tab(text: widget.tabToText)
                        ],
                      )),
                )
              : Theme(
                  data: ThemeData().copyWith(
                      splashColor: widget.indicatorColor,
                      highlightColor: widget.indicatorColor),
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: widget.activeTabStyle,
                    unselectedLabelStyle: widget.inactiveTabStyle,
                    indicatorColor: Colors.transparent,
                    labelColor: widget.activeLabelColor,
                    unselectedLabelColor: widget.inactiveLabelColor,
                    splashBorderRadius: _tabBarSplashBorderRadius,
                    indicator: BoxDecoration(
                        color: widget.indicatorColor,
                        borderRadius: _tabBarBorderRadius),
                    tabs: [
                      Tab(text: widget.tabFromText),
                      Tab(text: widget.tabToText)
                    ],
                  )),
          if (errorMessage != "")
            Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(errorMessage, style: widget.errorMessageTextStyle)),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 10),
              child: TabBarView(
                physics: widget.disableTabInteraction
                    ? NeverScrollableScrollPhysics()
                    : null,
                controller: _tabController,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 7, right: 7),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.is24Format
                              ? Container(
                                  height: 30,
                                )
                              : Padding(
                                  padding: EdgeInsets.only(bottom: 25),
                                  child: ToggleSwitch(
                                    fontSize: 12,
                                    minWidth: 90.0,
                                    minHeight: 30,
                                    cornerRadius: 20.0,
                                    activeBgColor: widget.activeBgColor,
                                    activeFgColor: widget.activeFgColor,
                                    inactiveBgColor: widget.inactiveBgColor,
                                    inactiveFgColor: widget.inactiveFgColor,
                                    labels: ['AM', 'PM'],
                                    initialLabelIndex: fromIndex,
                                    onToggle: (index) {
                                      fromIndex = index;
                                    },
                                  ),
                                ),
                          Padding(
                              padding:
                                  EdgeInsets.only(left: 10, right: 10, top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: widget.timeContainerStyle ??
                                          defaultDecoration,
                                      child: isEdit[0]
                                          ? TextField(
                                              controller: textControllers[0],
                                              focusNode: textFocus[0],
                                              textAlign: TextAlign.center,
                                              style: widget.selectedTimeStyle,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                              ],
                                              onSubmitted: (value) {
                                                setState(() {
                                                  if (value.isNotEmpty) {
                                                    if (int.parse(value) >
                                                        _maxJamValue) {
                                                      _jamFrom = _maxJamValue;
                                                    } else {
                                                      _jamFrom =
                                                          int.parse(value);
                                                    }
                                                  }

                                                  isEdit[0] = false;
                                                });
                                              },
                                            )
                                          : InkWell(
                                              onTap: () {
                                                if (widget.editable) {
                                                  setState(() {
                                                    isEdit[0] = true;
                                                    textFocus[0].requestFocus();
                                                  });
                                                }
                                              },
                                              child: NumberPicker(
                                                  minValue: _minJamValue,
                                                  maxValue: _maxJamValue,
                                                  value: _jamFrom,
                                                  zeroPad: true,
                                                  textStyle: widget
                                                      .unselectedTimeStyle,
                                                  selectedTextStyle:
                                                      widget.selectedTimeStyle,
                                                  infiniteLoop: true,
                                                  onChanged: (value) {
                                                    resetErrorMessage();
                                                    setState(() {
                                                      _jamFrom = value;
                                                    });
                                                  }),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      child: Text(":",
                                          style: widget.separatorStyle)),
                                  Expanded(
                                    child: Container(
                                      decoration: widget.timeContainerStyle ??
                                          defaultDecoration,
                                      child: isEdit[1]
                                          ? TextField(
                                              controller: textControllers[1],
                                              focusNode: textFocus[1],
                                              textAlign: TextAlign.center,
                                              style: widget.selectedTimeStyle,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                              ],
                                              onSubmitted: (value) {
                                                setState(() {
                                                  if (value.isNotEmpty) {
                                                    if (int.parse(value) > 59) {
                                                      _menitFrom = 59;
                                                    } else {
                                                      _menitFrom =
                                                          int.parse(value);
                                                    }
                                                  }

                                                  isEdit[1] = false;
                                                });
                                              },
                                            )
                                          : InkWell(
                                              onTap: () {
                                                if (widget.editable) {
                                                  setState(() {
                                                    isEdit[1] = true;
                                                    textFocus[1].requestFocus();
                                                  });
                                                }
                                              },
                                              child: NumberPicker(
                                                  minValue: 0,
                                                  maxValue: 59,
                                                  value: _menitFrom,
                                                  zeroPad: true,
                                                  textStyle: widget
                                                      .unselectedTimeStyle,
                                                  selectedTextStyle:
                                                      widget.selectedTimeStyle,
                                                  infiniteLoop: true,
                                                  onChanged: (value) {
                                                    resetErrorMessage();
                                                    setState(() {
                                                      _menitFrom = value;
                                                    });
                                                  }),
                                            ),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 7, right: 7),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.is24Format
                              ? Container(
                                  height: 30,
                                )
                              : Padding(
                                  padding: EdgeInsets.only(bottom: 35),
                                  child: ToggleSwitch(
                                    fontSize: 12,
                                    minWidth: 90.0,
                                    minHeight: 30,
                                    cornerRadius: 20.0,
                                    activeBgColor: widget.activeBgColor,
                                    activeFgColor: widget.activeFgColor,
                                    inactiveBgColor: widget.inactiveBgColor,
                                    inactiveFgColor: widget.inactiveFgColor,
                                    labels: ['AM', 'PM'],
                                    initialLabelIndex: toIndex,
                                    onToggle: (index) {
                                      toIndex = index;
                                    },
                                  ),
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: widget.timeContainerStyle ??
                                      defaultDecoration,
                                  child: isEdit[2]
                                      ? TextField(
                                          controller: textControllers[2],
                                          focusNode: textFocus[2],
                                          textAlign: TextAlign.center,
                                          style: widget.selectedTimeStyle,
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                          onSubmitted: (value) {
                                            setState(() {
                                              if (value.isNotEmpty) {
                                                if (int.parse(value) >
                                                    _maxJamValue) {
                                                  _jamTo = _maxJamValue;
                                                } else {
                                                  _jamTo = int.parse(value);
                                                }
                                              }

                                              isEdit[2] = false;
                                            });
                                          },
                                        )
                                      : InkWell(
                                          onTap: () {
                                            if (widget.editable) {
                                              setState(() {
                                                isEdit[2] = true;
                                                textFocus[2].requestFocus();
                                              });
                                            }
                                          },
                                          child: NumberPicker(
                                              minValue: _minJamValue,
                                              maxValue: _maxJamValue,
                                              value: _jamTo,
                                              zeroPad: true,
                                              textStyle:
                                                  widget.unselectedTimeStyle,
                                              selectedTextStyle:
                                                  widget.selectedTimeStyle,
                                              infiniteLoop: true,
                                              onChanged: (value) {
                                                resetErrorMessage();
                                                setState(() {
                                                  _jamTo = value;
                                                });
                                              }),
                                        ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child:
                                      Text(":", style: widget.separatorStyle)),
                              Expanded(
                                child: Container(
                                  decoration: widget.timeContainerStyle ??
                                      defaultDecoration,
                                  child: isEdit[3]
                                      ? TextField(
                                          controller: textControllers[3],
                                          focusNode: textFocus[3],
                                          textAlign: TextAlign.center,
                                          style: widget.selectedTimeStyle,
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                          onSubmitted: (value) {
                                            setState(() {
                                              if (value.isNotEmpty) {
                                                if (int.parse(value) > 59) {
                                                  _menitTo = 59;
                                                } else {
                                                  _menitTo = int.parse(value);
                                                }
                                              }

                                              isEdit[3] = false;
                                            });
                                          },
                                        )
                                      : InkWell(
                                          onTap: () {
                                            if (widget.editable) {
                                              setState(() {
                                                isEdit[3] = true;
                                                textFocus[3].requestFocus();
                                              });
                                            }
                                          },
                                          child: NumberPicker(
                                              minValue: 0,
                                              maxValue: 59,
                                              value: _menitTo,
                                              zeroPad: true,
                                              textStyle:
                                                  widget.unselectedTimeStyle,
                                              selectedTextStyle:
                                                  widget.selectedTimeStyle,
                                              infiniteLoop: true,
                                              onChanged: (value) {
                                                resetErrorMessage();
                                                setState(() {
                                                  _menitTo = value;
                                                });
                                              }),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                            widget.operationsOverlayColor),
                      ),
                      onPressed: () {
                        if (_selectedTab == 1) {
                          _tabController.animateTo(0);
                        } else {
                          widget.onCancel?.call();
                        }
                      },
                      child: Row(
                        children: [
                          _selectedTab == 0
                              ? widget.iconCancel ?? Container()
                              : widget.iconBack ?? Container(),
                          Padding(padding: EdgeInsets.only(right: 5)),
                          Text(
                              _selectedTab == 0
                                  ? widget.cancelText
                                  : widget.backText,
                              style: widget.operationsTextStyle)
                        ],
                      )),
                  TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                            widget.operationsOverlayColor),
                      ),
                      onPressed: () {
                        if (_selectedTab == 0) {
                          _tabController.animateTo(1);
                        } else {
                          if (isEdit[0]) {
                            if (textControllers[0].text.isNotEmpty) {
                              if (int.parse(textControllers[0].text) >
                                  _maxJamValue) {
                                _jamFrom = _maxJamValue;
                              } else {
                                _jamFrom = int.parse(textControllers[0].text);
                              }
                            }
                          }

                          if (isEdit[2]) {
                            if (textControllers[2].text.isNotEmpty) {
                              if (int.parse(textControllers[2].text) >
                                  _maxJamValue) {
                                _jamTo = _maxJamValue;
                              } else {
                                _jamTo = int.parse(textControllers[2].text);
                              }
                            }
                          }

                          if (isEdit[1]) {
                            if (textControllers[1].text.isNotEmpty) {
                              if (int.parse(textControllers[1].text) > 59) {
                                _menitFrom = 59;
                              } else {
                                _menitFrom = int.parse(textControllers[1].text);
                              }
                            }
                          }

                          if (isEdit[3]) {
                            if (textControllers[3].text.isNotEmpty) {
                              if (int.parse(textControllers[3].text) > 59) {
                                _menitTo = 59;
                              } else {
                                _menitTo = int.parse(textControllers[3].text);
                              }
                            }
                          }

                          var jamFr = widget.is24Format
                              ? _jamFrom
                              : fromIndex == 1
                                  ? (_jamFrom + 12)
                                  : _jamFrom;

                          var jamTo = widget.is24Format
                              ? _jamTo
                              : toIndex == 1
                                  ? (_jamTo + 12)
                                  : _jamTo;

                          if (isValidTime(
                              fromHour: jamFr,
                              fromMinute: _menitFrom,
                              toHour: jamTo,
                              toMinute: _menitTo)) {
                            widget.onSelect?.call(
                                TimeOfDay(hour: jamFr, minute: _menitFrom),
                                TimeOfDay(hour: jamTo, minute: _menitTo));
                          } else {
                            setState(() {
                              errorMessage =
                                  "Start time is greater than end time";
                            });
                          }
                        }
                      },
                      child: Row(
                        children: [
                          _selectedTab == 0
                              ? widget.iconNext ?? Container()
                              : widget.iconSelect ?? Container(),
                          Padding(padding: EdgeInsets.only(right: 5)),
                          Text(
                              _selectedTab == 0
                                  ? widget.nextText
                                  : widget.selectText,
                              style: widget.operationsTextStyle),
                        ],
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  bool isValidTime(
      {required int fromHour,
      required int fromMinute,
      required int toHour,
      required int toMinute}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, fromHour, fromMinute);
    final end = DateTime(now.year, now.month, now.day, toHour, toMinute);
    return start.compareTo(end) < 0;
  }

  void resetErrorMessage() {
    if (errorMessage != "") {
      setState(() {
        errorMessage = "";
      });
    }
  }
}
