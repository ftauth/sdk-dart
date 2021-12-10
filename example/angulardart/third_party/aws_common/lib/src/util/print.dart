import 'package:aws_common/src/util/debug.dart';

void safePrint(Object? o) {
  if (isDebugMode) {
    print(o);
  }
}
