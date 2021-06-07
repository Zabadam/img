/// | [![animation demonstrating the example app](https://raw.githubusercontent.com/Zabadam/img/main/doc/example_small.gif)](https://pub.dev/packages/img/example 'animation demonstrating the example app') | Easily paint mirror-tiling images for seamless edge-to-edge textures from any source. |
/// |:-:|:-:|
///
/// Defines [Repeat], an expansion on [ImageRepeat] that enables mirroring, \
/// as well as the Widgets, extensions, and methods to support it.
///
/// A `Repeat` provides value over an `ImageRepeat` as it defines three \
/// additional tiling methods that invlove mirroring alternating tiles to \
/// create a seamless edge-to-edge texture from a single image.
///
/// ## [pub.dev Listing](https://pub.dev/packages/img) | [API Doc](https://pub.dev/documentation/img/latest) | [GitHub](https://github.com/Zabadam/img)
/// #### API References: [`Repeat`](https://pub.dev/documentation/img/latest/img/Repeat-class.html) | [`ImageToo`](https://pub.dev/documentation/img/latest/img/ImageToo-class.html) | [`ImageDecorationToo`](https://pub.dev/documentation/img/latest/img/ImageDecorationToo-class.html) | [`paintImageToo()`](https://pub.dev/documentation/img/latest/img/paintImageToo.html) | [`InkImg`](https://pub.dev/documentation/img/latest/img/InkImg-class.html)
///
/// Provides the [ImageToo] stateless widget and several named constructors \
/// for easily rendering images from a variety of sources.
///
/// Also available is the [DecorationImageToo] class for displaying an image as \
/// a `Decoration` instead of as a `Widget`.
///
/// ### Shorthands: [Img], [DecorationImg]
///
/// An [InkImg] will create an [Ink.image]-like decoration for a [Material] \
/// that is capable of using the new [Repeat] modes and also renders \
/// ink splashes over top of itself.
///
/// Finally, consider the `String` to seamless texture methods in
/// [StringToTexture]. Also:
/// - [FileToTexture]
/// - [BytesToTexture]
///
/// ---
/// Along with `ImageToo`, a new [RawImageToo] and [RenderImageToo] had
/// to be provided.
/// - These are the Dart-abstracting [LeafRenderObjectWidget] and [RenderBox]
///   classes respectively.
///
/// `DecorationImageToo` necessitated the [DecorationImagePainterToo] class.
///
/// These exist because `RenderImageToo` and `DecorationImagePainterToo` needed \
/// to be forked from their vanilla Flutter counterparts in order to accommodate \
/// a modified [paintImage] method called, predictably, [paintImageToo] that \
/// handles the new [Repeat] values.
//
//  Consider LICENSE file, as some code comes from the Flutter source itself.
library img;

// For links here in doc.
// Hover for more info.
import 'package:flutter/material.dart';
import 'package:img/src/utils.dart';
import 'src/models/decoration.dart';
import 'src/models/repeat.dart';
import 'src/painting.dart';
import 'src/rendering.dart';
import 'src/widgets/image_too.dart';
import 'src/wrappers.dart';

export 'src/models/decoration.dart'; // "DecorationImage" class
export 'src/models/repeat.dart'; // "ImageRepeat" enum
export 'src/painting.dart'; // "paintImage" method
export 'src/utils.dart'; // Extensions that generate seamless textures
export 'src/widgets/image_too.dart'; // "Image" widget
export 'src/wrappers.dart'; // "Ink.image" widget
