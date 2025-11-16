import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType { info, success, error, warning }

void showCustomToast(
  BuildContext context,
  String text, {
  ToastType type = ToastType.info,
}) {
  FToast fToast = FToast();
  fToast.init(context);

  Color bgColor;
  IconData iconData;

  switch (type) {
    case ToastType.success:
      bgColor = Colors.green;
      iconData = Icons.check_circle;
      break;

    case ToastType.error:
      bgColor = const Color(0xFF9B0C0C);
      iconData = Icons.close;
      break;

    case ToastType.warning:
      bgColor = const Color(0xFFF19202);
      iconData = Icons.warning;
      break;

    case ToastType.info:
      bgColor = const Color(0xFF003D5F);
      iconData = Icons.info;
      break;
  }

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: bgColor,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: Colors.white),
        const SizedBox(width: 12.0),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.TOP,
    toastDuration: const Duration(seconds: 2),
  );
}
