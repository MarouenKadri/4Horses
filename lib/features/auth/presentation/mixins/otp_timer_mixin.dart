import 'package:flutter/widgets.dart';

// Logique de compte à rebours partagée entre les pages OTP.
// Utilisation : class _MyState extends State<MyWidget> with OtpTimerMixin<MyWidget>
mixin OtpTimerMixin<T extends StatefulWidget> on State<T> {
  int resendTimer = 60;
  bool canResend = false;

  void startResendTimer() {
    resendTimer = 60;
    canResend = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (resendTimer > 0) {
          resendTimer--;
        } else {
          canResend = true;
        }
      });
      return resendTimer > 0;
    });
  }
}
