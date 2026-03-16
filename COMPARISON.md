# Fork Comparison: info618/mobile_scanner vs juliansteenbakker/mobile_scanner

## Overview

This repository (`info618/mobile_scanner`) is a **B2M fork** of the official [`juliansteenbakker/mobile_scanner`](https://github.com/juliansteenbakker/mobile_scanner) Flutter package. Both are based on **v7.2.0**. This fork adds **5 web-specific bug fixes** targeting iOS Safari and CanvasKit rendering issues that the upstream does not have.

## Files Modified

| File | Lines Changed |
|------|--------------|
| `lib/src/web/mobile_scanner_web.dart` | +15 |
| `lib/src/mobile_scanner_preview.dart` | +16 / -1 |
| `lib/src/mobile_scanner.dart` | +22 / -9 |

## Fork Changes (not in upstream)

### 1. iOS Safari video element fixes (`mobile_scanner_web.dart`)
- Added `playsinline` attribute on `<video>` — required for inline video playback on iOS Safari (without it, camera preview is black)
- Added `muted = true` — satisfies browser autoplay policy
- Did NOT add `autoplay` — ZXing calls `video.play()` itself; `autoplay` causes "already playing" conflict on iOS Safari
- Added `transform: translateZ(0)` on the container `<div>` — forces GPU compositing layer on iOS Safari, preventing invisible camera feed until first user interaction

### 2. Web-specific preview sizing (`mobile_scanner_preview.dart`)
- Added `kIsWeb` check: on web, returns `SizedBox.expand(child: cameraView)` instead of `SizedBox.fromSize()` with native video dimensions
- The HtmlElementView's `<video>` already has CSS `objectFit:'cover'` and 100% width/height; sizing to native dimensions (e.g. 1920x1080) causes FittedBox to apply CSS transforms that don't reliably propagate to CanvasKit platform-view overlays on iOS Safari

### 3. CanvasKit ClipRect fix (`mobile_scanner.dart`)
- Added `kIsWeb` conditional: on web, uses `SizedBox.expand` instead of `ClipRect > SizedBox.fromSize > FittedBox`
- On CanvasKit renderer, HtmlElementView platform views are rendered as DOM overlays outside the Flutter canvas; `ClipRect` doesn't clip these overlays and `FittedBox` passes unconstrained constraints causing infinite-size errors

## Upstream Changes (not in fork)

The upstream `develop` branch has newer commits after v7.2.0 that this fork does not include:
- macOS overlay text orientation fix
- Apple rawBytes encoding migration
- iOS overlay orientation fix
- Android overlay rotation fix
- Dependency updates (camera library, analysis tools)

## Related Upstream Issues (still open)

These upstream issues describe the problems that this fork's fixes address:
- [#1655](https://github.com/juliansteenbakker/mobile_scanner/issues/1655) — Safari black half-screen
- [#950](https://github.com/juliansteenbakker/mobile_scanner/issues/950) — Blank screen on iOS web
- [#1320](https://github.com/juliansteenbakker/mobile_scanner/issues/1320) — Chrome/Safari iOS can't show widget

## Comparison Date

2026-03-16
