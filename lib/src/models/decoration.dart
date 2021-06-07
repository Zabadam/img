/// Provides a `DecorationImage` "too" that passes on its `Repeat` property
/// to its [paintImageToo] call.
//
//  Consider LICENSE file, as some code comes from the Flutter source itself.
library img;

import '../common.dart';

import '../painting.dart';

/// An image to show in a [BoxDecoration] which supports the [Repeat]
/// rendering modes including [Repeat.mirror].
///
/// The image is painted using [paintImageToo], which describes the meanings
/// of the various fields on this class in more detail.
@immutable
class DecorationImageToo implements DecorationImage {
  /// Creates an image to show in a [BoxDecoration] which supports the [Repeat]
  /// rendering modes including [Repeat.mirror].
  ///
  /// The [image], [alignment], [repeatMode], and [matchTextDirection] arguments
  /// must not be `null`.
  ///
  /// Like all `package:img` classes, `alignment` is ignored and forced
  /// [Alignment.center] if [repeat] is set to [Repeat.mirror],
  /// [Repeat.mirrorX], or [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, employ
  ///   an [Offset] in the [mirrorOffset] field.
  /// - This is a workaround for now and only aids in shifting a `Repeat.mirror`
  ///   tiled image that is meant to fill an entire space.
  ///
  /// See [paintImageToo] for a description of the meaning of these arguments.
  const DecorationImageToo({
    required this.image,
    this.onError,
    this.fit,
    this.scale = 1.0,
    this.alignment = Alignment.center,
    this.repeatMode = Repeat.noRepeat,
    this.mirrorOffset = Offset.zero,
    this.colorFilter,
    this.centerSlice,
    this.matchTextDirection = false,
  });

  /// The image to be painted into the decoration.
  ///
  /// Typically this will be an [AssetImage] (for an image shipped with the
  /// application) or a [NetworkImage] (for an image obtained from the network).
  @override
  final ImageProvider image;

  /// An optional error callback for errors emitted when loading [image].
  @override
  final ImageErrorListener? onError;

  /// How the image should be inscribed into the box.
  ///
  /// The default is [BoxFit.scaleDown] if [centerSlice] is `null`, and
  /// [BoxFit.fill] if [centerSlice] is not `null`.
  ///
  /// See the discussion at [paintImage] (the vanilla FLutter image painting
  /// method) for more details.
  @override
  final BoxFit? fit;

  /// Defines image pixels to be shown per logical pixels.
  ///
  /// By default the value of scale is 1.0. The scale for the image is
  /// calculated by multiplying [scale] with `scale` of the given
  /// [ImageProvider].
  @override
  final double scale;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of
  /// `(-1.0, -1.0)` aligns the image to the top-left corner of its layout
  /// bounds, while an value of `Alignment(1.0, 1.0)` aligns the bottom right
  /// of the image with the bottom right corner of its layout bounds.
  /// Similarly, an alignment of `(0.0, 1.0)` aligns the bottom middle of the
  /// image with the middle of the bottom edge of its layout bounds.
  ///
  /// Ignored and forced [Alignment.center] if [repeat] is set to
  /// [Repeat.mirror], [Repeat.mirrorX], or [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, employ
  ///   an [Offset] in the [mirrorOffset] field.
  /// - This is a workaround for now.
  ///
  /// To display a subpart of an image, consider using a [CustomPainter] and
  /// [Canvas.drawImageRect].
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then a [TextDirection] must be available
  /// when the image is painted.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  @override
  final AlignmentGeometry alignment;

  /// How to paint any portions of the box that would not otherwise be covered
  /// by the image.
  ///
  /// This is the special ingredient for a [DecorationImageToo] and allows
  /// the creation of seamless, tiling textures with any given image.
  ///
  /// In addition to the standard [ImageRepeat] options, this `Repeat` property
  /// has a few extra display choices.
  ///
  /// While a standard `DecorationImage` can be tiled in both axes with
  /// [ImageRepeat.repeat], a `DecorationImageToo` may additionally be
  /// tiled with *mirroring* in both axes by [Repeat.mirror].
  ///
  /// Consider that [ImageRepeat.repeatX] tiles an image only horizontally then
  /// reason that [Repeat.mirrorX] tiles an image horizontally by mirroring
  /// each odd-numbered tile horizontally. Also available is [Repeat.mirrorY].
  final Repeat repeatMode;
  @override
  ImageRepeat get repeat => ImageRepeat.noRepeat;

  /// Only applicable if [repeat] is [Repeat.mirror], [Repeat.mirrorX], or
  /// [Repeat.mirrorY]. Default is [Offset.zero].
  ///
  /// Valid values range `0..resolution`. That is to say maximum value for this
  /// `Offset.dx` is the horizontal resolution of [image] while the max for
  /// this `Offset.dy` is this [image]'s vertical resolution.
  ///
  /// Corresponds to an additional translation to the canvas onto which
  /// this image is painted. For a mirror-tiling image, this has the effect
  /// of shifting the mirror edge seams.
  ///
  /// This property replaces and functions similar to [alignment] when [repeat]
  /// is [Repeat.mirror], [Repeat.mirrorX], or [Repeat.mirrorY], is currently
  /// only a workaround, and only truly acts as "alignment" if [Repeat.mirror].
  final Offset mirrorOffset;

  /// A color filter to apply to the image before painting it.
  @override
  final ColorFilter? colorFilter;

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  ///
  /// The stretching will be applied in order to make the image fit into the box
  /// specified by [fit]. When [centerSlice] is not `null`, [fit] defaults to
  /// [BoxFit.fill], which distorts the destination image size relative to the
  /// image's original aspect ratio. Values of [BoxFit] which do not distort the
  /// destination image size will result in [centerSlice] having no effect
  /// (since the nine regions of the image will be rendered with the same
  /// scaling, as if it wasn't specified).
  @override
  final Rect? centerSlice;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  @override
  final bool matchTextDirection;

  /// Creates a [DecorationImagePainterToo] for this [DecorationImageToo].
  ///
  /// The `onChanged` argument must not be `null`.
  /// It will be called whenever the image needs to be repainted,
  /// e.g. because it is loading incrementally or because it is animated.
  @override
  DecorationImagePainter createPainter(VoidCallback onChanged) =>
      DecorationImagePainterToo._(this, onChanged);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DecorationImageToo &&
        other.image == image &&
        other.fit == fit &&
        other.alignment == alignment &&
        other.repeatMode == repeatMode &&
        other.colorFilter == colorFilter &&
        other.centerSlice == centerSlice &&
        other.matchTextDirection == matchTextDirection &&
        other.scale == scale;
  }

  @override
  int get hashCode => hashValues(image, fit, alignment, repeatMode, colorFilter,
      centerSlice, matchTextDirection, scale);

  @override
  String toString() {
    final properties = <String>[
      '$image',
      if (colorFilter != null) '$colorFilter',
      if (fit != null &&
          !(fit == BoxFit.fill && centerSlice != null) &&
          !(fit == BoxFit.scaleDown && centerSlice == null))
        '$fit',
      '$alignment',
      if (centerSlice != null) 'centerSlice: $centerSlice',
      if (repeatMode != Repeat.noRepeat) '$repeatMode',
      if (matchTextDirection) 'match text direction',
      'scale: $scale',
    ];
    return '${objectRuntimeType(this, 'DecorationImageToo')}'
        '(${properties.join(", ")})';
  }
}

/// The painter for a [DecorationImageToo].
///
/// To obtain a painter, call [DecorationImageToo.createPainter].
///
/// To paint, call [paint]. The `onChanged` callback passed to
/// [DecorationImageToo.createPainter] will be called if the image needs to
/// paint again (e.g. because it is animated or because it had not yet loaded
/// the first time the [paint] method was called).
///
/// This object should be disposed using the [dispose] method when it is no
/// longer needed.
class DecorationImagePainterToo implements DecorationImagePainter {
  DecorationImagePainterToo._(this._details, this._onChanged);

  final DecorationImageToo _details;
  final VoidCallback _onChanged;

  ImageStream? _imageStream;
  ImageInfo? _image;

  /// Draw the image onto the given canvas.
  ///
  /// The image is drawn at the position and size given by the `rect` argument.
  ///
  /// The image is clipped to the given `clipPath`, if any.
  ///
  /// The `configuration` object is used to resolve the image (e.g. to pick
  /// resolution-specific assets), and to implement the
  /// [DecorationImageToo.matchTextDirection] feature.
  ///
  /// If the image needs to be painted again, e.g. because it is animated or
  /// because it had not yet been loaded the first time this method was called,
  /// then the `onChanged` callback passed to [DecorationImageToo.createPainter]
  /// will be called.
  @override
  void paint(Canvas canvas, Rect rect, Path? clipPath,
      ImageConfiguration configuration) {
    var flipHorizontally = false;
    if (_details.matchTextDirection) {
      assert(() {
        // We check this first so that the assert will fire immediately, not
        // just when the image is ready.
        if (configuration.textDirection == null) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('DecorationImage.matchTextDirection can only be used '
                'when a TextDirection is available.'),
            ErrorDescription(
              'When DecorationImagePainter.paint() was called, '
              'there was no text direction provided in the '
              'ImageConfiguration object to match.',
            ),
            DiagnosticsProperty<DecorationImageToo>(
                'The DecorationImage was', _details,
                style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<ImageConfiguration>(
                'The ImageConfiguration was', configuration,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (configuration.textDirection == TextDirection.rtl) {
        flipHorizontally = true;
      }
    }

    final newImageStream = _details.image.resolve(configuration);
    if (newImageStream.key != _imageStream?.key) {
      final listener = ImageStreamListener(
        _handleImage,
        onError: _details.onError,
      );
      _imageStream?.removeListener(listener);
      _imageStream = newImageStream;
      _imageStream!.addListener(listener);
    }
    if (_image == null) return;

    if (clipPath != null) {
      canvas
        ..save()
        ..clipPath(clipPath);
    }

    /// Expanded [paintImage] method that accepts a [Repeat].
    paintImageToo(
      canvas: canvas,
      rect: rect,
      image: _image!.image,
      debugImageLabel: _image!.debugLabel,
      scale: _details.scale * _image!.scale,
      colorFilter: _details.colorFilter,
      fit: _details.fit,
      alignment: _details.alignment.resolve(configuration.textDirection),
      centerSlice: _details.centerSlice,
      // FINALLY the meat and potatoes:
      // enabling mirroring tiles in the paint method.
      repeat: _details.repeatMode,
      mirrorOffset: _details.mirrorOffset,
      flipHorizontally: flipHorizontally,
      filterQuality: FilterQuality.low,
    );

    if (clipPath != null) canvas.restore();
  }

  void _handleImage(ImageInfo value, bool synchronousCall) {
    if (_image == value) return;
    if (_image != null && _image!.isCloneOf(value)) {
      value.dispose();
      return;
    }
    _image?.dispose();
    _image = value;
    if (!synchronousCall) _onChanged();
  }

  /// Releases the resources used by this painter.
  ///
  /// This should be called whenever the painter is no longer needed.
  ///
  /// After this method has been called, the object is no longer usable.
  @override
  @mustCallSuper
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(
      _handleImage,
      onError: _details.onError,
    ));
    _image?.dispose();
    _image = null;
  }

  @override
  String toString() => '${objectRuntimeType(this, 'DecorationImagePainterToo')}'
      '(stream: $_imageStream, image: $_image) for $_details';
}
