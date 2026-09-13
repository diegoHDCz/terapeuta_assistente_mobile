import 'package:flutter_easyloading/flutter_easyloading.dart';

void showSuccessToast(String message) {
  EasyLoading.showSuccess(message, duration: const Duration(seconds: 2));
}

void showErrorToast(String message) {
  EasyLoading.showError(message, duration: const Duration(seconds: 3));
}

void showInfoToast(String message) {
  EasyLoading.showToast(message, duration: const Duration(seconds: 2));
}
