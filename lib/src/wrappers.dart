/// Short-hand wrappers and package-name fulfillment
/// - 🆕 [InkImg] - extends Ink, reimplements [Ink.image]
/// - [DecorationImg] - extends [DecorationImageToo]
/// - [Img] - extends [ImageToo]
library img;

import 'dart:io';
import 'dart:typed_data';

import 'common.dart';

import 'models/decoration.dart';
import 'painting.dart';
import 'widgets/image_too.dart';

/// A convenience widget for drawing images and other decorations on [Material]
/// widgets, so that [InkWell] and [InkResponse] splashes will render over them.
///
/// Ink splashes and highlights, as rendered by [InkWell] and [InkResponse],
/// draw on the actual underlying [Material], under whatever widgets are drawn
/// over the material (such as [Text] and [Icon]s). If an opaque image is drawn
/// over the [Material] (maybe using a [Container] or [DecoratedBox]), these ink
/// effects will not be visible, as they will be entirely obscured by the opaque
/// graphics drawn above the [Material].
///
/// This widget draws the given [Decoration] directly on the [Material], in the
/// same way that [InkWell] and [InkResponse] draw there. This allows the
/// splashes to be drawn above the otherwise opaque graphics.
///
/// An alternative solution is to use a [MaterialType.transparency] material
/// above the opaque graphics, so that the ink responses from [InkWell]s and
/// [InkResponse]s will be drawn on the transparent material on top of the
/// opaque graphics, rather than under the opaque graphics on the underlying
/// [Material].
///
/// ## Limitations
///
/// This widget is subject to the same limitations as other ink effects, as
/// described in the documentation for [Material]. Most notably, the position of
/// an [Ink] widget must not change during the lifetime of the [Material] object
/// unless a [LayoutChangedNotification] is dispatched each frame that the
/// position changes. This is done automatically for [ListView] and other
/// scrolling widgets, but is not done for animated transitions such as
/// [SlideTransition].
///
/// Additionally, if multiple [Ink] widgets paint on the same [Material] in the
/// same location, their relative order is not guaranteed. The decorations will
/// be painted in the order that they were added to the material, which
/// generally speaking will match the order they are given in the widget tree,
/// but this order may appear to be somewhat random in more dynamic situations.
///
/// {@tool snippet}
///
/// The following example shows how an image can be printed on a [Material]
/// widget with an [InkWell] above it:
///
/// ```dart
/// Material(
///   color: Colors.grey[800],
///   child: Center(
///     child: InkImg(
///       image: const AssetImage('cat.jpeg'),
///       fit: BoxFit.cover,
///       width: 300.0,
///       height: 200.0,
///       child: InkWell(
///         onTap: () { /* ... */ },
///         child: const Align(
///           alignment: Alignment.topLeft,
///           child: Padding(
///             padding: EdgeInsets.all(10.0),
///             child: Text(
///               'KITTEN',
///               style: TextStyle(
///                 fontWeight: FontWeight.w900,
///                 color: Colors.white,
///               ),
///             ),
///           ),
///         )
///       ),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Container], a more generic form of this widget which paints itself,
///    rather that deferring to the nearest [Material] widget.
///  * [InkDecoration], the [InkFeature] subclass used by this widget to paint
///    on [Material] widgets.
///  * [InkWell] and [InkResponse], which also draw on [Material] widgets.
///
/// (Description copied from [Ink].)
class InkImg extends Ink {
  /// Creates a widget that shows an image (obtained from an [ImageProvider]) on
  /// a [Material] and whose underlying decoration supports the [Repeat]
  /// rendering modes including [Repeat.mirror].
  ///
  /// Also adds `color` capability, which would render underneath the image
  /// if provided.
  ///
  /// This argument is a shorthand for passing a [BoxDecoration] that has only
  /// its [BoxDecoration.image] property (and potentially `color`) set
  /// to the [Ink] constructor. The properties of the [DecorationImageToo] of
  /// that [BoxDecoration] are set according to the arguments passed to this
  /// constructor.
  ///
  /// The `image` argument must not be `null`. If there is no
  /// intention to render anything on this image, consider using a
  /// [Container] with a [BoxDecoration.image] instead. The `onImageError`
  /// argument may be provided to listen for errors when resolving the image.
  ///
  /// The `alignment`, `repeat`, and `matchTextDirection` arguments must not
  /// be null either, but they have default values.
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
  InkImg({
    Key? key,
    Color? color,
    required ImageProvider image,
    double scale = 1.0,
    double? width,
    double? height,
    EdgeInsets? padding,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    Repeat repeat = Repeat.noRepeat,
    Offset mirrorOffset = Offset.zero,
    ColorFilter? colorFilter,
    Rect? centerSlice,
    bool matchTextDirection = false,
    Widget? child,
    ImageErrorListener? onImageError,
  })  : assert(padding == null || padding.isNonNegative),
        super(
          key: key,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            image: DecorationImg(
              image: image,
              scale: scale,
              fit: fit,
              alignment: alignment,
              repeatMode: repeat,
              mirrorOffset: mirrorOffset,
              colorFilter: colorFilter,
              centerSlice: centerSlice,
              matchTextDirection: matchTextDirection,
              onError: onImageError,
            ),
          ),
          width: width,
          height: height,
          child: child,
        );
}

/// A shorthand wrapper for [DecorationImageToo].
class DecorationImg extends DecorationImageToo {
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
  const DecorationImg({
    required ImageProvider image,
    double scale = 1.0,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    Repeat repeatMode = Repeat.noRepeat,
    Offset mirrorOffset = Offset.zero,
    ColorFilter? colorFilter,
    Rect? centerSlice,
    bool matchTextDirection = false,
    ImageErrorListener? onError,
  }) : super(
          image: image,
          scale: scale,
          fit: fit,
          alignment: alignment,
          repeatMode: repeatMode,
          mirrorOffset: mirrorOffset,
          colorFilter: colorFilter,
          centerSlice: centerSlice,
          matchTextDirection: matchTextDirection,
          onError: onError,
        );
}

/// A shorthand wrapper for [ImageToo].
///
/// A [StatefulWidget] that renders an [image] according to a swath of
/// optional properties. Several constructors are provided for drawing an
/// image from a variety of sources.
///
/// All of these image widgets support an expanded concept of `ImageRepeat`
/// defined as [Repeat]. Thus this `ImageToo` can render an image smaller than
/// its bounds by mirror-tiling with [Repeat.mirror] as well as the expected
/// values such as [Repeat.noRepeat], [Repeat.repeat], etc.
///
/// This is the core difference between an [Image] and an [ImageToo].
///
/// Construct a `const` [new ImageToo] with an [ImageProvider] as the [image]
/// property.
///
/// [new ImageToo.network] demands a `String` representing the URL path to a
/// network hosted image.
///
/// [new ImageToo.file] demands a [File] representing the image on the
/// local disk.
///
/// [new ImageToo.asset] demands a `String` and optional [AssetBundle]
/// describing the image as an asset included with a package.
///
/// [new ImageToo.memory] constructs an image from a [Uint8List] of bytes.
class Img extends ImageToo {
  /// A [StatefulWidget] that renders its required [image] field, an
  /// [ImageProvider], according to the other optional properties.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat]. Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with [Repeat.mirror] as well as the expected
  /// values such as [Repeat.noRepeat], [Repeat.repeat], etc.
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
  const Img({
    Key? key,
    required ImageProvider image,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    Repeat repeat = Repeat.noRepeat,
    Offset mirrorOffset = Offset.zero,
    Color? color,
    BlendMode? colorBlendMode,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
  }) : super(
          key: key,
          image: image,
          frameBuilder: frameBuilder,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          semanticLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          width: width,
          height: height,
          color: color,
          colorBlendMode: colorBlendMode,
          fit: fit,
          alignment: alignment,
          repeat: repeat,
          mirrorOffset: mirrorOffset,
          centerSlice: centerSlice,
          matchTextDirection: matchTextDirection,
          gaplessPlayback: gaplessPlayback,
          isAntiAlias: isAntiAlias,
          filterQuality: filterQuality,
        );

  /// A [StatefulWidget] that renders an image from a web server defined by the
  /// URL [src], the required `String` at the front of this constructor.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat]. Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with [Repeat.mirror] as well as the expected
  /// values such as [Repeat.noRepeat], [Repeat.repeat], etc.
  ///
  /// For a `const ImageToo`, construct a [new ImageToo] with an [ImageProvider]
  /// as the `image` property.
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
  Img.network(
    String src, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    double scale = 1.0,
    AlignmentGeometry alignment = Alignment.center,
    Repeat repeat = Repeat.noRepeat,
    Offset mirrorOffset = Offset.zero,
    Color? color,
    BlendMode? colorBlendMode,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    Map<String, String>? headers,
    int? cacheWidth,
    int? cacheHeight,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
  }) : super.network(
          src,
          scale: scale,
          key: key,
          frameBuilder: frameBuilder,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          semanticLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          width: width,
          height: height,
          color: color,
          colorBlendMode: colorBlendMode,
          fit: fit,
          alignment: alignment,
          repeat: repeat,
          mirrorOffset: mirrorOffset,
          centerSlice: centerSlice,
          matchTextDirection: matchTextDirection,
          gaplessPlayback: gaplessPlayback,
          isAntiAlias: isAntiAlias,
          filterQuality: filterQuality,
          headers: headers,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        );

  /// A [StatefulWidget] that renders an image from a [File], the required value
  /// at the front of this constructor.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat]. Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with [Repeat.mirror] as well as the expected
  /// values such as [Repeat.noRepeat], [Repeat.repeat], etc.
  ///
  /// For a `const ImageToo`, construct a [new ImageToo] with an [ImageProvider]
  /// as the `image` property.
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
  Img.file(
    File file, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    double scale = 1.0,
    AlignmentGeometry alignment = Alignment.center,
    Repeat repeat = Repeat.noRepeat,
    Offset mirrorOffset = Offset.zero,
    Color? color,
    BlendMode? colorBlendMode,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    int? cacheWidth,
    int? cacheHeight,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
  }) : super.file(file,
            key: key,
            scale: scale,
            frameBuilder: frameBuilder,
            errorBuilder: errorBuilder,
            semanticLabel: semanticLabel,
            excludeFromSemantics: excludeFromSemantics,
            width: width,
            height: height,
            color: color,
            colorBlendMode: colorBlendMode,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
            mirrorOffset: mirrorOffset,
            centerSlice: centerSlice,
            matchTextDirection: matchTextDirection,
            gaplessPlayback: gaplessPlayback,
            isAntiAlias: isAntiAlias,
            filterQuality: filterQuality,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight);

  /// A [StatefulWidget] that renders an image from an optional `bundle`
  /// [AssetBundle] that is defined by [name], the required `String` at
  /// the front of this constructor.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat]. Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with [Repeat.mirror] as well as the expected
  /// values such as [Repeat.noRepeat], [Repeat.repeat], etc.
  ///
  /// For a `const ImageToo`, construct a [new ImageToo] with an [ImageProvider]
  /// as the `image` property.
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
  Img.asset(
    String name, {
    Key? key,
    AssetBundle? bundle,
    double? scale,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    Repeat repeat = Repeat.noRepeat,
    Offset mirrorOffset = Offset.zero,
    Color? color,
    BlendMode? colorBlendMode,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    String? package,
    int? cacheWidth,
    int? cacheHeight,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
  }) : super.asset(
          name,
          key: key,
          bundle: bundle,
          frameBuilder: frameBuilder,
          errorBuilder: errorBuilder,
          semanticLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          scale: scale,
          width: width,
          height: height,
          color: color,
          colorBlendMode: colorBlendMode,
          fit: fit,
          alignment: alignment,
          repeat: repeat,
          mirrorOffset: mirrorOffset,
          centerSlice: centerSlice,
          matchTextDirection: matchTextDirection,
          gaplessPlayback: gaplessPlayback,
          isAntiAlias: isAntiAlias,
          package: package,
          filterQuality: filterQuality,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        );

  /// A [StatefulWidget] that renders an image based on a list of data [bytes]
  /// representing that image in memory, the required [Uint8List] at the front
  /// of this constructor.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat]. Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with [Repeat.mirror] as well as the expected
  /// values such as [Repeat.noRepeat], [Repeat.repeat], etc.
  ///
  /// For a `const ImageToo`, construct a [new ImageToo] with an [ImageProvider]
  /// as the `image` property.
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
  Img.memory(
    Uint8List bytes, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    double scale = 1.0,
    AlignmentGeometry alignment = Alignment.center,
    Repeat repeat = Repeat.noRepeat,
    Offset mirrorOffset = Offset.zero,
    Color? color,
    BlendMode? colorBlendMode,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    int? cacheWidth,
    int? cacheHeight,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
  }) : super.memory(
          bytes,
          key: key,
          scale: scale,
          frameBuilder: frameBuilder,
          errorBuilder: errorBuilder,
          semanticLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          width: width,
          height: height,
          color: color,
          colorBlendMode: colorBlendMode,
          fit: fit,
          alignment: alignment,
          repeat: repeat,
          mirrorOffset: mirrorOffset,
          centerSlice: centerSlice,
          matchTextDirection: matchTextDirection,
          gaplessPlayback: gaplessPlayback,
          isAntiAlias: isAntiAlias,
          filterQuality: filterQuality,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        );
}
