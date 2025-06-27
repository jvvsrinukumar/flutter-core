import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

String logStreamName = '';

String _getLogStreamName() {
  if (logStreamName == '') {
    logStreamName = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
  }
  return logStreamName;
}

void logFlutterSystemError(dynamic logString, dynamic stackTrace) {
  var message = 'Auto Captured Error: ${logString.toString()}\n\n'
      'Auto Captured Stack Trace:\n${stackTrace.toString()}';
}

class LogService {
  late Logger localLogger;
  final String className;
  final Level configuredLogLevel; // Configured log level

  LogService(this.className, this.configuredLogLevel) {
    // if (EnvironmentConfig.environment == 'DEV') {
    //   // Initialize local Logger for DEV
    //   localLogger = Logger(
    //       printer: CustomerPrinter(className), level: configuredLogLevel);
    // } else {
    //   // Initialize CloudWatch Logger for STAGE and PROD
    // }
  }

  void error({required String message}) {
    _log(message: message, level: 'error');
  }

  void warning({required String message}) {
    _log(message: message, level: 'warning');
  }

  void info({required String message}) {
    _log(message: message, level: 'info');
  }

  void debug({required String message}) {
    _log(message: message, level: 'debug');
  }

  void _log({required String message, required String level}) {
    // Level logLevel = _getLogLevel(level);

    // if (logLevel.index >= configuredLogLevel.index) {
    //   final formattedMessage =
    //       '${level.toString().split('.').last.toUpperCase()} : $className : $message';

    //   if (EnvironmentConfig.environment == 'DEV') {
    //     localLogger.log(logLevel, message);
    //   } else {}
    // }
  }

//   static Level _getLogLevel(String level) {
//     switch (level.toLowerCase()) {
//       case 'debug':
//         return Level.debug;
//       case 'info':
//         return Level.info;
//       case 'warning':
//         return Level.warning;
//       case 'error':
//         return Level.error;
//       default:
//         return Level.info;
//     }
//   }
// }
}
