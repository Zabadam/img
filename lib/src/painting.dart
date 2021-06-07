/// Defines [_Proximity] to a source tile for a mirror-aware paint method
/// called [paintImageToo].
/// - Compare this file to Flutter's `decoration_image.dart` and [paintImage]
/// - See [_generateImageTileRects], which generates the tiles for the vanilla
///   `repeat`ed images as well as new `mirror`ed images
///   - `yield`s `Rect` mapped to a `_Proximity` to source tile (Proximity(0,0))
/// - If `repeat` is `repeat`, the generated tiles are painted one after another
/// - If `repeat` is one of the new `mirror` modes, delegate to
///   new [_drawWithMirroring]
///   - Checks proximity's x and y parity (even/odd) and provided `repeat` mode
///   and flips the `canvas` before painting if necessary
///   - Painting the images mirrored is done by manipulating the `canvas` with
///   [_mirrorX] or [_mirrorY], painting the `image`, and then reverting that
///   transform.
library img;

import 'dart:developer' as developer;
import 'dart:ui' as ui show Image;

import 'common.dart';

/// A description of how many instances, or tiles, away from a source that
/// another object resides along both the `X` and `Y` axes.
class _Proximity {
  /// Construct a `Proximity` to some source for another object.
  ///
  /// Provide two counting values, `int`s [alongX] and [alongY], where `alongX`
  /// describes the number of instances, or tiles, this object resides from the
  /// source in the `X` axis.
  ///
  /// These values may be negative. If either value is `0`, the object is
  /// aligned with the source in that axis. If both values are `0`, this
  /// object *is* the source instance.
  const _Proximity(this.alongX, this.alongY);

  /// A counting value that describes the number of instances, or tiles,
  /// traveled away from `Proximity(0,0)`, the source tile itself.
  ///
  /// Positive proximities move right and down from the source instance. \
  /// Negative proximities move left and up from the source instance.
  final int alongX, alongY;
}

Rect _scaleRect(Rect rect, double scale) => Rect.fromLTRB(rect.left * scale,
    rect.top * scale, rect.right * scale, rect.bottom * scale);

void _mirrorX(Canvas canvas, double dx) {
  canvas
    ..translate(-dx, 0.0)
    ..scale(-1.0, 1.0)
    ..translate(dx, 0.0);
}

void _mirrorY(Canvas canvas, double dy) {
  canvas
    ..translate(0.0, -dy)
    ..scale(1.0, -1.0)
    ..translate(0.0, dy);
}

void _drawWithMirroring(
  Canvas canvas,
  ui.Image image,
  Rect imageRect,
  Map<Rect, _Proximity> tileMap,
  Offset translation,
  Repeat repeat,
  Paint paint,
) {
  var shouldMirrorX = (repeat == Repeat.mirror || repeat == Repeat.mirrorX);
  var shouldMirrorY = (repeat == Repeat.mirror || repeat == Repeat.mirrorY);
  final proximity = tileMap.values.single;
  // Odd proximity implies a mirror should occur
  if (proximity.alongX.isEven) shouldMirrorX = false;
  if (proximity.alongY.isEven) shouldMirrorY = false;

  canvas.save();
  if (shouldMirrorX) {
    _mirrorX(canvas, translation.dx);
  }
  if (shouldMirrorY) {
    _mirrorY(canvas, translation.dy);
  }
  canvas
    ..drawImageRect(image, imageRect, tileMap.keys.single, paint)
    ..restore();
  // if (shouldMirrorX) {
  //   _mirrorX(canvas, translation.dx);
  // }
  // if (shouldMirrorY) {
  //   _mirrorY(canvas, translation.dy);
  // }
}

/// TODO: Optimize such that employing [mirrorOffset] does not generate
/// unnecessary tiles. WORKED AROUND: Set maximum for [mirrorOffset].
///
/// TODO: Correct behavior with provided `alignment` instead of overriding to
/// [Alignment.center] and looking to [mirrorOffset].
Iterable<Map<Rect, _Proximity>> _generateImageTileRects(
  Rect outputRect,
  Rect eachTile,
  Repeat repeat, [
  Offset mirrorOffset = Offset.zero,
]) sync* {
  // Currently a workaround.
  assert(
    0 <= mirrorOffset.dx && mirrorOffset.dx <= eachTile.width,
    'When offsetting a mirrored image, offset horizontally by '
    'an amount less than or equal to the image\'s width.\n'
    'mirrorOffset.dx == ${mirrorOffset.dx}, image width: ${eachTile.width}',
  );
  assert(
    0 <= mirrorOffset.dy && mirrorOffset.dy <= eachTile.height,
    'When offsetting a mirrored image, offset vertically by '
    'an amount less than or equal to the image\'s height.\n'
    'mirrorOffset.dy == ${mirrorOffset.dy}, image height: ${eachTile.height}',
  );
  var startX = 0, startY = 0, stopX = 0, stopY = 0;
  final strideX = eachTile.width;
  final strideY = eachTile.height;

  if (repeat == Repeat.repeat ||
      repeat == Repeat.repeatX ||
      repeat == Repeat.mirror ||
      repeat == Repeat.mirrorX) {
    // Re-consider calculation with mirrorOffset.
    startX =
        ((outputRect.left - mirrorOffset.dx - eachTile.left) / strideX).floor();
    stopX = ((outputRect.right + mirrorOffset.dx - eachTile.right) / strideX)
        .ceil();
  }

  if (repeat == Repeat.repeat ||
      repeat == Repeat.repeatY ||
      repeat == Repeat.mirror ||
      repeat == Repeat.mirrorY) {
    // Re-consider calculation with mirrorOffset.
    startY =
        ((outputRect.top - mirrorOffset.dy - eachTile.top) / strideY).floor();
    stopY = ((outputRect.bottom + mirrorOffset.dy - eachTile.bottom) / strideY)
        .ceil();
  }

  /// The current "proximity" to the source tile in terms of Proximity(x,y),
  /// where Proximity(0,0) describes the source image Rect at its true aligned
  /// position, can be evaluated as the current `i` and `j` values each `yield`;
  /// then delivered as `[i,j]`, mapped to the output `Rect` itself, to be
  /// considered in paint method.
  ///
  /// This proximity, when odd, dictates a tile should be mirrored in that axis.
  for (var i = startX; i <= stopX; ++i) {
    for (var j = startY; j <= stopY; ++j) {
      yield <Rect, _Proximity>{
        eachTile.shift(Offset(i * strideX, j * strideY)): _Proximity(i, j)
      };
    }
  }
}

/// Used by [paintImageToo] to report image sizes drawn at the end of the frame.
Map<String, ImageSizeInfo> _pendingImageSizeInfo = <String, ImageSizeInfo>{};

/// [ImageSizeInfo]s that were reported on the last frame.
///
/// Used to prevent duplicative reports from frame to frame.
Set<ImageSizeInfo> _lastFrameImageSizeInfo = <ImageSizeInfo>{};

/// Flushes inter-frame tracking of image size information from [paintImage].
///
/// Has no effect if asserts are disabled.
@visibleForTesting
void debugFlushLastFrameImageSizeInfo() {
  assert(() {
    _lastFrameImageSizeInfo = <ImageSizeInfo>{};
    return true;
  }());
}

/// Paints an image into the given rectangle on the canvas.
///
/// The arguments have the following meanings:
///
///  * `canvas`: The canvas onto which the image will be painted.
///
///  * `rect`: The region of the canvas into which the image will be painted.
///   The image might not fill the entire rectangle (e.g., depending on the
///   `fit`). If `rect` is empty, nothing is painted.
///
///  * `image`: The image to paint onto the canvas.
///
///  * `scale`: The number of image pixels for each logical pixel.
///
///  * `colorFilter`: If non-null, the color filter to apply when painting the
///   image.
///
///  * `fit`: How the image should be inscribed into `rect`. If null, the
///   default behavior depends on `centerSlice`. If `centerSlice` is also null,
///   the default behavior is [BoxFit.scaleDown]. If `centerSlice` is
///   non-null, the default behavior is [BoxFit.fill]. See [BoxFit] for
///   details.
///
///  * `alignment`: How the destination rectangle defined by applying `fit` is
///   aligned within `rect`. For example, if `fit` is [BoxFit.contain] and
///   `alignment` is [Alignment.bottomRight], the image will be as large
///   as possible within `rect` and placed with its bottom right corner at the
///   bottom right corner of `rect`. \
///   Defaults to [Alignment.center]. Reverts to [Alignment.center] if [repeat]
///   is a [Repeat.mirror] value. See then: [mirrorOffset].
///
///  * `centerSlice`: The image is drawn in nine portions described by splitting
///   the image by drawing two horizontal lines and two vertical lines, where
///   `centerSlice` describes the rectangle formed by the four points where
///   these four lines intersect each other. (This forms a 3-by-3 grid
///   of regions, the center region being described by `centerSlice`.)
///   The four regions in the corners are drawn, without scaling, in the four
///   corners of the destination rectangle defined by applying `fit`. The
///   remaining five regions are drawn by stretching them to fit such that they
///   exactly cover the destination rectangle while maintaining their relative
///   positions.
///
///  * `repeat`: If the image does not fill `rect`, whether and how the image
///   should be repeated to fill `rect`. By default, the image is not repeated.
///   See [Repeat] for details. This is the core difference between this method
///   and the standard [paintImage].
///
///  * `mirrorOffset`: If the image is [repeat]ed with a [Repeat.mirror] value,
///   then [alignment] is reverted to [Alignment.center]. In that case, use this
///   [Offset] ranging `0..maxAxisResolution` (resolution of [image] in px) to
///   shift the mirroring tiles.
///
///  * `flipHorizontally`: Whether to flip the image horizontally. This is
///   occasionally used with images in right-to-left environments, for images
///   that were designed for left-to-right locales (or vice versa). Be careful,
///   when using this, to not flip images with integral shadows, text, or other
///   effects that will look incorrect when flipped.
///
///  * `invertColors`: Inverting the colors of an image applies a new color
///   filter to the paint. If there is another specified color filter, the
///   invert will be applied after it. This is primarily used for implementing
///   smart invert on iOS.
///
///  * `filterQuality`: Use this to change the quality when scaling an image.
///   Use the [FilterQuality.low] quality setting to scale the image,
///   which corresponds to bilinear interpolation, rather than the default
///   [FilterQuality.none] which corresponds to nearest-neighbor.
///
/// The `canvas`, `rect`, `image`, `scale`, `alignment`, `repeat`,
/// `flipHorizontally` and `filterQuality` arguments must not be `null`.
///
/// See also:
///
///  * [paintBorder], which paints a border around a rectangle on a canvas.
///  * `ImageToo`, a `Widget` that creates a chain of rendering objects that
///   eventually call this method.
///  * `DecorationImageToo`, which holds a configuration for calling this
///   function.
///  * [BoxDecoration], which uses this function to paint a
///   `DecorationImageToo`.
void paintImageToo({
  required Canvas canvas,
  required Rect rect,
  required ui.Image image,
  String? debugImageLabel,
  double scale = 1.0,
  ColorFilter? colorFilter,
  BoxFit? fit,
  Alignment alignment = Alignment.center,
  Rect? centerSlice,
  Repeat repeat = Repeat.noRepeat,
  Offset mirrorOffset = Offset.zero,
  bool flipHorizontally = false,
  bool invertColors = false,
  FilterQuality filterQuality = FilterQuality.low,
  bool isAntiAlias = false,
}) {
  assert(
    image.debugGetOpenHandleStackTraces()?.isNotEmpty ?? true,
    'Cannot paint an image that is disposed.\n'
    'The caller of paintImage is expected to wait to dispose the image until '
    'after painting has completed.',
  );
  if (rect.isEmpty) {
    return;
  }
  var sizeOut = rect.size;
  var sizeIn = Size(image.width.toDouble(), image.height.toDouble());
  Offset? sliceBorder;
  if (centerSlice != null) {
    sliceBorder = sizeIn / scale - centerSlice.size as Offset;
    sizeOut = sizeOut - sliceBorder as Size;
    sizeIn = sizeIn - sliceBorder * scale as Size;
  }
  fit ??= centerSlice == null ? BoxFit.scaleDown : BoxFit.fill;
  assert(centerSlice == null || (fit != BoxFit.none && fit != BoxFit.cover));
  final fittedSizes = applyBoxFit(fit, sizeIn / scale, sizeOut);
  final sizeSource = fittedSizes.source * scale;
  var sizeDest = fittedSizes.destination;
  if (centerSlice != null) {
    sizeOut += sliceBorder!;
    sizeDest += sliceBorder;
    // We don't have the ability to draw a subset of the image at the same time
    // as we apply a nine-patch stretch.
    assert(
        sizeSource == sizeIn,
        'centerSlice was used with a BoxFit that '
        'does not guarantee that the image is fully visible.');
  }

  if (repeat != Repeat.noRepeat && sizeDest == sizeOut) {
    repeat = Repeat.noRepeat;
  }

  /// TODO: Properly fix `alignment`.
  alignment = (repeat == Repeat.mirror ||
          repeat == Repeat.mirrorX ||
          repeat == Repeat.mirrorY)
      ? Alignment.center
      : alignment;

  final paint = Paint()
    ..isAntiAlias = isAntiAlias
    ..filterQuality = filterQuality
    ..invertColors = invertColors;
  if (colorFilter != null) {
    paint.colorFilter = colorFilter;
  }

  final halfWidthDelta = (sizeOut.width - sizeDest.width) / 2.0;
  final halfHeightDelta = (sizeOut.height - sizeDest.height) / 2.0;
  final dx = halfWidthDelta +
      (flipHorizontally ? -alignment.x : alignment.x) * halfWidthDelta;
  final dy = halfHeightDelta + alignment.y * halfHeightDelta;
  final alignedOffset = rect.topLeft.translate(dx, dy);
  final alignedRect = alignedOffset & sizeDest;

  // Set to true if we added a saveLayer to the canvas to invert/flip the image.
  var invertedCanvas = false;
  // Output size and destination rect are fully calculated.
  if (!kReleaseMode) {
    invertedCanvas = _debug(debugImageLabel, image, sizeOut, canvas,
        alignedRect, rect, invertedCanvas);
  }

  final needSave =
      centerSlice != null || repeat != Repeat.noRepeat || flipHorizontally;
  if (needSave) canvas.save();
  if (repeat != Repeat.noRepeat) canvas.clipRect(rect);

  final recenterX = -(rect.left + rect.width / 2.0);
  final recenterY = -(rect.top + rect.height / 2.0);
  if (flipHorizontally) {
    _mirrorX(canvas, recenterY);
  }

  /// No Center Slicing
  if (centerSlice == null) {
    final imageRect = alignment.inscribe(
      sizeSource,
      Offset.zero & sizeIn,
    );
    if (repeat == Repeat.noRepeat) {
      canvas.drawImageRect(image, imageRect, alignedRect, paint);
    } else {
      canvas.translate(mirrorOffset.dx, mirrorOffset.dy);
      for (final tileMap
          in _generateImageTileRects(rect, alignedRect, repeat, mirrorOffset)) {
        if (repeat == Repeat.mirror ||
            repeat == Repeat.mirrorX ||
            repeat == Repeat.mirrorY) {
          _drawWithMirroring(canvas, image, imageRect, tileMap,
              Offset(recenterX, recenterY), repeat, paint);

          /// Repeat.repeat || repeatX || repeatY
        } else {
          canvas.drawImageRect(image, imageRect, tileMap.keys.single, paint);
        }
      }
    }

    /// Center Slicing
  } else {
    canvas.scale(1 / scale);
    if (repeat == Repeat.noRepeat) {
      canvas.drawImageNine(image, _scaleRect(centerSlice, scale),
          _scaleRect(alignedRect, scale), paint);
    } else {
      for (final tileMap
          in _generateImageTileRects(rect, alignedRect, repeat)) {
        canvas.drawImageNine(image, _scaleRect(centerSlice, scale),
            _scaleRect(tileMap.keys.single, scale), paint);
      }
    }
  }
  if (needSave) canvas.restore();

  if (invertedCanvas) {
    canvas.restore();
  }
}

bool _debug(
  String? debugImageLabel,
  ui.Image image,
  Size outputSize,
  Canvas canvas,
  Rect destinationRect,
  Rect rect,
  bool invertedCanvas,
) {
  final sizeInfo = ImageSizeInfo(
    // Some ImageProvider implementations may not have given this.
    source:
        debugImageLabel ?? '<Unknown Image(${image.width}×${image.height})>',
    imageSize: Size(image.width.toDouble(), image.height.toDouble()),
    displaySize: outputSize,
  );
  assert(() {
    if (debugInvertOversizedImages &&
        sizeInfo.decodedSizeInBytes >
            sizeInfo.displaySizeInBytes + debugImageOverheadAllowance) {
      final overheadInKilobytes =
          (sizeInfo.decodedSizeInBytes - sizeInfo.displaySizeInBytes) ~/ 1024;
      final outputWidth = outputSize.width.toInt();
      final outputHeight = outputSize.height.toInt();
      FlutterError.reportError(FlutterErrorDetails(
        exception: 'Image $debugImageLabel has a display size of '
            '$outputWidth×$outputHeight but a decode size of '
            '${image.width}×${image.height}, which uses an additional '
            '${overheadInKilobytes}KB.\n\n'
            'Consider resizing the asset ahead of time, supplying a '
            'cacheWidth parameter of $outputWidth, a cacheHeight parameter '
            'of $outputHeight, or using a ResizeImage.',
        library: 'painting library',
        context: ErrorDescription('while painting an image'),
      ));
      // Invert the colors of the canvas.

      canvas.saveLayer(
        destinationRect,
        Paint()..colorFilter = const ColorFilter.matrix(_matrix),
      );
      // Flip the canvas vertically.
      final dy = -(rect.top + rect.height / 2.0);
      _mirrorY(canvas, dy);
      invertedCanvas = true;
    }
    return true;
  }());
  // Avoid emitting events that are the same as those emitted
  // in the last frame.
  if (!_lastFrameImageSizeInfo.contains(sizeInfo)) {
    final existingSizeInfo = _pendingImageSizeInfo[sizeInfo.source];
    if (existingSizeInfo == null ||
        existingSizeInfo.displaySizeInBytes < sizeInfo.displaySizeInBytes) {
      _pendingImageSizeInfo[sizeInfo.source!] = sizeInfo;
    }
    debugOnPaintImage?.call(sizeInfo);
    SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      _lastFrameImageSizeInfo = _pendingImageSizeInfo.values.toSet();
      if (_pendingImageSizeInfo.isEmpty) {
        return;
      }
      developer.postEvent(
        'Flutter.ImageSizesForFrame',
        <String, Object>{
          for (ImageSizeInfo imageSizeInfo in _pendingImageSizeInfo.values)
            imageSizeInfo.source!: imageSizeInfo.toJson(),
        },
      );
      _pendingImageSizeInfo = <String, ImageSizeInfo>{};
    });
  }
  return invertedCanvas;
}

const _matrix = <double>[
  -1,
  0,
  0,
  0,
  255,
  0,
  -1,
  0,
  0,
  255,
  0,
  0,
  -1,
  0,
  255,
  0,
  0,
  0,
  1,
  0,
];
