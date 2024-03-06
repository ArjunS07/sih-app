import 'package:flutter/material.dart';

showStandardAlertDialog(BuildContext context, String loadingMessage) {
  AlertDialog alert = AlertDialog(
    content: SizedBox(
      width: 100.0,
      height: 100.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(loadingMessage)
          ],
        ),
      ),
    ),
  );
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
