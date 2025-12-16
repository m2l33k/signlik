import 'dart:math';

class CameraMock {
  static String simulateDetection() {
    final options = ['Hello', 'Thank you', 'Yes', 'No', 'Help'];
    return options[Random().nextInt(options.length)];
  }
}
