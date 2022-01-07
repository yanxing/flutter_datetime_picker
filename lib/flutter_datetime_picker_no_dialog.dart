import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_datetime_picker/src/datetime_picker_theme.dart';
import 'package:flutter_datetime_picker/src/date_model.dart';
import 'package:flutter_datetime_picker/src/i18n_model.dart';

export 'package:flutter_datetime_picker/src/datetime_picker_theme.dart';
export 'package:flutter_datetime_picker/src/date_model.dart';
export 'package:flutter_datetime_picker/src/i18n_model.dart';

typedef DateChangedCallback(DateTime time);
typedef DateCancelledCallback();
typedef String? StringAtIndexCallBack(int index);

///不以弹窗形式展示时间选择，直接返回控件
class DatePickerNoDialog{
  ///
  /// Display date picker
  ///
  static Widget showDatePicker({
    DateTime? minTime,
    DateTime? maxTime,
    DateChangedCallback? onChanged,
    locale: LocaleType.en,
    DateTime? currentTime,
    DatePickerTheme? theme,
  }) {
    return _DatePickerComponent(
      onChanged: onChanged,
      locale: locale,
      theme: theme,
      pickerModel: DatePickerModel(
        currentTime: currentTime,
        maxTime: maxTime,
        minTime: minTime,
        locale: locale,
      ),
    );
  }

  ///
  /// Display time picker
  ///
  static Widget showTimePicker({
    bool showSecondsColumn: true,
    DateChangedCallback? onChanged,
    locale: LocaleType.en,
    DateTime? currentTime,
    DatePickerTheme? theme,
  })  {
    return _DatePickerComponent(
      onChanged: onChanged,
      locale: locale,
      theme: theme,
      pickerModel: TimePickerModel(
        currentTime: currentTime,
        locale: locale,
        showSecondsColumn: showSecondsColumn,
      ),
    );
  }

  ///
  /// Display time picker  with AM/PM.
  ///
  static Widget showTime12hPicker( {
    DateChangedCallback? onChanged,
    locale: LocaleType.en,
    DateTime? currentTime,
    DatePickerTheme? theme,
  }) {
    return _DatePickerComponent(
      onChanged: onChanged,
      locale: locale,
      theme: theme,
      pickerModel: Time12hPickerModel(
        currentTime: currentTime,
        locale: locale,
      ),
    );
  }

  ///
  /// Display date&time picker.
  ///
  static Widget showDateTimePicker({
    DateTime? minTime,
    DateTime? maxTime,
    DateChangedCallback? onChanged,
    locale: LocaleType.en,
    DateTime? currentTime,
    DatePickerTheme? theme,
  }){
    return _DatePickerComponent(
      onChanged: onChanged,
      locale: locale,
      theme: theme,
      pickerModel: DateTimePickerModel(
        currentTime: currentTime,
        minTime: minTime,
        maxTime: maxTime,
        locale: locale,
      ),
    );
  }

  ///
  /// Display date picker witch custom picker model.
  ///
  static Widget showPicker({
    DateChangedCallback? onChanged,
    locale: LocaleType.en,
    BasePickerModel? pickerModel,
    DatePickerTheme? theme,
  }){
    return _DatePickerComponent(
      onChanged: onChanged,
      locale: locale,
      theme: theme,
      pickerModel: pickerModel ?? DatePickerModel(),
    );
  }
}


class _DatePickerComponent extends StatefulWidget {
  _DatePickerComponent({
    Key? key,
    required this.pickerModel,
    required this.theme,
    this.onChanged,
    this.locale,
  }) : super(key: key);

  final DateChangedCallback? onChanged;
  final LocaleType? locale;
  final DatePickerTheme? theme;
  final BasePickerModel pickerModel;

  @override
  State<StatefulWidget> createState() {
    return _DatePickerState();
  }
}

class _DatePickerState extends State<_DatePickerComponent> {
  late FixedExtentScrollController leftScrollCtrl,
      middleScrollCtrl,
      rightScrollCtrl;

  @override
  void initState() {
    super.initState();
    refreshScrollOffset();
  }

  void refreshScrollOffset() {
    leftScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentLeftIndex());
    middleScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentMiddleIndex());
    rightScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentRightIndex());
  }

  @override
  Widget build(BuildContext context) {
    DatePickerTheme theme = widget.theme!;
    return  GestureDetector(
      child: Material(
        color: theme.backgroundColor,
        child: _renderItemView(theme),
      ),
    );
  }

  void _notifyDateChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(widget.pickerModel.finalTime()!);
    }
  }

  Widget _renderColumnView(
    ValueKey key,
    DatePickerTheme theme,
    StringAtIndexCallBack stringAtIndexCB,
    ScrollController scrollController,
    int layoutProportion,
    ValueChanged<int> selectedChangedWhenScrolling,
    ValueChanged<int> selectedChangedWhenScrollEnd,
  ) {
    return Expanded(
      flex: layoutProportion,
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: theme.containerHeight,
        decoration: BoxDecoration(color: theme.backgroundColor),
        child: NotificationListener(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0 &&
                notification is ScrollEndNotification &&
                notification.metrics is FixedExtentMetrics) {
              final FixedExtentMetrics metrics =
                  notification.metrics as FixedExtentMetrics;
              final int currentItemIndex = metrics.itemIndex;
              selectedChangedWhenScrollEnd(currentItemIndex);
            }
            return false;
          },
          child: CupertinoPicker.builder(
            key: key,
            backgroundColor: theme.backgroundColor,
            scrollController: scrollController as FixedExtentScrollController,
            itemExtent: theme.itemHeight,
            selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: Colors.transparent,),
            onSelectedItemChanged: (int index) {
              selectedChangedWhenScrolling(index);
            },
            useMagnifier: true,
            itemBuilder: (BuildContext context, int index) {
              final content = stringAtIndexCB(index);
              if (content == null) {
                return null;
              }
              return Container(
                height: theme.itemHeight,
                alignment: Alignment.center,
                child: Text(
                  content,
                  style: theme.itemStyle,
                  textAlign: TextAlign.start,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _renderItemView(DatePickerTheme theme) {
    return Container(
      color: theme.backgroundColor,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: widget.pickerModel.layoutProportions()[0] > 0
                  ? _renderColumnView(
                      ValueKey(widget.pickerModel.currentLeftIndex()),
                      theme,
                      widget.pickerModel.leftStringAtIndex,
                      leftScrollCtrl,
                      widget.pickerModel.layoutProportions()[0], (index) {
                      widget.pickerModel.setLeftIndex(index);
                    }, (index) {
                      setState(() {
                        refreshScrollOffset();
                        _notifyDateChanged();
                      });
                    })
                  : null,
            ),
            Text(
              widget.pickerModel.leftDivider(),
              style: theme.itemStyle,
            ),
            Container(
              child: widget.pickerModel.layoutProportions()[1] > 0
                  ? _renderColumnView(
                      ValueKey(widget.pickerModel.currentLeftIndex()),
                      theme,
                      widget.pickerModel.middleStringAtIndex,
                      middleScrollCtrl,
                      widget.pickerModel.layoutProportions()[1], (index) {
                      widget.pickerModel.setMiddleIndex(index);
                    }, (index) {
                      setState(() {
                        refreshScrollOffset();
                        _notifyDateChanged();
                      });
                    })
                  : null,
            ),
            Text(
              widget.pickerModel.rightDivider(),
              style: theme.itemStyle,
            ),
            Container(
              child: widget.pickerModel.layoutProportions()[2] > 0
                  ? _renderColumnView(
                      ValueKey(widget.pickerModel.currentMiddleIndex() * 100 +
                          widget.pickerModel.currentLeftIndex()),
                      theme,
                      widget.pickerModel.rightStringAtIndex,
                      rightScrollCtrl,
                      widget.pickerModel.layoutProportions()[2], (index) {
                      widget.pickerModel.setRightIndex(index);
                    }, (index) {
                      setState(() {
                        refreshScrollOffset();
                        _notifyDateChanged();
                      });
                    })
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
