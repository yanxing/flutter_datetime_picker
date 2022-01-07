import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker_no_dialog.dart';

///Created by 李双祥 on 2022/1/7.
///不以弹窗形式直接展示时间选择
class NoDialogDatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NoDialogDatePageState();
}

class _NoDialogDatePageState extends State<NoDialogDatePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DatePickerNoDialog.showDatePicker(
              minTime: DateTime(1940, 1, 1),
              maxTime: DateTime.now(),
              theme: DatePickerTheme(
                  backgroundColor: Colors.white,
                  itemStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
              onChanged: (date) {
                print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
              },
              currentTime: DateTime(DateTime.now().year-20,05,04),
              locale: LocaleType.zh)
        ],
      ),
    );
  }
}
