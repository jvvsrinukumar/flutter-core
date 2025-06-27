import 'package:logger/logger.dart';

class CustomerPrinter extends LogPrinter {
  final String className;

  CustomerPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    //final color = PrettyPrinter.levelColors[event.level];
    //final emoji = PrettyPrinter.levelEmojis[event.level];
    final level = event.level.toString().split('.').last.toUpperCase();
    final message = event.message;

    //return [color('$emoji $className: $message')];
    return ['$level : $className : $message'];
  }
}
