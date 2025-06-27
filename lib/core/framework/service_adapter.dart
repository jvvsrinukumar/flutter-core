import 'package:flutter_core/core/framework/server_error.dart';

abstract class ServiceAdapter {
  String getErrorMessage(ServerError error);
}
