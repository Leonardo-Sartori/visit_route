import 'package:flutter_easyloading/flutter_easyloading.dart';

void showLoading(String msg) {
  EasyLoading.show(status: msg);
}

void showSuccess(String msg, {Duration? duration}) {
  EasyLoading.showSuccess(msg, duration: duration);
}

void showError(String msg) {
  EasyLoading.showError(msg, duration: Duration(seconds: 3));
}

void dismiss() {
  EasyLoading.dismiss();
}
