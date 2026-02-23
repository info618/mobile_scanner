import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// A widget showing a live camera preview.
class CameraPreview extends StatelessWidget {
  /// Creates a preview widget for the given camera controller.
  const CameraPreview(this.controller, {super.key});

  /// The controller for the camera that the preview is shown for.
  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox();
    }

    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (BuildContext context, MobileScannerState value, Widget? child) {
        final cameraView = controller.buildCameraView();

        // On web the camera view is an HtmlElementView whose underlying
        // <video> element already has CSS objectFit:'cover', width/height
        // 100%.  Sizing to native video dimensions (e.g. 1920x1080) forces
        // FittedBox to apply a CSS transform that does not reliably
        // propagate to the CanvasKit platform-view overlay on iOS Safari.
        // SizedBox.expand() fills the parent exactly so FittedBox becomes
        // a no-op (1:1 scale = identity transform).
        if (kIsWeb) {
          return SizedBox.expand(child: cameraView);
        }

        // On native platforms the camera texture is rendered by Flutter's
        // compositor, so FittedBox scaling works correctly.
        return SizedBox.fromSize(
          size:
              value.deviceOrientation.isLandscape
                  ? value.size.flipped
                  : value.size,
          child: _wrapInRotatedBox(child: cameraView),
        );
      },
    );
  }

  Widget _wrapInRotatedBox({required Widget child}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }
    return RotatedBox(
      quarterTurns: controller.value.deviceOrientation.turns,
      child: child,
    );
  }
}

/// Extension on [DeviceOrientation] that adds helpful properties for
/// working with screen rotation and camera preview transformations.
extension on DeviceOrientation {
  /// Returns `true` if the device orientation is landscape (horizontal).
  bool get isLandscape =>
      this == DeviceOrientation.landscapeLeft ||
      this == DeviceOrientation.landscapeRight;

  /// Maps the different device orientations to quarter turns that the
  /// preview should take in account.
  int get turns => switch (this) {
    DeviceOrientation.portraitUp => 0,
    DeviceOrientation.landscapeRight => 1,
    DeviceOrientation.portraitDown => 2,
    DeviceOrientation.landscapeLeft => 3,
  };
}
