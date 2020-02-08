import 'package:flutter/material.dart';
import 'package:init_app/common/Common.dart';
import 'package:init_app/main.dart';
import 'package:init_app/utils/IntentAnimation.dart';

class SetPassword extends StatelessWidget {
  var check;

  SetPassword({this.check});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.yellow,
        child: Center(
          child: Container(
            width: Common.widthOfScreen - 200,
            child: TextField(
              onSubmitted: (value) {
                summit(context, value);
              },
              keyboardType: TextInputType.phone,
              maxLength: 6,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline),
                labelText: "Enter you pass",
              ),
            ),
          ),
        ),
      ),
    );
  }

  void summit(context, value) async {
    print(value);
    if (check == null || !check) if (value != "") {
      if (await pref.setString(Common.SEF_PASS, value)) {
        if (await pref.setBool(Common.SEF_CHECK_IS_PASSWORD, true))
          IntentAnimation.intentBack(context: context, result: value);
        else
          IntentAnimation.intentBack(context: context, result: "not ok");
      } else
        IntentAnimation.intentBack(context: context, result: "not ok");
    } else
      IntentAnimation.intentBack(context: context, result: "not ok");
    else
      IntentAnimation.intentBack(context: context, result: value);
  }
}
