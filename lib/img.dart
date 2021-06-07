/// Defines the enum [Repeat], an expansion on the concept of [ImageRepeat].
///
/// A `Repeat` provides value over an `ImageRepeat` as it defines three
/// additional tiling methods that invlove mirroring alternating tiles to
/// create a seamless edge-to-edge texture from a single image.
///
/// Provides the [ImageToo] stateless widget and several named constructors
/// for easily rendering images from a variety of sources.
///
/// Also available is the [DecorationImageToo] class for displaying an image as
/// a `Decoration` instead of as a `Widget`.
///
/// Finally, an [InkImg] will create an [Ink.image]-like decoration for a
/// [Material] that is capable of using the new [Repeat] modes and also
/// renders ink splashes over top of itself.
///
/// - Along with `ImageToo`, a new [RawImageToo] and [RenderImageToo] had
///   to be provided.
///   - These are the Dart-abstracting [LeafRenderObjectWidget] and [RenderBox]
///     classes respectively.
/// - `DecorationImageToo` necessitated the [DecorationImagePainterToo] class
///
/// This is because `RenderImageToo` and `DecorationImagePainterToo` needed
/// to be forked from their vanilla Flutter counterparts in order to accommodate
/// a modified [paintImage] method called, predictably, [paintImageToo] that
/// handles the new [Repeat] values.
///
/// [![animation demonstrating the example app](https://raw.githubusercontent.com/Zabadam/img/main/doc/example_small.gif)](https://pub.dev/packages/img/example 'animation demonstrating the example app')
library img;

// For links here in doc.
// Hover for more info.
import 'package:flutter/material.dart';
import 'src/models/decoration.dart';
import 'src/models/repeat.dart';
import 'src/painting.dart';
import 'src/rendering.dart';
import 'src/widgets/image_too.dart';
import 'src/wrappers.dart';

export 'src/models/decoration.dart'; // "DecorationImage" class
export 'src/models/repeat.dart'; // "ImageRepeat" enum
export 'src/painting.dart'; // "paintImage" method
export 'src/utils.dart'; // Class extensions
export 'src/widgets/image_too.dart'; // "Image" widget
export 'src/wrappers.dart'; // "Ink.image" widget
