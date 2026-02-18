import 'package:flutter/material.dart';
import 'package:ice_shield/orchestration_layer/Action/WebView/WebViewPage.dart';

class WidgetNavigatorAction {
  static void navigateExternalUrl(BuildContext context, String fullUrl) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => WebViewPage(url: fullUrl)));
  }
}
