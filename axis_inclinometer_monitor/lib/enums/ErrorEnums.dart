import 'package:flutter/material.dart';

enum ErrorCode {
  ExRG01,
  ExRG02,
  ExRG03,
  ExRGXX,
}

enum ErrorSeverity {
  INFO,
  WARNING,
  CRITICAL,
}

extension ErrorCodeExt on ErrorCode {

  Map<dynamic, dynamic> get ext {
    switch(this) {
      case ErrorCode.ExRGXX:
        return {'code': 'ExRGXX', 'severity': ErrorSeverity.CRITICAL, 'message': 'No, no no! You are a bad boy! We can\'t have you traipsing around willy-nilly all over this application. You are a naughty, naughty boy and will be punished!', 'tint': Colors.blue};
      case ErrorCode.ExRG01:
        return {'code': 'ExRG01', 'severity': ErrorSeverity.INFO, 'message': 'Oooops, you\'ve tried to access a screen that doesn\'t exist!', 'tint': Colors.red};
      case ErrorCode.ExRG02:
        return {'code': 'ExRG02', 'severity': ErrorSeverity.WARNING, 'message': 'Oooops, you\'ve accessed a screen that doesn\'t exist!', 'tint': Colors.amber};
      case ErrorCode.ExRG03:
        return {'code': 'ExRG03', 'severity': ErrorSeverity.WARNING, 'message': 'Oooops, you\'ve accessed a screen that doesn\'t exist!', 'tint': Colors.blue};
    }
  }

}