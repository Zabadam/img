/// Provides the `StatefulWidget` [ImageToo]. Think [Image] but this
/// widget's `repeat` property accepts a bespoke [Repeat] object which is
/// forwared along to a `LeafRenderObject` called [RawImageToo], itself
/// creating a [RenderImageToo]; all fully aware of the new `Repeat` type and
/// deferrent to a new `paintImageToo()` method as opposed to the traditional
/// `paintImage()` call.
//
//  Consider LICENSE file, as some code comes from the Flutter source itself.
library img;

import 'dart:io' show File;
import 'dart:typed_data';

import '../common.dart';

import '../rendering.dart';
import '../utils.dart';

/// A [StatefulWidget] that renders an [image] according to a swath of
/// optional properties. Several constructors are provided for painting an
/// image from a variety of sources.
///
/// Abstracts the rendering of a `dart:ui` `Image` by returning a configured
/// [RawImageToo] (which creates a [RenderImageToo] `RenderBox`).
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
class ImageToo extends StatefulWidget {
  /// A [StatefulWidget] that renders its required [image] field, an [ImageProvider], \
  /// according to the other optional properties.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat].
  ///
  /// Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with \
  /// [Repeat.mirror] as well as the expected values such as [Repeat.noRepeat],
  /// [Repeat.repeat], etc.
  ///
  /// For convenience, consider [StringToTexture]. It is used by calling one of
  /// the three methods \
  /// (one each for [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY])
  /// on a `String` such as:
  ///
  /// ```dart
  /// final Widget imageToo = 'https://url.to/image.png'.toSeamlessTexture();
  /// ```
  ///
  /// For a `const ImageToo`, construct a [new ImageToo] with an [ImageProvider]
  /// as the `image` property.
  ///
  /// ---
  /// Like all `package:img` classes, `alignment` is ignored and forced [Alignment.center] \
  /// if [repeat] is set to [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, \
  ///   employ an [Offset] in the [mirrorOffset] field.
  /// - This is a workaround for now and only aids in "aligning" a `Repeat.mirror` \
  /// tiled image if it is meant to fill an entire space, shifting its edges.
  const ImageToo({
    Key? key,
    required this.image,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = Repeat.noRepeat,
    this.mirrorOffset = Offset.zero,
    this.color,
    this.colorBlendMode,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.frameBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);

  /// A [StatefulWidget] that renders an image from a web server defined by the
  /// URL [src], \
  /// the required `String` at the front of this constructor.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat].
  ///
  /// Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with \
  /// [Repeat.mirror] as well as the expected values such as [Repeat.noRepeat],
  /// [Repeat.repeat], etc.
  ///
  /// For convenience, consider [StringToTexture]. It is used by calling one of
  /// the three methods \
  /// (one each for [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY])
  /// on a `String` such as:
  ///
  /// ```dart
  /// final Widget imageToo = 'https://url.to/image.png'.toSeamlessTexture();
  /// ```
  ///
  /// For a `const ImageToo`, construct a [new ImageToo] with an [ImageProvider]
  /// as the `image` property.
  ///
  /// ---
  /// Like all `package:img` classes, `alignment` is ignored and forced [Alignment.center] \
  /// if [repeat] is set to [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, \
  ///   employ an [Offset] in the [mirrorOffset] field.
  /// - This is a workaround for now and only aids in "aligning" a `Repeat.mirror` \
  /// tiled image if it is meant to fill an entire space, shifting its edges.
  ImageToo.network(
    String src, {
    Key? key,
    this.width,
    this.height,
    this.fit,
    double scale = 1.0,
    this.alignment = Alignment.center,
    this.repeat = Repeat.noRepeat,
    this.mirrorOffset = Offset.zero,
    this.color,
    this.colorBlendMode,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.isAntiAlias = false,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    Map<String, String>? headers,
    int? cacheWidth,
    int? cacheHeight,
    this.frameBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  })  : image = ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight,
            NetworkImage(src, scale: scale, headers: headers)),
        assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        super(key: key);

  /// A [StatefulWidget] that renders an image from a [File], the required value
  /// at the front of this constructor.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat].
  ///
  /// Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with \
  /// [Repeat.mirror] as well as the expected values such as [Repeat.noRepeat],
  /// [Repeat.repeat], etc.
  ///
  /// For convenience, consider [FileToTexture]. It is used by calling one of
  /// the three methods \
  /// (one each for [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY])
  /// on a `File` such as:
  ///
  /// ```dart
  /// final Widget imageToo = File(...).toSeamlessTexture();
  /// ```
  ///
  /// For a `const ImageToo`, construct a [new ImageToo] with an [ImageProvider]
  /// as the `image` property.
  ///
  /// ---
  /// Like all `package:img` classes, `alignment` is ignored and forced [Alignment.center] \
  /// if [repeat] is set to [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, \
  ///   employ an [Offset] in the [mirrorOffset] field.
  /// - This is a workaround for now and only aids in "aligning" a `Repeat.mirror` \
  /// tiled image if it is meant to fill an entire space, shifting its edges.
  ImageToo.file(
    File file, {
    Key? key,
    this.width,
    this.height,
    this.fit,
    double scale = 1.0,
    this.alignment = Alignment.center,
    this.repeat = Repeat.noRepeat,
    this.mirrorOffset = Offset.zero,
    this.color,
    this.colorBlendMode,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    int? cacheWidth,
    int? cacheHeight,
    this.frameBuilder,
    this.errorBuilder,
  })  : image = ResizeImage.resizeIfNeeded(
            cacheWidth, cacheHeight, FileImage(file, scale: scale)),
        loadingBuilder = null,
        assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        super(key: key);

  /// A [StatefulWidget] that renders an image from an optional `bundle`
  /// [AssetBundle] that is defined by [name], the required `String` at
  /// the front of this constructor.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat].
  ///
  /// Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with \
  /// [Repeat.mirror] as well as the expected values such as [Repeat.noRepeat],
  /// [Repeat.repeat], etc.
  ///
  /// For convenience, consider [StringToTexture]. It is used by calling one of
  /// the three methods \
  /// (one each for [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY])
  /// on a `String` such as:
  ///
  /// ```dart
  /// final Widget imageToo = 'res/image.png'.toSeamlessTexture(isAsset: true);
  /// ```
  ///
  /// For a `const ImageToo`, construct a [new ImageToo] with an [ImageProvider]
  /// as the `image` property.
  ///
  /// ---
  /// Like all `package:img` classes, `alignment` is ignored and forced [Alignment.center] \
  /// if [repeat] is set to [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, \
  ///   employ an [Offset] in the [mirrorOffset] field.
  /// - This is a workaround for now and only aids in "aligning" a `Repeat.mirror` \
  /// tiled image if it is meant to fill an entire space, shifting its edges.
  ImageToo.asset(
    String name, {
    Key? key,
    AssetBundle? bundle,
    this.width,
    this.height,
    this.fit,
    double? scale,
    this.alignment = Alignment.center,
    this.repeat = Repeat.noRepeat,
    this.mirrorOffset = Offset.zero,
    this.color,
    this.colorBlendMode,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    String? package,
    int? cacheWidth,
    int? cacheHeight,
    this.frameBuilder,
    this.errorBuilder,
  })  : image = ResizeImage.resizeIfNeeded(
          cacheWidth,
          cacheHeight,
          scale != null
              ? ExactAssetImage(name,
                  bundle: bundle, scale: scale, package: package)
              : AssetImage(name, bundle: bundle, package: package),
        ),
        loadingBuilder = null,
        assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        super(key: key);

  /// A [StatefulWidget] that renders an image based on a list of data [bytes]
  /// representing that image in memory, the required [Uint8List] at the front
  /// of this constructor.
  ///
  /// This image `Widget` supports an expanded concept of `ImageRepeat` defined
  /// as [Repeat].
  ///
  /// Thus this `ImageToo` can render an image smaller than its
  /// bounds by mirror-tiling with \
  /// [Repeat.mirror] as well as the expected values such as [Repeat.noRepeat],
  /// [Repeat.repeat], etc.
  ///
  /// For convenience, consider [BytesToTexture]. It is used by calling one of
  /// the three methods \
  /// (one each for [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY])
  /// on a `Uint8List` such as:
  ///
  /// ```dart
  /// final Widget imageToo = Uint8List(...).toSeamlessTexture();
  /// ```
  ///
  /// For a `const ImageToo`, construct a [new ImageToo] with an [ImageProvider]
  /// as the `image` property.
  ///
  /// ---
  /// Like all `package:img` classes, `alignment` is ignored and forced [Alignment.center] \
  /// if [repeat] is set to [Repeat.mirror], [Repeat.mirrorX], [Repeat.mirrorY].
  /// - To align/position the seamlessly-tiling image in this situation, \
  ///   employ an [Offset] in the [mirrorOffset] field.
  /// - This is a workaround for now and only aids in "aligning" a `Repeat.mirror` \
  /// tiled image if it is meant to fill an entire space, shifting its edges.
  ImageToo.memory(
    Uint8List bytes, {
    Key? key,
    this.width,
    this.height,
    this.fit,
    double scale = 1.0,
    this.alignment = Alignment.center,
    this.repeat = Repeat.noRepeat,
    this.mirrorOffset = Offset.zero,
    this.color,
    this.colorBlendMode,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    int? cacheWidth,
    int? cacheHeight,
    this.frameBuilder,
    this.errorBuilder,
  })  : image = ResizeImage.resizeIfNeeded(
            cacheWidth, cacheHeight, MemoryImage(bytes, scale: scale)),
        loadingBuilder = null,
        assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        super(key: key);

  /// The image to display.
  final ImageProvider image;

  /// If non-`null`, require the image to have this width.
  ///
  /// If `null`, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double? width;

  /// If non-`null`, require the image to have this height.
  ///
  /// If `null`, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double? height;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit? fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of
  /// `(-1.0, -1.0)` aligns the image to the top-left corner of its layout
  /// bounds, while a value of `Alignment(1.0, 1.0)` aligns the bottom right of
  /// the image with the bottom right corner of its layout bounds. Similarly,
  /// an alignment of `(0.0, 1.0)` aligns the bottom middle of the image with
  /// the middle of the bottom edge of its layout bounds.
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
  /// This is the special ingredient for an [ImageToo] and allows
  /// the creation of seamless, tiling textures with any given image,
  /// if desired.
  ///
  /// In addition to the standard options expected from [ImageRepeat], this
  /// [Repeat] property has a few extra display choices.
  ///
  /// While a standard `Image` can be tiled in both axes with
  /// [ImageRepeat.repeat], an `ImageToo` may additionally be
  /// tiled with *mirroring* in both axes by [Repeat.mirror].
  ///
  /// Consider that [ImageRepeat.repeatX] tiles an image only horizontally then
  /// reason that [Repeat.mirrorX] also tiles an image horizontally but mirrors
  /// each odd-numbered tile. Also available is [Repeat.mirrorY].
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
  /// Corresponds to an additional translation to the canvas onto which
  /// this image is painted. For a mirror-tiling image, this has the effect
  /// of shifting the mirror edge seams.
  ///
  /// This property replaces and functions similar to [alignment] when [repeat]
  /// is [Repeat.mirror], [Repeat.mirrorX], or [Repeat.mirrorY], is currently
  /// only a workaround, and only truly acts as "alignment" if [Repeat.mirror].
  final Offset mirrorOffset;

  /// The rendering quality of the image.
  ///
  /// If the image is of a high quality and its pixels are perfectly aligned
  /// with the physical screen pixels, extra quality enhancement may not be
  /// necessary. If so, then [FilterQuality.none] would be the most efficient.
  ///
  /// If the pixels are not perfectly aligned with the screen pixels, or if the
  /// image itself is of a low quality, [FilterQuality.none] may produce
  /// undesirable artifacts. Consider using other [FilterQuality] values to
  /// improve the rendered image quality in this case. Pixels may be misaligned
  /// with the screen pixels as a result of transforms or scaling.
  ///
  /// See also:
  ///
  ///  * [FilterQuality], the enum containing all possible filter quality
  ///    options.
  final FilterQuality filterQuality;

  /// If non-`null`, this color is blended with each image pixel using
  /// [colorBlendMode].
  final Color? color;

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

  /// Whether to continue showing the old image (true), or briefly show nothing
  /// (false), when the image provider changes. The default value is false.
  ///
  /// ## Design discussion
  ///
  /// ### Why is the default value of [gaplessPlayback] false?
  ///
  /// Having the default value of [gaplessPlayback] be false helps prevent
  /// situations where stale or misleading information might be presented.
  /// Consider the following case:
  ///
  /// We have constructed a 'Person' widget that displays an avatar [ImageToo]
  /// of the currently loaded person along with their name. We could request for
  /// a new person to be loaded into the widget at any time. Suppose we have a
  /// person currently loaded and the widget loads a new person. What happens
  /// if the [ImageToo] fails to load?
  ///
  /// * Option A ([gaplessPlayback] = false): The new person's name is coupled
  /// with a blank image.
  ///
  /// * Option B ([gaplessPlayback] = true): The widget displays the avatar of
  /// the previous person and the name of the newly loaded person.
  ///
  /// This is why the default value is false. Most of the time, when you change
  /// the image provider you're not just changing the image, you're removing the
  /// old widget and adding a new one and not expecting them to have any
  /// relationship. With [gaplessPlayback] on you might accidentally break this
  /// expectation and re-use the old widget.
  final bool gaplessPlayback;

  /// A Semantic description of the image.
  ///
  /// Used to provide a description of the image to TalkBack on Android, and
  /// VoiceOver on iOS.
  final String? semanticLabel;

  /// Whether to exclude this image from semantics.
  ///
  /// Useful for images which do not contribute meaningful information to an
  /// application.
  final bool excludeFromSemantics;

  /// Whether to paint the image with anti-aliasing.
  ///
  /// Anti-aliasing alleviates the sawtooth artifact when the image is rotated.
  final bool isAntiAlias;

  /// A builder function responsible for creating the widget that represents
  /// this image.
  ///
  /// If this is `null`, this widget will display an image that is painted as
  /// soon as the first image frame is available (and will appear to "pop" in
  /// if it becomes available asynchronously). Callers might use this builder to
  /// add effects to the image (such as fading the image in when it becomes
  /// available) or to display a placeholder widget while the image is loading.
  ///
  /// To have finer-grained control over the way that an image's loading
  /// progress is communicated to the user, see [loadingBuilder].
  ///
  /// ## Chaining with [loadingBuilder]
  ///
  /// If a [loadingBuilder] has _also_ been specified for an image, the two
  /// builders will be chained together: the _result_ of this builder will
  /// be passed as the `child` argument to the [loadingBuilder]. For example,
  /// consider the following builders used in conjunction:
  ///
  /// {@template flutter.widgets.Image.frameBuilder.chainedBuildersExample}
  /// ```dart
  /// Image(
  ///   ...
  // ignore: lines_longer_than_80_chars
  ///   frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
  ///     return Padding(
  ///       padding: EdgeInsets.all(8.0),
  ///       child: child,
  ///     );
  ///   },
  // ignore: lines_longer_than_80_chars
  ///   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
  ///     return Center(child: child);
  ///   },
  /// )
  /// ```
  ///
  /// In this example, the widget hierarchy will contain the following:
  ///
  /// ```dart
  /// Center(
  ///   Padding(
  ///     padding: EdgeInsets.all(8.0),
  ///     child: <image>,
  ///   ),
  /// )
  /// ```
  /// {@endtemplate}
  ///
  /// {@tool dartpad --template=stateless_widget_material}
  ///
  /// The following sample demonstrates how to use this builder to implement an
  /// image that fades in once it's been loaded.
  ///
  /// This sample contains a limited subset of the functionality that the
  /// [FadeInImage] widget provides out of the box.
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return DecoratedBox(
  ///     decoration: BoxDecoration(
  ///       color: Colors.white,
  ///       border: Border.all(),
  ///       borderRadius: BorderRadius.circular(20),
  ///     ),
  ///     child: Image.network(
  ///       'https://flutter.github.io/assets-for-api-docs/assets/widgets/puffin.jpg',
  // ignore: lines_longer_than_80_chars
  ///       frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
  ///         if (wasSynchronouslyLoaded) {
  ///           return child;
  ///         }
  ///         return AnimatedOpacity(
  ///           child: child,
  ///           opacity: frame == null ? 0 : 1,
  ///           duration: const Duration(seconds: 1),
  ///           curve: Curves.easeOut,
  ///         );
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  final ImageFrameBuilder? frameBuilder;

  /// A builder that specifies the widget to display to the user while an image
  /// is still loading.
  ///
  /// If this is `null`, and the image is loaded incrementally (e.g. over a
  /// network), the user will receive no indication of the progress as the
  /// bytes of the image are loaded.
  ///
  /// For more information on how to interpret the arguments that are passed to
  /// this builder, see the documentation on [ImageLoadingBuilder].
  ///
  /// ## Performance implications
  ///
  /// If a [loadingBuilder] is specified for an image, the [ImageToo] widget is
  /// likely to be rebuilt on every
  /// [rendering pipeline frame](rendering/RendererBinding/drawFrame.html) until
  /// the image has loaded. This is useful for cases such as displaying a
  /// loading progress indicator, but for simpler cases such as displaying a
  /// placeholder widget that doesn't depend on the loading progress (e.g.
  /// static "loading" text), [frameBuilder] will likely work and not incur as
  /// much cost.
  ///
  /// ## Chaining with [frameBuilder]
  ///
  /// If a [frameBuilder] has _also_ been specified for an image, the two
  /// builders will be chained together: the `child` argument to this
  /// builder will contain the _result_ of the [frameBuilder]. For example,
  /// consider the following builders used in conjunction:
  ///
  /// {@macro flutter.widgets.Image.frameBuilder.chainedBuildersExample}
  ///
  /// {@tool dartpad --template=stateless_widget_material}
  ///
  /// The following sample uses [loadingBuilder] to show a
  /// [CircularProgressIndicator] while an image loads over the network.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return DecoratedBox(
  ///     decoration: BoxDecoration(
  ///       color: Colors.white,
  ///       border: Border.all(),
  ///       borderRadius: BorderRadius.circular(20),
  ///     ),
  ///     child: Image.network(
  ///       'https://example.com/image.jpg',
  // ignore: lines_longer_than_80_chars
  ///       loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
  ///         if (loadingProgress == null) {
  ///           return child;
  ///         }
  ///         return Center(
  ///           child: CircularProgressIndicator(
  ///             value: loadingProgress.expectedTotalBytes != null
  ///                 ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
  ///                 : null,
  ///           ),
  ///         );
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// Run against a real-world image on a slow network, the previous example
  /// renders the following loading progress indicator while the image loads
  /// before rendering the completed image.
  ///
  /// {@animation 400 400 https://flutter.github.io/assets-for-api-docs/assets/widgets/loading_progress_image.mp4}
  final ImageLoadingBuilder? loadingBuilder;

  /// A builder function that is called if an error occurs during image loading.
  ///
  /// If this builder is not provided, any exceptions will be reported to
  /// [FlutterError.onError]. If it is provided, the caller should either handle
  /// the exception by providing a replacement widget, or rethrow the exception.
  ///
  /// {@tool dartpad --template=stateless_widget_material}
  ///
  /// The following sample uses [errorBuilder] to show a '😢' in place of the
  /// image that fails to load, and prints the error to the console.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return DecoratedBox(
  ///     decoration: BoxDecoration(
  ///       color: Colors.white,
  ///       border: Border.all(),
  ///       borderRadius: BorderRadius.circular(20),
  ///     ),
  ///     child: Image.network(
  ///       'https://example.does.not.exist/image.jpg',
  // ignore: lines_longer_than_80_chars
  ///       errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
  ///         // Appropriate logging or analytics, e.g.
  ///         // myAnalytics.recordError(
  ///         //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
  ///         //   exception,
  ///         //   stackTrace,
  ///         // );
  ///         return const Text('😢');
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  _ImageTooState createState() => _ImageTooState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ImageProvider>('image', image))
      ..add(DiagnosticsProperty<Function>('frameBuilder', frameBuilder))
      ..add(DiagnosticsProperty<Function>('loadingBuilder', loadingBuilder))
      ..add(DoubleProperty('width', width, defaultValue: null))
      ..add(DoubleProperty('height', height, defaultValue: null))
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(EnumProperty<BlendMode>('colorBlendMode', colorBlendMode,
          defaultValue: null))
      ..add(EnumProperty<BoxFit>('fit', fit, defaultValue: null))
      ..add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment,
          defaultValue: null))
      ..add(
          EnumProperty<Repeat>('repeat', repeat, defaultValue: Repeat.noRepeat))
      ..add(EnumProperty<Offset>('mirrorOffset', mirrorOffset,
          defaultValue: Offset.zero))
      ..add(DiagnosticsProperty<Rect>('centerSlice', centerSlice,
          defaultValue: null))
      ..add(FlagProperty('matchTextDirection',
          value: matchTextDirection, ifTrue: 'match text direction'))
      ..add(StringProperty('semanticLabel', semanticLabel, defaultValue: null))
      ..add(DiagnosticsProperty<bool>(
          'this.excludeFromSemantics', excludeFromSemantics))
      ..add(EnumProperty<FilterQuality>('filterQuality', filterQuality));
  }
}

class _ImageTooState extends State<ImageToo> with WidgetsBindingObserver {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  ImageChunkEvent? _loadingProgress;
  bool _isListeningToStream = false;
  late bool _invertColors;
  int? _frameNumber;
  bool _wasSynchronouslyLoaded = false;
  late DisposableBuildContext<State<ImageToo>> _scrollAwareContext;
  Object? _lastException;
  StackTrace? _lastStack;
  ImageStreamCompleterHandle? _completerHandle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _scrollAwareContext = DisposableBuildContext<State<ImageToo>>(this);
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    WidgetsBinding.instance!.removeObserver(this);
    _stopListeningToStream();
    _completerHandle?.dispose();
    _scrollAwareContext.dispose();
    _replaceImage(info: null);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _updateInvertColors();
    _resolveImage();

    if (TickerMode.of(context)) {
      _listenToStream();
    } else {
      _stopListeningToStream(keepStreamAlive: true);
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ImageToo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isListeningToStream &&
        (widget.loadingBuilder == null) != (oldWidget.loadingBuilder == null)) {
      final oldListener = _getListener();
      _imageStream!.addListener(_getListener(recreateListener: true));
      _imageStream!.removeListener(oldListener);
    }
    if (widget.image != oldWidget.image) _resolveImage();
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    setState(_updateInvertColors);
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _updateInvertColors() {
    _invertColors = MediaQuery.maybeOf(context)?.invertColors ??
        SemanticsBinding.instance!.accessibilityFeatures.invertColors;
  }

  void _resolveImage() {
    final provider = ScrollAwareImageProvider<Object>(
      context: _scrollAwareContext,
      imageProvider: widget.image,
    );
    final newStream = provider.resolve(createLocalImageConfiguration(
      context,
      size: widget.width != null && widget.height != null
          ? Size(widget.width!, widget.height!)
          : null,
    ));
    _updateSourceStream(newStream);
  }

  ImageStreamListener? _imageStreamListener;
  ImageStreamListener _getListener({bool recreateListener = false}) {
    if (_imageStreamListener == null || recreateListener) {
      _lastException = null;
      _lastStack = null;
      _imageStreamListener = ImageStreamListener(
        _handleImageFrame,
        onChunk: widget.loadingBuilder == null ? null : _handleImageChunk,
        onError: widget.errorBuilder != null || kDebugMode
            ? (Object error, StackTrace? stackTrace) {
                setState(() {
                  _lastException = error;
                  _lastStack = stackTrace;
                });
                assert(() {
                  if (widget.errorBuilder == null) {
                    // ignore: only_throw_errors
                    throw error;
                  } // Ensures the error message is printed to the console.
                  return true;
                }());
              }
            : null,
      );
    }
    return _imageStreamListener!;
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _replaceImage(info: imageInfo);
      _loadingProgress = null;
      _lastException = null;
      _lastStack = null;
      _frameNumber = _frameNumber == null ? 0 : _frameNumber! + 1;
      _wasSynchronouslyLoaded = _wasSynchronouslyLoaded | synchronousCall;
    });
  }

  void _handleImageChunk(ImageChunkEvent event) {
    assert(widget.loadingBuilder != null);
    setState(() {
      _loadingProgress = event;
      _lastException = null;
      _lastStack = null;
    });
  }

  void _replaceImage({required ImageInfo? info}) {
    _imageInfo?.dispose();
    _imageInfo = info;
  }

  // Updates _imageStream to newStream, and moves the stream listener
  // registration from the old stream to the new stream (if a listener was
  // registered).
  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) return;

    if (_isListeningToStream) _imageStream!.removeListener(_getListener());

    if (!widget.gaplessPlayback) {
      setState(() {
        _replaceImage(info: null);
      });
    }

    setState(() {
      _loadingProgress = null;
      _frameNumber = null;
      _wasSynchronouslyLoaded = false;
    });

    _imageStream = newStream;
    if (_isListeningToStream) _imageStream!.addListener(_getListener());
  }

  void _listenToStream() {
    if (_isListeningToStream) return;

    _imageStream!.addListener(_getListener());
    _completerHandle?.dispose();
    _completerHandle = null;

    _isListeningToStream = true;
  }

  /// Stops listening to the image stream, if this state object has attached a
  /// listener.
  ///
  /// If the listener from this state is the last listener on the stream, the
  /// stream will be disposed. To keep the stream alive, set `keepStreamAlive`
  /// to true, which create [ImageStreamCompleterHandle] to keep the completer
  /// alive and is compatible with the [TickerMode] being off.
  void _stopListeningToStream({bool keepStreamAlive = false}) {
    if (!_isListeningToStream) return;

    if (keepStreamAlive &&
        _completerHandle == null &&
        _imageStream?.completer != null) {
      _completerHandle = _imageStream!.completer!.keepAlive();
    }

    _imageStream!.removeListener(_getListener());
    _isListeningToStream = false;
  }

  Widget _debugBuildErrorWidget(BuildContext context, Object error) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        const Positioned.fill(
          child: Placeholder(
            color: Color(0xCF8D021F),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            child: Text(
              '$error',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                shadows: <Shadow>[
                  Shadow(blurRadius: 1.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_lastException != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _lastException!, _lastStack);
      }
      if (kDebugMode) return _debugBuildErrorWidget(context, _lastException!);
    }

    Widget result = RawImageToo(
      // Do not clone the image, because RawImage is a stateless wrapper.
      // The image will be disposed by this state object when it is not needed
      // anymore, such as when it is unmounted or when the image stream pushes
      // a new image.
      image: _imageInfo?.image,
      debugImageLabel: _imageInfo?.debugLabel,
      width: widget.width,
      height: widget.height,
      scale: _imageInfo?.scale ?? 1.0,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      mirrorOffset: widget.mirrorOffset,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      invertColors: _invertColors,
      isAntiAlias: widget.isAntiAlias,
      filterQuality: widget.filterQuality,
    );

    if (!widget.excludeFromSemantics) {
      result = Semantics(
        container: widget.semanticLabel != null,
        image: true,
        label: widget.semanticLabel ?? '',
        child: result,
      );
    }

    if (widget.frameBuilder != null) {
      result = widget.frameBuilder!(
          context, result, _frameNumber, _wasSynchronouslyLoaded);
    }

    if (widget.loadingBuilder != null) {
      result = widget.loadingBuilder!(context, result, _loadingProgress);
    }

    return result;
  }

  @override
  void debugFillProperties(properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ImageStream>('stream', _imageStream))
      ..add(DiagnosticsProperty<ImageInfo>('pixels', _imageInfo))
      ..add(DiagnosticsProperty<ImageChunkEvent>(
          'loadingProgress', _loadingProgress))
      ..add(DiagnosticsProperty<int>('frameNumber', _frameNumber))
      ..add(DiagnosticsProperty<bool>(
          'wasSynchronouslyLoaded', _wasSynchronouslyLoaded));
  }
}
