// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String getUrlPort() => html.window.location.port;

String getReturnUrl() => html.window.location.href;
