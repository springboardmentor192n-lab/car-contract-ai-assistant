// lib/services/web_download_helper_web.dart
import 'dart:html' as html;

void downloadFile(String url, String fileName) {
  html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
}
