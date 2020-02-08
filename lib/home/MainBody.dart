import 'package:flutter/material.dart';
import 'package:init_app/common/Common.dart';
import 'package:init_app/home/HomeViewModel.dart';
import 'package:init_app/main.dart';
import 'package:init_app/password/SetPassword.dart';
import 'package:init_app/utils/CallNativeUtils.dart';
import 'package:init_app/utils/IntentAnimation.dart';

class MainBody extends StatefulWidget {
  var callback;
  HomeViewModel _viewModel;
  MainBody(this._viewModel, this.callback);

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  var serviceIsRun = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    serviceIsRun = pref.getBool(Common.SERVICE_IS_RUNNING);
    if (serviceIsRun == null) serviceIsRun = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(serviceIsRun
                  ? "assets/images/backroundred.jpg"
                  : "assets/images/backgroundblue.jpg"),
              fit: BoxFit.fill)),
      child: GestureDetector(
        onTap: () {
          if (serviceIsRun) {
            setOff(context);
          } else
            setOn();
          serviceIsRun = !serviceIsRun;
          setState(() {});
          widget.callback(serviceIsRun);
        },
        child: Container(
          width: Common.widthOfScreen / 2,
          height: Common.widthOfScreen / 2,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              serviceIsRun ? "Stop" : "Start",
              style: TextStyle(
                  color: serviceIsRun ? Colors.red : Colors.blue,
                  fontSize: 50,
                  fontWeight: FontWeight.w800),
            ),
          ),
          decoration: BoxDecoration(
              color: serviceIsRun ? Colors.red[300] : Colors.blue[300],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: serviceIsRun ? Colors.red[700] : Colors.blue[700],
                    offset: Offset(4.0, 4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0),
                BoxShadow(
                    color: serviceIsRun ? Colors.red : Colors.blue,
                    offset: Offset(-4.0, -4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0),
              ],
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[200],
                    Colors.grey[300],
                    Colors.grey[400],
                    Colors.grey[500],
                  ],
                  stops: [
                    0.05,
                    0.3,
                    0.8,
                    1
                  ])),
        ),
      ),
    );
  }

  void setOn() {
    pref.setBool(Common.SERVICE_IS_RUNNING, true);
    pref.setBool(Common.SEF_IS_CHECK_TOUNCH, true);
    CallNativeUtils.invokeMethod(method: "setNotifi");
  }

  void setOff(context) async {
    if (widget._viewModel.isSetPass)
      IntentAnimation.intentNomal(
              context: context,
              screen: SetPassword(check: true),
              option: IntentAnimationOption.ZOOM,
              duration: Duration(milliseconds: 500))
          .then((re) {
        print(pref.getString(Common.SEF_PASS));
        print(re);
        if (re == pref.getString(Common.SEF_PASS)) {
          CallNativeUtils.invokeMethod(method: "setOffNotifi");
          pref.setBool(Common.SERVICE_IS_RUNNING, false);
        }
      });
    else {
      CallNativeUtils.invokeMethod(method: "setOffNotifi");
      pref.setBool(Common.SERVICE_IS_RUNNING, false);
    }
  }
}
