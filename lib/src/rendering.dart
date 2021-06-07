/// Organize properties for single-leaf image rendering via [RawImageToo]
/// and [RenderImageToo]. This layer is also where the Dart abstraction occurs.
///
/// A `RenderImageToo` defers to the new [paintImageToo] method as opposed
/// to the vanilla [paintImage] call.
//
//  Consider LICENSE file, as some code comes from the Flutter source itself.
library img;

import 'dart:ui' as ui show Image;

import 'common.dart';

import 'painting.dart';

/// A [RawImage] "too" that has an altered [repeat] property that is of the
/// new type [Repeat].
class RawImageToo extends LeafRenderObjectWidget {
  /// A [RawImage] "too" that has an altered [repeat] property that is of the
  /// new type [Repeat].
  ///
  /// Like all `package:img` classes, `alignment` is ignored and forced
  /// [Alignment.center] if [repeat] is set to [Repeat.mirror],
  /// [Repeat.mirrorX], or [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, employ
  ///   an [Offset] in the [mirrorOffset] field.
  /// - This is a workaround for now and only aids in shifting a `Repeat.mirror`
  ///   tiled image that is meant to fill an entire space.
  const RawImageToo({
    Key? key,
    this.image,
    this.debugImageLabel,
    this.width,
    this.height,
    this.scale = 1.0,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = Repeat.noRepeat,
    this.mirrorOffset = Offset.zero,
    this.centerSlice,
    this.matchTextDirection = false,
    this.invertColors = false,
    this.filterQuality = FilterQuality.low,
    this.isAntiAlias = false,
  }) : super(key: key);

  /// The image to display.
  ///
  /// Since a [RawImageToo] is stateless, it does not ever dispose this image.
  /// Creators of a [RawImageToo] are expected to call [ui.Image] `.dispose()`
  /// on this image handle when the [RawImageToo] will no longer be needed.
  final ui.Image? image;

  /// A string identifying the source of the image.
  final String? debugImageLabel;

  /// If non-`null`, require the image to have this width.
  ///
  /// If `null`, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  final double? width;

  /// If non-`null`, require the image to have this height.
  ///
  /// If `null`, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  final double? height;

  /// Specifies the image's scale.
  ///
  /// Used when determining the best display size for the image.
  final double scale;

  /// If non-`null`, this color is blended with each image pixel using
  /// [colorBlendMode].
  final Color? color;

  /// Used to set the filterQuality of the image
  /// Use the "low" quality setting to scale the image, which corresponds to
  /// bilinear interpolation, rather than the default "none" which corresponds
  /// to nearest-neighbor.
  final FilterQuality filterQuality;

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each
  ///  blend mode.
  final BlendMode? colorBlendMode;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit? fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while
  /// a [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// Ignored and forced [Alignment.center] if [repeat] is set to
  /// [Repeat.mirror], [Repeat.mirrorX], or [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, employ
  ///   an [Offset] in the [mirrorOffset] field.
  ///
  /// To display a subpart of an image, consider using a [CustomPainter] and
  /// [Canvas.drawImageRect].
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  ///
  /// This is the special ingredient for a [RawImageToo] and allows
  /// the creation of seamless, tiling textures with any given image.
  ///
  /// In addition to the standard [ImageRepeat] options, this [Repeat] property
  /// has a few extra display choices.
  ///
  /// While a standard `DecorationImage` can be tiled in both axes with
  /// [ImageRepeat.repeat], a `DecorationImageToo` may additionally be
  /// tiled with *mirroring* in both axes by [Repeat.mirror].
  ///
  /// Consider that [ImageRepeat.repeatX] tiles an image only horizontally then
  /// reason that [Repeat.mirrorX] tiles an image horizontally by mirroring
  /// each odd-numbered tile horizontally. Also available is [Repeat.mirrorY].
  ///
  /// See [Repeat] for more information.
  final Repeat repeat;

  /// Only applicable if [repeat] is [Repeat.mirror], [Repeat.mirrorX], or
  /// [Repeat.mirrorY]. Default is [Offset.zero].
  ///
  /// Valid values range `0..resolution`. That is to say maximum value for this
  /// `Offset.dx` is the horizontal resolution of [image] while the max for
  /// this `Offset.dy` is this [image]'s vertical resolution.
  ///
  ///
  /// Corresponds to an additional translation to the canvas onto which
  /// this image is painted. For a mirror-tiling image, this has the effect
  /// of shifting the mirror edge seams.
  ///
  /// This property replaces and functions similar to [alignment] when [repeat]
  /// is [Repeat.mirror], [Repeat.mirrorX], or [Repeat.mirrorY].
  final Offset mirrorOffset;

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  final Rect? centerSlice;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with images in right-to-left environments, for
  /// images that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip images with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is true, there must be an ambient [Directionality] widget in
  /// scope.
  final bool matchTextDirection;

  /// Whether the colors of the image are inverted when drawn.
  ///
  /// inverting the colors of an image applies a new color filter to the paint.
  /// If there is another specified color filter, the invert will be applied
  /// after it. This is primarily used for implementing smart invert on iOS.
  ///
  /// See also:
  ///
  ///  * [Paint.invertColors], for the dart:ui implementation.
  final bool invertColors;

  /// Whether to paint the image with anti-aliasing.
  ///
  /// Anti-aliasing alleviates the sawtooth artifact when the image is rotated.
  final bool isAntiAlias;

  @override
  RenderImageToo createRenderObject(BuildContext context) {
    assert((!matchTextDirection && alignment is Alignment) ||
        debugCheckHasDirectionality(context));
    assert(
      image?.debugGetOpenHandleStackTraces()?.isNotEmpty ?? true,
      'Creator of a RawImage disposed of the image when the RawImage still '
      'needed it.',
    );
    return RenderImageToo(
      image: image?.clone(),
      debugImageLabel: debugImageLabel,
      width: width,
      height: height,
      scale: scale,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      mirrorOffset: mirrorOffset,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      textDirection: matchTextDirection || alignment is! Alignment
          ? Directionality.of(context)
          : null,
      invertColors: invertColors,
      filterQuality: filterQuality,
      isAntiAlias: isAntiAlias,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderImageToo renderObject) {
    assert(
      image?.debugGetOpenHandleStackTraces()?.isNotEmpty ?? true,
      'Creator of a RawImage disposed of the image when the RawImage still '
      'needed it.',
    );
    renderObject
      ..image = image?.clone()
      ..debugImageLabel = debugImageLabel
      ..width = width
      ..height = height
      ..scale = scale
      ..color = color
      ..colorBlendMode = colorBlendMode
      ..alignment = alignment
      ..fit = fit
      ..repeat = repeat
      ..mirrorOffset = mirrorOffset
      ..centerSlice = centerSlice
      ..matchTextDirection = matchTextDirection
      ..textDirection = matchTextDirection || alignment is! Alignment
          ? Directionality.of(context)
          : null
      ..invertColors = invertColors
      ..filterQuality = filterQuality;
  }

  @override
  void didUnmountRenderObject(RenderImageToo renderObject) {
    // Have the render object dispose its image handle.
    renderObject.image = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ui.Image>('image', image))
      ..add(DoubleProperty('width', width, defaultValue: null))
      ..add(DoubleProperty('height', height, defaultValue: null))
      ..add(DoubleProperty('scale', scale, defaultValue: 1.0))
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(EnumProperty<BlendMode>('colorBlendMode', colorBlendMode,
          defaultValue: null))
      ..add(EnumProperty<BoxFit>('fit', fit, defaultValue: null))
      ..add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment,
          defaultValue: null))
      ..add(
          EnumProperty<Repeat>('repeat', repeat, defaultValue: Repeat.noRepeat))
      ..add(DiagnosticsProperty<Offset>('mirrorOffset', mirrorOffset,
          defaultValue: Offset.zero))
      ..add(DiagnosticsProperty<Rect>('centerSlice', centerSlice,
          defaultValue: null))
      ..add(FlagProperty('matchTextDirection',
          value: matchTextDirection, ifTrue: 'match text direction'))
      ..add(DiagnosticsProperty<bool>('invertColors', invertColors))
      ..add(EnumProperty<FilterQuality>('filterQuality', filterQuality));
  }
}

/// An image in the render tree.
///
/// A [RenderImage] "too" that has an altered [repeat] property that is of the
/// new type [Repeat].
///
/// The render image attempts to find a size for itself that fits in the given
/// constraints and preserves the image's intrinsic aspect ratio.
///
/// The image is painted using [paintImageToo], which describes the meanings of
/// the various fields on this class in more detail.
class RenderImageToo extends RenderBox {
  /// Creates a render box that displays an image.
  ///
  /// A [RenderImage] "too" that has an altered [repeat] property that is of the
  /// new type [Repeat].
  ///
  /// The [scale], [alignment], [repeat], [matchTextDirection] and
  /// [filterQuality] arguments must not be `null`. The [textDirection]
  /// argument must not be `null` if [alignment] will need resolving or if
  /// [matchTextDirection] is true.
  ///
  /// Like all `package:img` classes, `alignment` is ignored and forced
  /// [Alignment.center] if [repeat] is set to [Repeat.mirror],
  /// [Repeat.mirrorX], or [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, employ
  ///   an [Offset] in the [mirrorOffset] field.
  /// - This is a workaround for now and only aids in shifting a `Repeat.mirror`
  ///   tiled image that is meant to fill an entire space.
  RenderImageToo({
    ui.Image? image,
    this.debugImageLabel,
    double? width,
    double? height,
    double scale = 1.0,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    Repeat repeat = Repeat.noRepeat,
    Offset mirrorOffset = Offset.zero,
    Rect? centerSlice,
    bool matchTextDirection = false,
    TextDirection? textDirection,
    bool invertColors = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  })  : _image = image,
        _width = width,
        _height = height,
        _scale = scale,
        _color = color,
        _colorBlendMode = colorBlendMode,
        _fit = fit,
        _alignment = alignment,
        _repeat = repeat,
        _mirrorOffset = mirrorOffset,
        _centerSlice = centerSlice,
        _matchTextDirection = matchTextDirection,
        _invertColors = invertColors,
        _textDirection = textDirection,
        _isAntiAlias = isAntiAlias,
        _filterQuality = filterQuality {
    _updateColorFilter();
  }

  Alignment? _resolvedAlignment;
  bool? _flipHorizontally;

  void _resolve() {
    if (_resolvedAlignment != null) {
      return;
    }
    _resolvedAlignment = alignment.resolve(textDirection);
    _flipHorizontally =
        matchTextDirection && textDirection == TextDirection.rtl;
  }

  void _markNeedResolution() {
    _resolvedAlignment = null;
    _flipHorizontally = null;
    markNeedsPaint();
  }

  /// The image to display.
  ui.Image? get image => _image;
  ui.Image? _image;
  set image(ui.Image? value) {
    if (value == _image) {
      return;
    }
    // If we get a clone of our image, it's the same underlying native data -
    // dispose of the new clone and return early.
    if (value != null && _image != null && value.isCloneOf(_image!)) {
      value.dispose();
      return;
    }
    _image?.dispose();
    _image = value;
    markNeedsPaint();
    if (_width == null || _height == null) {
      markNeedsLayout();
    }
  }

  /// A string used to identify the source of the image.
  String? debugImageLabel;

  /// If non-`null`, requires the image to have this width.
  ///
  /// If `null`, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  double? get width => _width;
  double? _width;
  set width(double? value) {
    if (value == _width) {
      return;
    }
    _width = value;
    markNeedsLayout();
  }

  /// If non-`null`, require the image to have this height.
  ///
  /// If `null`, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  double? get height => _height;
  double? _height;
  set height(double? value) {
    if (value == _height) {
      return;
    }
    _height = value;
    markNeedsLayout();
  }

  /// Specifies the image's scale.
  ///
  /// Used when determining the best display size for the image.
  double get scale => _scale;
  double _scale;
  set scale(double value) {
    if (value == _scale) {
      return;
    }
    _scale = value;
    markNeedsLayout();
  }

  ColorFilter? _colorFilter;

  void _updateColorFilter() {
    if (_color == null) {
      _colorFilter = null;
    } else {
      _colorFilter =
          ColorFilter.mode(_color!, _colorBlendMode ?? BlendMode.srcIn);
    }
  }

  /// If non-`null`, this color is blended with each image pixel using
  /// [colorBlendMode].
  Color? get color => _color;
  Color? _color;
  set color(Color? value) {
    if (value == _color) {
      return;
    }
    _color = value;
    _updateColorFilter();
    markNeedsPaint();
  }

  /// Used to set the [filterQuality] of the image.
  ///
  /// Use the [FilterQuality.low] quality setting to scale the image, which
  /// corresponds to bilinear interpolation, rather than the default
  /// [FilterQuality.none] which corresponds to nearest-neighbor.
  FilterQuality get filterQuality => _filterQuality;
  FilterQuality _filterQuality;
  set filterQuality(FilterQuality value) {
    if (value == _filterQuality) {
      return;
    }
    _filterQuality = value;
    markNeedsPaint();
  }

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each
  ///  blend mode.
  BlendMode? get colorBlendMode => _colorBlendMode;
  BlendMode? _colorBlendMode;
  set colorBlendMode(BlendMode? value) {
    if (value == _colorBlendMode) {
      return;
    }
    _colorBlendMode = value;
    _updateColorFilter();
    markNeedsPaint();
  }

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  BoxFit? get fit => _fit;
  BoxFit? _fit;
  set fit(BoxFit? value) {
    if (value == _fit) {
      return;
    }
    _fit = value;
    markNeedsPaint();
  }

  /// How to align the image within its bounds.
  ///
  /// If this is set to a text-direction-dependent value, [textDirection] must
  /// not be `null`.
  ///
  /// Ignored if [repeat] is [Repeat.mirror], `mirrorX`, or `mirrorY`.
  /// In this context, see [mirrorOffset].
  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    if (value == _alignment) {
      return;
    }
    _alignment = value;
    _markNeedResolution();
  }

  /// How to repeat this image if it does not fill its layout bounds.
  ///
  /// This is the special ingredient for a [RenderImageToo] and allows
  /// the creation of seamless, tiling textures with any given image.
  ///
  /// See [Repeat].
  Repeat get repeat => _repeat;
  Repeat _repeat;
  set repeat(Repeat value) {
    if (value == _repeat) {
      return;
    }
    _repeat = value;
    markNeedsPaint();
  }

  /// How to translate this image if is it to be [Repeat.mirror]ed
  /// prior to painting. Replaces [alignment] in this context.
  Offset get mirrorOffset => _mirrorOffset;
  Offset _mirrorOffset;
  set mirrorOffset(Offset value) {
    if (value == _mirrorOffset) {
      return;
    }
    _mirrorOffset = value;
    markNeedsPaint();
  }

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  Rect? get centerSlice => _centerSlice;
  Rect? _centerSlice;
  set centerSlice(Rect? value) {
    if (value == _centerSlice) {
      return;
    }
    _centerSlice = value;
    markNeedsPaint();
  }

  /// Whether to invert the colors of the image.
  ///
  /// inverting the colors of an image applies a new color filter to the paint.
  /// If there is another specified color filter, the invert will be applied
  /// after it. This is primarily used for implementing smart invert on iOS.
  bool get invertColors => _invertColors;
  bool _invertColors;
  set invertColors(bool value) {
    if (value == _invertColors) {
      return;
    }
    _invertColors = value;
    markNeedsPaint();
  }

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with images in right-to-left environments, for
  /// images that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip images with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is set to true, [textDirection] must not be `null`.
  bool get matchTextDirection => _matchTextDirection;
  bool _matchTextDirection;
  set matchTextDirection(bool value) {
    if (value == _matchTextDirection) {
      return;
    }
    _matchTextDirection = value;
    _markNeedResolution();
  }

  /// The text direction with which to resolve [alignment].
  ///
  /// This may be changed to `null`, but only after the [alignment] and
  /// [matchTextDirection] properties have been changed to values that do not
  /// depend on the direction.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    _markNeedResolution();
  }

  /// Whether to paint the image with anti-aliasing.
  ///
  /// Anti-aliasing alleviates the sawtooth artifact when the image is rotated.
  bool get isAntiAlias => _isAntiAlias;
  bool _isAntiAlias;
  set isAntiAlias(bool value) {
    if (_isAntiAlias == value) {
      return;
    }
    _isAntiAlias = value;
    markNeedsPaint();
  }

  /// Find a size for the render image within the given constraints.
  ///
  ///  - The dimensions of the RenderImage must fit within the constraints.
  ///  - The aspect ratio of the RenderImage matches the intrinsic aspect
  ///    ratio of the image.
  ///  - The RenderImage's dimension are maximal subject to being smaller than
  ///    the intrinsic size of the image.
  Size _sizeForConstraints(BoxConstraints constraints) {
    // Folds the given |width| and |height| into |constraints| so they can all
    // be treated uniformly.
    constraints = BoxConstraints.tightFor(
      width: _width,
      height: _height,
    ).enforce(constraints);

    if (_image == null) {
      return constraints.smallest;
    }

    return constraints.constrainSizeAndAttemptToPreserveAspectRatio(Size(
      _image!.width.toDouble() / _scale,
      _image!.height.toDouble() / _scale,
    ));
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    assert(height >= 0.0);
    if (_width == null && _height == null) {
      return 0.0;
    }
    return _sizeForConstraints(BoxConstraints.tightForFinite(height: height))
        .width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(height >= 0.0);
    return _sizeForConstraints(BoxConstraints.tightForFinite(height: height))
        .width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    assert(width >= 0.0);
    if (_width == null && _height == null) {
      return 0.0;
    }
    return _sizeForConstraints(BoxConstraints.tightForFinite(width: width))
        .height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    assert(width >= 0.0);
    return _sizeForConstraints(BoxConstraints.tightForFinite(width: width))
        .height;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _sizeForConstraints(constraints);
  }

  @override
  void performLayout() {
    size = _sizeForConstraints(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_image == null) {
      return;
    }
    _resolve();
    assert(_resolvedAlignment != null);
    assert(_flipHorizontally != null);

    /// Expanded [paintImage] method that accepts a [Repeat].
    paintImageToo(
      canvas: context.canvas,
      rect: offset & size,
      image: _image!,
      debugImageLabel: debugImageLabel,
      scale: _scale,
      colorFilter: _colorFilter,
      fit: _fit,
      alignment: _resolvedAlignment!,
      centerSlice: _centerSlice,
      // FINALLY the meat and potatoes:
      // enabling mirroring tiles in the paint method.
      repeat: _repeat,
      mirrorOffset: _mirrorOffset,
      flipHorizontally: _flipHorizontally!,
      invertColors: invertColors,
      filterQuality: _filterQuality,
      isAntiAlias: _isAntiAlias,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ui.Image>('image', image))
      ..add(DoubleProperty('width', width, defaultValue: null))
      ..add(DoubleProperty('height', height, defaultValue: null))
      ..add(DoubleProperty('scale', scale, defaultValue: 1.0))
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(EnumProperty<BlendMode>('colorBlendMode', colorBlendMode,
          defaultValue: null))
      ..add(EnumProperty<BoxFit>('fit', fit, defaultValue: null))
      ..add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment,
          defaultValue: null))
      ..add(
          EnumProperty<Repeat>('repeat', repeat, defaultValue: Repeat.noRepeat))
      ..add(DiagnosticsProperty<Rect>('centerSlice', centerSlice,
          defaultValue: null))
      ..add(FlagProperty('matchTextDirection',
          value: matchTextDirection, ifTrue: 'match text direction'))
      ..add(EnumProperty<TextDirection>('textDirection', textDirection,
          defaultValue: null))
      ..add(DiagnosticsProperty<bool>('invertColors', invertColors))
      ..add(EnumProperty<FilterQuality>('filterQuality', filterQuality));
  }
}
