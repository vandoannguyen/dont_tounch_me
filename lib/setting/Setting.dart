import 'package:flutter/material.dart';
import 'package:init_app/common/Common.dart';
import 'package:init_app/password/SetPassword.dart';
import 'package:init_app/utils/CallNativeUtils.dart';
import 'package:init_app/utils/IntentAnimation.dart';

import '../main.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  var isSetPass = false;

  var isSetFlash = false;

  bool isSetVibration = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("adslkjaslkdjlasjdasjdioqwueoiqweiuqwyeqopiwueyqweuqopiweuqiowe");
    isSetPass = pref.getBool(Common.SEF_CHECK_IS_PASSWORD);
    print(isSetPass);
    if (isSetPass == null) isSetPass = false;
    print(isSetPass);
    print("iahdskljuahjsdfhlaksjdfhkl;ajhrfpqwiueyrpqowierj;ákhdf");
    isSetFlash = pref.getBool(Common.SEF_CHECK_IS_FLASH);
    if (isSetFlash == null) isSetFlash = false;
    isSetVibration = pref.getBool(Common.SEF_CHECK_IS_VIBRATION);
    if (isSetVibration == null) isSetVibration = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              height: 0.5,
              color: Colors.grey,
            ),
            customItemButton(
              leftIcon: Icon(Icons.lock),
              title: "Set PIN",
              rightIcon: Switch(
                value: isSetPass,
                onChanged: (value) {
                  setPass(context, value);
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
              leftIcon: Icon(Icons.highlight),
              title: "Flash light with alarm",
              rightIcon: Switch(
                value: isSetFlash,
                onChanged: (value) {
                  if (value) {
                    setFlash();
                  } else {
                    pref.setBool(Common.SEF_CHECK_IS_FLASH, value);
                    setState(() {
                      isSetFlash = value;
                    });
                  }
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
                leftIcon: Icon(Icons.vibration),
                title: "Vibration when alarm",
                rightIcon: Switch(
                  value: isSetVibration,
                  onChanged: (value) {
                    if (value) {
                      setVibration();
                    } else {
                      pref.setBool(Common.SEF_CHECK_IS_VIBRATION, value);
                      setState(() {
                        isSetVibration = value;
                      });
                    }
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                )),
            ExpansionTile(
              leading: Icon(Icons.ring_volume),
              title: Text("Ring tones"),
              children: <Widget>[
                itemExplandTitle(
                  onTapItem: () {
                    print("Setting");
                    setDefaultRingtone();
                  },
                  title: "Ringtone default",
                ),
                itemExplandTitle(
                  onTapItem: () {
                    print("áodapsodkaosdasdasd");
                    setCustomRingtone();
                  },
                  title: "Ringtone custom",
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  itemExplandTitle({onTapItem, title}) {
    return GestureDetector(
      onTap: onTapItem,
      child: Container(
        height: 50,
        width: double.infinity,
        padding: EdgeInsets.only(left: 50, top: 15, bottom: 15),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
                color: Colors.grey, style: BorderStyle.solid, width: 0.5)),
        child: Text(
          title,
          style: lableStyle(),
        ),
      ),
    );
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

  lableStyle() {
    return TextStyle(fontSize: 17, color: Colors.black87);
  }

  void setPass(BuildContext context, value) async {
    print("pkppkpkpasd");
    if (value) {
      var status = await IntentAnimation.intentNomal(
          context: context,
          screen: SetPassword(),
          option: IntentAnimationOption.ZOOM_ROLATE,
          duration: Duration(milliseconds: 500));
      if (status != "not ok")
        setState(() {
          isSetPass = true;
        });
      else
        setState(() {
          isSetPass = false;
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
          isSetPass = value;
        });
      }
    }
  }

  void setFlash() async {
    var check = await pref.setBool(Common.SEF_CHECK_IS_FLASH, true);
    if (check)
      setState(() {
        isSetFlash = true;
      });
  }

  void setVibration() async {
    var check = await pref.setBool(Common.SEF_CHECK_IS_VIBRATION, true);
    if (check)
      setState(() {
        isSetVibration = true;
      });
  }

  void setDefaultRingtone() {
    print("setting");
    pref.setString(Common.SEF_RING_TONE, "default");
    CallNativeUtils.invokeMethod(
        method: "toast", aguments: {"mess": "Set ring tone is default"});
  }

  void setCustomRingtone() {
    CallNativeUtils.invokeMethod(method: "openMucis");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
