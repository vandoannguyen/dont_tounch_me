import 'package:flutter/material.dart';
import 'package:init_app/common/Common.dart';
import 'package:init_app/home/HomePresenter.dart';
import 'package:init_app/home/HomeViewModel.dart';
import 'package:init_app/home/MainBody.dart';
import 'package:init_app/password/SetPassword.dart';
import 'package:init_app/setting/Setting.dart';
import 'package:init_app/utils/BaseView.dart';
import 'package:init_app/utils/CallNativeUtils.dart';
import 'package:init_app/utils/IntentAnimation.dart';

import '../main.dart';
import 'DrawerButton.dart';

class HomePage extends StatelessWidget implements BaseView {
  bool isOn = false;
  HomePresenter _presenter;
  HomeViewModel _viewModel;
  GlobalKey<ScaffoldState> scfKey;

  @override
  Widget build(BuildContext context) {
    _viewModel = new HomeViewModel();
    _presenter = new HomePresenter(_viewModel);
    scfKey = new GlobalKey();
    Common.widthOfScreen = MediaQuery.of(context).size.width;
    Common.heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scfKey,
      drawer: Drawer(
        elevation: 4,
        semanticLabel: "Demo",
        child: Container(
//          color: Color.fromRGBO(108, 115, 255, 1),
          color: Color(0xFF222386),
          child: SafeArea(child: drawerButton(context)),
        ),
      ),
      body: Container(
        height: Common.heightOfScreen,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(children: <Widget>[
                MainBody(_viewModel, (isOn) {}),
                Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        scfKey.currentState.openDrawer();
                      },
                      child: Container(
                        color: Colors.transparent,
                        height: 50,
                        width: 50,
                        child: Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                      ),
                    )),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ButtomButton(context, _viewModel),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void updateUI(dynamic) {
    // TODO: implement updateUI
  }

  drawerButton(BuildContext context) {
    return DrawerButton(context, _viewModel);
  }
}

class ButtomButton extends StatefulWidget {
  BuildContext ctx;
  HomeViewModel _viewModel;

  ButtomButton(this.ctx, this._viewModel);

  @override
  _ButtomButtonState createState() => _ButtomButtonState();
}

class _ButtomButtonState extends State<ButtomButton> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget._viewModel.isSetPass = pref.getBool(Common.SEF_CHECK_IS_PASSWORD);
    if (widget._viewModel.isSetPass == null) {
      pref.setBool(Common.SEF_CHECK_IS_PASSWORD, false);
      widget._viewModel.isSetPass = false;
    }
    widget._viewModel.isSetCharge = pref.getBool(Common.SEF_CHECK_IS_PIN);
    if (widget._viewModel.isSetCharge == null) {
      pref.setBool(Common.SEF_CHECK_IS_PIN, false);
      widget._viewModel.isSetCharge = false;
    }
    if (widget._viewModel.isSetCharge) {
      CallNativeUtils.invokeMethod(
          method: "chargeSate", aguments: {"isSet": true});
    }
    widget._viewModel.isFlash = pref.getBool(Common.SEF_CHECK_IS_FLASH);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setPassword(context);
            },
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
//                        boxShadow: [
//                          BoxShadow(
//                            color: Colors.grey[300],
//                            blurRadius: 4,
//                            spreadRadius: 4,
//                          )
//                        ],
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Icon(
                      Icons.lock,
                      color: widget._viewModel.isSetPass != null &&
                              widget._viewModel.isSetPass
                          ? Colors.red[400]
                          : Colors.blue[300],
                      size: 35,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Password",
                    textAlign: TextAlign.center,
                    style: titleStyle(),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setFlash(context);
            },
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
//                        boxShadow: [
//                          BoxShadow(
//                            color: Colors.grey[300],
//                            blurRadius: 4,
//                            spreadRadius: 4,
//                          )
//                        ],
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Icon(
                      Icons.highlight,
                      color: widget._viewModel.isFlash != null &&
                              widget._viewModel.isFlash
                          ? Colors.red[400]
                          : Colors.blue[300],
                      size: 35,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Flash",
                    textAlign: TextAlign.center,
                    style: titleStyle(),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setCharge(context);
            },
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
//                        boxShadow: [
//                          BoxShadow(
//                            color: Colors.grey[300],
//                            blurRadius: 4,
//                            spreadRadius: 4,
//                          )
//                        ],
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Icon(
                      Icons.battery_charging_full,
                      color: widget._viewModel.isSetCharge != null &&
                              widget._viewModel.isSetCharge
                          ? Colors.red[400]
                          : Colors.blue[300],
                      size: 35,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Set Battery",
                    textAlign: TextAlign.center,
                    style: titleStyle(),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setting(context);
            },
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
//                        boxShadow: [
//                          BoxShadow(
//                            color: Colors.grey[300],
//                            blurRadius: 4,
//                            spreadRadius: 4,
//                          )
//                        ],
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Icon(
                      Icons.settings,
                      color: Colors.blue[300],
                      size: 35,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Setting",
                    textAlign: TextAlign.center,
                    style: titleStyle(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
//    );
  }

  titleStyle() {
    return TextStyle(fontSize: 16, color: Colors.white);
  }

  void setPassword(context) async {
    if (!widget._viewModel.isSetPass) {
      var check = await IntentAnimation.intentNomal(
          context: context,
          screen: SetPassword(),
          option: IntentAnimationOption.ZOOM,
          duration: Duration(milliseconds: 500));
      if (check != "not ok") {
        widget._viewModel.isSetPass = !widget._viewModel.isSetPass;
      }
    } else {
//      set rồi thì k set kiểm tra xem có chùng với mk k
      var check = await IntentAnimation.intentNomal(
          context: context,
          screen: SetPassword(
            check: true,
          ),
          option: IntentAnimationOption.ZOOM,
          duration: Duration(milliseconds: 500));
      if (check == pref.getString(Common.SEF_PASS)) {
        widget._viewModel.isSetPass = !widget._viewModel.isSetPass;
      }
    }
    pref.setBool(Common.SEF_CHECK_IS_PASSWORD, widget._viewModel.isSetPass);
    setState(() {});
  }

  void setFlash(BuildContext context) {
    if (widget._viewModel.isFlash == null) widget._viewModel.isFlash = false;
    widget._viewModel.isFlash = !widget._viewModel.isFlash;
    setState(() {});

    pref.setBool(Common.SEF_CHECK_IS_FLASH, widget._viewModel.isFlash);
  }

  void setCharge(BuildContext context) {
    if (widget._viewModel.isSetCharge == null)
      widget._viewModel.isSetCharge = false;
    widget._viewModel.isSetCharge = !widget._viewModel.isSetCharge;
    setState(() {});
    if (widget._viewModel.isSetCharge) {
      CallNativeUtils.invokeMethod(
          method: "chargeSate", aguments: {"isSet": true});
    } else
      CallNativeUtils.invokeMethod(
          method: "chargeSate", aguments: {"isSet": false});

    pref.setBool(Common.SEF_CHECK_IS_PIN, widget._viewModel.isSetCharge);
  }

  void setting(context) async {
    var result = await IntentAnimation.intentNomal(
        context: context,
        screen: Setting(),
        option: IntentAnimationOption.RIGHT_TO_LEFT,
        duration: Duration(milliseconds: 500));
//    if (result != "not ok") {
//      setState(() {
//        widget._viewModel.isSetPass = true;
//      });
//    }
  }
}
