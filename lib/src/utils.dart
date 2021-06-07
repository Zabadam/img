/// Provides extensions to the same types for which [ImageToo] has named
/// constructors. These extensions offer `toSeamlessTexture`,
/// `toSeamlessRow` and `toSeamlessColumn` to created mirror-tiling
/// "textures" easily with a simple method.
library img;

import 'dart:io';
import 'dart:typed_data';

import 'common.dart';

import 'widgets/image_too.dart';

/// Provides [toSeamlessTexture] that considers `this String` as a URL that
/// leads to an image and returns an [ImageToo] widget. \
/// This is default behavior.
///
/// If `isAsset` is passed `true`, the returning `ImageToo` expects
/// `this String` to be the path to a direct asset image.
///
/// The `repeat` property on this returned widget is set to [Repeat.mirror]
/// which has the effect of creating a seamless, edge-to-edge texture from
/// any image that will fill the space of the widget.
///
/// - For a horizontally-tiling texture using [Repeat.mirrorX],
///   see [toSeamlessRow].
/// - For a vertically-tiling texture using [Repeat.mirrorY],
///   see [toSeamlessColumn].
extension StringToTexture on String {
  /// A method that considers `this String` as a URL that leads to an image
  /// and returns an [ImageToo] widget. This is default behavior.
  ///
  /// If [isAsset] is passed `true`, the returning `ImageToo` expects
  /// `this String` to be the path to a direct asset image. In this scenario,
  /// further employ [bundle] or [package] if necessary.
  ///
  /// The `repeat` property on this returned widget is set to [Repeat.mirror]
  /// which has the effect of creating a seamless, edge-to-edge texture from
  /// any image that will fill the space of the widget.
  ///
  /// Some images fare better than others as far as the quality of the output.
  /// Most will appear kaleidoscopic at worst and magical at best.
  ///
  /// Still, condiering how *few* images out there are designed to support
  /// edge-to-edge tiling with a simple [Repeat.repeat] mode, this functionality
  /// broadly expands the versatility of using any image as a texture.
  ///
  /// - `color` is mixed with the image using `blendMode`.
  /// - Larger `scale` values render the image smaller.
  /// - Max x and y components for `offset` are equal to the resolution of the
  /// image and act to shift the texture's edges/translation.
  ///   - See [ImageToo.mirrorOffset].
  ImageToo toSeamlessTexture({
    double? width,
    double? height,
    double scale = 1.0,
    Offset offset = Offset.zero,
    Color? color,
    BlendMode? blendMode,
    FilterQuality quality = FilterQuality.low,
    bool isAntiAlias = false,
    bool isAsset = false,
    AssetBundle? bundle,
    String? package,
  }) =>
      isAsset
          ? ImageToo.asset(
              this,
              width: width,
              height: height,
              scale: scale,
              repeat: Repeat.mirror,
              mirrorOffset: offset,
              color: color,
              colorBlendMode: blendMode,
              filterQuality: quality,
              isAntiAlias: isAntiAlias,
              bundle: bundle,
              package: package,
            )
          : ImageToo.network(
              this,
              width: width,
              height: height,
              scale: scale,
              repeat: Repeat.mirror,
              mirrorOffset: offset,
              color: color,
              colorBlendMode: blendMode,
              filterQuality: quality,
              isAntiAlias: isAntiAlias,
            );

  /// A method that considers `this String` as a URL that leads to an image
  /// and returns an [ImageToo] widget. This is default behavior.
  ///
  /// If [isAsset] is passed `true`, the returning `ImageToo` expects
  /// `this String` to be the path to a direct asset image. In this scenario,
  /// further employ [bundle] or [package] if necessary.
  ///
  /// The `repeat` property on this returned widget is set to [Repeat.mirrorX]
  /// which has the effect of creating a seamless, edge-to-edge horizontal
  /// texture from any image that will fill the space of the widget.
  ///
  /// Some images fare better than others as far as the quality of the output.
  /// Most will appear kaleidoscopic at worst and magical at best.
  ///
  /// Still, condiering how *few* images out there are designed to support
  /// edge-to-edge tiling with a simple [Repeat.repeat] mode, this functionality
  /// broadly expands the versatility of using any image as a texture.
  ///
  /// - `color` is mixed with the image using `blendMode`.
  /// - Larger `scale` values render the image smaller.
  /// - Max x and y components for `offset` are equal to the resolution of the
  /// image and act to shift the texture's edges/translation.
  ///   - See [ImageToo.mirrorOffset].
  ImageToo toSeamlessRow({
    double? width,
    double? height,
    double scale = 1.0,
    Offset offset = Offset.zero,
    Color? color,
    BlendMode? blendMode,
    FilterQuality quality = FilterQuality.low,
    bool isAntiAlias = false,
    bool isAsset = false,
    AssetBundle? bundle,
    String? package,
  }) =>
      isAsset
          ? ImageToo.asset(
              this,
              width: width,
              height: height,
              scale: scale,
              repeat: Repeat.mirrorX,
              mirrorOffset: offset,
              color: color,
              colorBlendMode: blendMode,
              filterQuality: quality,
              isAntiAlias: isAntiAlias,
              bundle: bundle,
              package: package,
            )
          : ImageToo.network(
              this,
              width: width,
              height: height,
              scale: scale,
              repeat: Repeat.mirrorX,
              mirrorOffset: offset,
              color: color,
              colorBlendMode: blendMode,
              filterQuality: quality,
              isAntiAlias: isAntiAlias,
            );

  /// A method that considers `this String` as a URL that leads to an image
  /// and returns an [ImageToo] widget. This is default behavior.
  ///
  /// If [isAsset] is passed `true`, the returning `ImageToo` expects
  /// `this String` to be the path to a direct asset image. In this scenario,
  /// further employ [bundle] or [package] if necessary.
  ///
  /// The `repeat` property on this returned widget is set to [Repeat.mirrorY]
  /// which has the effect of creating a seamless, edge-to-edge vertical
  /// texture from any image that will fill the space of the widget.
  ///
  /// Some images fare better than others as far as the quality of the output.
  /// Most will appear kaleidoscopic at worst and magical at best.
  ///
  /// Still, condiering how *few* images out there are designed to support
  /// edge-to-edge tiling with a simple [Repeat.repeat] mode, this functionality
  /// broadly expands the versatility of using any image as a texture.
  ///
  /// - `color` is mixed with the image using `blendMode`.
  /// - Larger `scale` values render the image smaller.
  /// - Max x and y components for `offset` are equal to the resolution of the
  /// image and act to shift the texture's edges/translation.
  ///   - See [ImageToo.mirrorOffset].
  ImageToo toSeamlessColumn({
    double? width,
    double? height,
    double scale = 1.0,
    Offset offset = Offset.zero,
    Color? color,
    BlendMode? blendMode,
    FilterQuality quality = FilterQuality.low,
    bool isAntiAlias = false,
    bool isAsset = false,
    AssetBundle? bundle,
    String? package,
  }) =>
      isAsset
          ? ImageToo.asset(
              this,
              width: width,
              height: height,
              scale: scale,
              repeat: Repeat.mirrorY,
              mirrorOffset: offset,
              color: color,
              colorBlendMode: blendMode,
              filterQuality: quality,
              isAntiAlias: isAntiAlias,
              bundle: bundle,
              package: package,
            )
          : ImageToo.network(
              this,
              width: width,
              height: height,
              scale: scale,
              repeat: Repeat.mirrorY,
              mirrorOffset: offset,
              color: color,
              colorBlendMode: blendMode,
              filterQuality: quality,
              isAntiAlias: isAntiAlias,
            );
}

/// Provides [toSeamlessTexture] that considers `this File` as a file that
/// leads to an image and returns an [ImageToo] widget.
///
/// The `repeat` property on this returned widget is set to [Repeat.mirror]
/// which has the effect of creating a seamless, edge-to-edge texture from
/// any image that will fill the space of the widget.
///
/// - For a horizontally-tiling texture using [Repeat.mirrorX],
///   see [toSeamlessRow].
/// - For a vertically-tiling texture using [Repeat.mirrorY],
///   see [toSeamlessColumn].
extension FileToTexture on File {
  /// A method that considers `this File` as a file that leads to an image
  /// and returns an [ImageToo] widget.
  ///
  /// The `repeat` property on this returned widget is set to [Repeat.mirror]
  /// which has the effect of creating a seamless, edge-to-edge texture from
  /// any image that will fill the space of the widget.
  ///
  /// Some images fare better than others as far as the quality of the output.
  /// Most will appear kaleidoscopic at worst and magical at best.
  ///
  /// Still, condiering how *few* images out there are designed to support
  /// edge-to-edge tiling with a simple [Repeat.repeat] mode, this functionality
  /// broadly expands the versatility of using any image as a texture.
  ///
  /// - `color` is mixed with the image using `blendMode`.
  /// - Larger `scale` values render the image smaller.
  /// - Max x and y components for `offset` are equal to the resolution of the
  /// image and act to shift the texture's edges/translation.
  ///   - See [ImageToo.mirrorOffset].
  ImageToo toSeamlessTexture({
    double? width,
    double? height,
    double scale = 1.0,
    Offset offset = Offset.zero,
    Color? color,
    BlendMode? blendMode,
    FilterQuality quality = FilterQuality.low,
    bool isAntiAlias = false,
    AssetBundle? bundle,
    String? package,
  }) =>
      ImageToo.file(
        this,
        width: width,
        height: height,
        scale: scale,
        repeat: Repeat.mirror,
        mirrorOffset: offset,
        color: color,
        colorBlendMode: blendMode,
        filterQuality: quality,
        isAntiAlias: isAntiAlias,
      );

  /// A method that considers `this File` as a file that leads to an image
  /// and returns an [ImageToo] widget.
  ///
  /// The `repeat` property on this returned widget is set to [Repeat.mirrorX]
  /// which has the effect of creating a seamless, edge-to-edge horizontal
  /// texture from any image that will fill the space of the widget.
  ///
  /// Some images fare better than others as far as the quality of the output.
  /// Most will appear kaleidoscopic at worst and magical at best.
  ///
  /// Still, condiering how *few* images out there are designed to support
  /// edge-to-edge tiling with a simple [Repeat.repeat] mode, this functionality
  /// broadly expands the versatility of using any image as a texture.
  ///
  /// - `color` is mixed with the image using `blendMode`.
  /// - Larger `scale` values render the image smaller.
  /// - Max x and y components for `offset` are equal to the resolution of the
  /// image and act to shift the texture's edges/translation.
  ///   - See [ImageToo.mirrorOffset].
  ImageToo toSeamlessRow({
    double? width,
    double? height,
    double scale = 1.0,
    Offset offset = Offset.zero,
    Color? color,
    BlendMode? blendMode,
    FilterQuality quality = FilterQuality.low,
    bool isAntiAlias = false,
    bool isAsset = false,
    AssetBundle? bundle,
    String? package,
  }) =>
      ImageToo.file(
        this,
        width: width,
        height: height,
        scale: scale,
        repeat: Repeat.mirrorX,
        mirrorOffset: offset,
        color: color,
        colorBlendMode: blendMode,
        filterQuality: quality,
        isAntiAlias: isAntiAlias,
      );

  /// A method that considers `this File` as a file that leads to an image
  /// and returns an [ImageToo] widget.
  ///
  /// The `repeat` property on this returned widget is set to [Repeat.mirrorY]
  /// which has the effect of creating a seamless, edge-to-edge vertical
  /// texture from any image that will fill the space of the widget.
  ///
  /// Some images fare better than others as far as the quality of the output.
  /// Most will appear kaleidoscopic at worst and magical at best.
  ///
  /// Still, condiering how *few* images out there are designed to support
  /// edge-to-edge tiling with a simple [Repeat.repeat] mode, this functionality
  /// broadly expands the versatility of using any image as a texture.
  ///
  /// - `color` is mixed with the image using `blendMode`.
  /// - Larger `scale` values render the image smaller.
  /// - Max x and y components for `offset` are equal to the resolution of the
  /// image and act to shift the texture's edges/translation.
  ///   - See [ImageToo.mirrorOffset].
  ImageToo toSeamlessColumn({
    double? width,
    double? height,
    double scale = 1.0,
    Offset offset = Offset.zero,
    Color? color,
    BlendMode? blendMode,
    FilterQuality quality = FilterQuality.low,
    bool isAntiAlias = false,
    bool isAsset = false,
    AssetBundle? bundle,
    String? package,
  }) =>
      ImageToo.file(
        this,
        width: width,
        height: height,
        scale: scale,
        repeat: Repeat.mirrorY,
        mirrorOffset: offset,
        color: color,
        colorBlendMode: blendMode,
        filterQuality: quality,
        isAntiAlias: isAntiAlias,
      );
}

/// Provides [toSeamlessTexture] that considers `this Uin8List` as bytes that
/// describe an image and returns an [ImageToo] widget.
///
/// The `repeat` property on this returned widget is set to [Repeat.mirror]
/// which has the effect of creating a seamless, edge-to-edge texture from
/// any image that will fill the space of the widget.
///
/// - For a horizontally-tiling texture using [Repeat.mirrorX],
///   see [toSeamlessRow].
/// - For a vertically-tiling texture using [Repeat.mirrorY],
///   see [toSeamlessColumn].
extension BytesToTexture on Uint8List {
  /// A method that considers `this Uint8List` as bytes that describe an image
  /// and returns an [ImageToo] widget.
  ///
  /// The `repeat` property on this returned widget is set to [Repeat.mirror]
  /// which has the effect of creating a seamless, edge-to-edge texture from
  /// any image that will fill the space of the widget.
  ///
  /// Some images fare better than others as far as the quality of the output.
  /// Most will appear kaleidoscopic at worst and magical at best.
  ///
  /// Still, condiering how *few* images out there are designed to support
  /// edge-to-edge tiling with a simple [Repeat.repeat] mode, this functionality
  /// broadly expands the versatility of using any image as a texture.
  ///
  /// - `color` is mixed with the image using `blendMode`.
  /// - Larger `scale` values render the image smaller.
  /// - Max x and y components for `offset` are equal to the resolution of the
  /// image and act to shift the texture's edges/translation.
  ///   - See [ImageToo.mirrorOffset].
  ImageToo toSeamlessTexture({
    double? width,
    double? height,
    double scale = 1.0,
    Offset offset = Offset.zero,
    Color? color,
    BlendMode? blendMode,
    FilterQuality quality = FilterQuality.low,
    bool isAntiAlias = false,
    AssetBundle? bundle,
    String? package,
  }) =>
      ImageToo.memory(
        this,
        width: width,
        height: height,
        scale: scale,
        repeat: Repeat.mirror,
        mirrorOffset: offset,
        color: color,
        colorBlendMode: blendMode,
        filterQuality: quality,
        isAntiAlias: isAntiAlias,
      );

  /// A method that considers `this Uint8List` as bytes that describe an image
  /// and returns an [ImageToo] widget.
  ///
  /// The `repeat` property on this returned widget is set to [Repeat.mirrorX]
  /// which has the effect of creating a seamless, edge-to-edge horizontal
  /// texture from any image that will fill the space of the widget.
  ///
  /// Some images fare better than others as far as the quality of the output.
  /// Most will appear kaleidoscopic at worst and magical at best.
  ///
  /// Still, condiering how *few* images out there are designed to support
  /// edge-to-edge tiling with a simple [Repeat.repeat] mode, this functionality
  /// broadly expands the versatility of using any image as a texture.
  ///
  /// - `color` is mixed with the image using `blendMode`.
  /// - Larger `scale` values render the image smaller.
  /// - Max x and y components for `offset` are equal to the resolution of the
  /// image and act to shift the texture's edges/translation.
  ///   - See [ImageToo.mirrorOffset].
  ImageToo toSeamlessRow({
    double? width,
    double? height,
    double scale = 1.0,
    Offset offset = Offset.zero,
    Color? color,
    BlendMode? blendMode,
    FilterQuality quality = FilterQuality.low,
    bool isAntiAlias = false,
    bool isAsset = false,
    AssetBundle? bundle,
    String? package,
  }) =>
      ImageToo.memory(
        this,
        width: width,
        height: height,
        scale: scale,
        repeat: Repeat.mirrorX,
        mirrorOffset: offset,
        color: color,
        colorBlendMode: blendMode,
        filterQuality: quality,
        isAntiAlias: isAntiAlias,
      );

  /// A method that considers `this Uint8List` as bytes that describe an image
  /// and returns an [ImageToo] widget.
  ///
  /// The `repeat` property on this returned widget is set to [Repeat.mirrorY]
  /// which has the effect of creating a seamless, edge-to-edge vertical
  /// texture from any image that will fill the space of the widget.
  ///
  /// Some images fare better than others as far as the quality of the output.
  /// Most will appear kaleidoscopic at worst and magical at best.
  ///
  /// Still, condiering how *few* images out there are designed to support
  /// edge-to-edge tiling with a simple [Repeat.repeat] mode, this functionality
  /// broadly expands the versatility of using any image as a texture.
  ///
  /// - `color` is mixed with the image using `blendMode`.
  /// - Larger `scale` values render the image smaller.
  /// - Max x and y components for `offset` are equal to the resolution of the
  /// image and act to shift the texture's edges/translation.
  ///   - See [ImageToo.mirrorOffset].
  ImageToo toSeamlessColumn({
    double? width,
    double? height,
    double scale = 1.0,
    Offset offset = Offset.zero,
    Color? color,
    BlendMode? blendMode,
    FilterQuality quality = FilterQuality.low,
    bool isAntiAlias = false,
    bool isAsset = false,
    AssetBundle? bundle,
    String? package,
  }) =>
      ImageToo.memory(
        this,
        width: width,
        height: height,
        scale: scale,
        repeat: Repeat.mirrorY,
        mirrorOffset: offset,
        color: color,
        colorBlendMode: blendMode,
        filterQuality: quality,
        isAntiAlias: isAntiAlias,
      );
}
