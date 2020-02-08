import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:init_app/common/Common.dart';
import 'package:init_app/home/HomeViewModel.dart';
import 'package:init_app/main.dart';
import 'package:init_app/password/SetPassword.dart';
import 'package:init_app/setting/Setting.dart';
import 'package:init_app/utils/CallNativeUtils.dart';
import 'package:init_app/utils/IntentAnimation.dart';

class DrawerButton extends StatefulWidget {
  var context;
  HomeViewModel _viewModel;

  DrawerButton(this.context, this._viewModel);

  @override
  _DrawerButtonState createState() => _DrawerButtonState();
}

class _DrawerButtonState extends State<DrawerButton> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var isPass = pref.getBool(Common.SEF_CHECK_IS_PASSWORD);
    if (isPass != null) widget._viewModel.isSetPass = isPass;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: Common.heightOfScreen / 8,
        ),
        Container(
          height: 0.5,
          color: Colors.grey,
        ),
        customItemButton(
          onTap: () {
            print("on Tap");
          },
          leftIcon: Icon(
            Icons.lock_outline,
            color: Colors.white,
          ),
          title: "Set password",
          rightIcon: Switch(
            value: widget._viewModel.isSetPass,
            onChanged: (value) {
              setPass(context, value);
//              if (value) {
//                setPass(context);
//              } else {
//                pref.setBool(Common.SEF_CHECK_IS_PASSWORD, value);
//                setState(() {
//                  widget._viewModel.isSetPass = value;
//                });
//              }
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ),
        Container(
          height: 0.5,
          color: Colors.grey,
        ),
        customItemButton(
            onTap: () {},
            leftIcon: Icon(
              Icons.battery_charging_full,
              color: Colors.white,
            ),
            title: "Notify charge",
            rightIcon: Switch(
              value: widget._viewModel.isSetCharge,
              onChanged: (value) {
                if (value) {
                  setNotifyPin(context, value);
                }
                setState(() {
                  widget._viewModel.isSetCharge = value;
                });
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            )),
        Container(
          height: 0.5,
          color: Colors.grey,
        ),
        customItemButton(
          title: "Setting",
          leftIcon: Icon(Icons.settings, color: Colors.white),
          onTap: () {
            IntentAnimation.intentBack(context: widget.context);
            settingScreen(widget.context);
          },
        ),
        Container(
          height: 0.5,
          color: Colors.grey,
        ),
        customItemButton(
            leftIcon: Icon(
              Icons.stars,
              color: Colors.yellow,
            ),
            title: "Rate",
            onTap: () {
              rate();
            }),
        Container(
          height: 0.5,
          color: Colors.grey,
        ),
        customItemButton(
            leftIcon: Icon(
              Icons.share,
              color: Colors.yellow,
            ),
            title: "Share app",
            onTap: () {
              share();
            })
      ],
    );
  }

  lableStyle() {
    return TextStyle(fontSize: 17, color: Colors.white);
  }

  customItemButton({Icon leftIcon, String title, Widget rightIcon, onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        color: Colors.transparent,
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            leftIcon,
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(title, style: lableStyle()),
            ),
            Container(child: rightIcon)
          ],
        ),
      ),
    );
  }

  void settingScreen(BuildContext context) {
    IntentAnimation.intentNomal(
        context: context,
        screen: Setting(),
        option: IntentAnimationOption.RIGHT_TO_LEFT,
        duration: Duration(milliseconds: 500));
  }

  void rate() {
    CallNativeUtils.invokeMethod(method: "rateManual");
  }

  void share() {
    Share.text("Don't tounch my phone !!!", Common.APP_LINK, 'text/plain');
  }

//  void setPass(BuildContext context) async {
//    IntentAnimation.intentBack(context: context);
//    IntentAnimation.intentNomal(
//        context: widget.context,
//        screen: SetPassword(),
//        option: IntentAnimationOption.ZOOM,
//        duration: Duration(milliseconds: 500));
//  }

  void setPass(BuildContext context, value) async {
    print("pkppkpkpasd");
    IntentAnimation.intentBack(context: context);
    if (value) {
      var status = await IntentAnimation.intentNomal(
          context: context,
          screen: SetPassword(),
          option: IntentAnimationOption.ZOOM_ROLATE,
          duration: Duration(milliseconds: 500));
      if (status != "not ok")
        setState(() {
          widget._viewModel.isSetPass = true;
        });
      else
        setState(() {
          widget._viewModel.isSetPass = false;
        });
    } else {
      var status = await IntentAnimation.intentNomal(
          context: context,
          screen: SetPassword(
            check: true,
          ),
          option: IntentAnimationOption.ZOOM_ROLATE,
          duration: Duration(milliseconds: 500));
      if (status == pref.getString(Common.SEF_PASS)) {
        pref.setBool(Common.SEF_CHECK_IS_PASSWORD, value);
        setState(() {
          widget._viewModel.isSetPass = value;
        });
      }
    }
  }

  void setNotifyPin(BuildContext context, value) {
    CallNativeUtils.invokeMethod(method: "chargeSate");
    pref.setBool(Common.SEF_CHECK_IS_PIN, value);
  }
}
