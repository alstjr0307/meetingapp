import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'HomePage.dart';

void main() {
  runApp(MyApp());
  KakaoContext.clientId = "53a9680a0b7f04eee5360234993a0176";
  KakaoContext.javascriptClientId = "	647cc847bbd927526f1a15c5a70c512a";

}

class MyApp extends StatelessWidget {
  ThemeMode themeMode = ThemeMode.light;

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    const FlexScheme usedFlexScheme = FlexScheme.barossa;
    return MaterialApp(
      title: 'Flutter Demo',

      home: HomePage(),
      theme:FlexColorScheme.light(

          scheme: usedFlexScheme,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          fontFamily: 'Hanma'
      ).toTheme,
      themeMode:  themeMode,
      builder: (context, child) => Stack(
        children: [
          child!,
          DropdownAlert(position: AlertPosition.BOTTOM,)
        ],
      ),
    );
  }
}
