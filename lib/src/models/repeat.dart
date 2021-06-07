/// Defines the `Repeat` enum, an expansion on the concept of [ImageRepeat]
/// offering three additional "mirror" modes.
library img;

import 'package:flutter/painting.dart' show ImageRepeat;

/// How to paint any portions of a box not covered by an image.
///
/// An expansion on the concept of [ImageRepeat], this enum defines three
/// additional values whereby an image may be repeated by mirroring every other
/// image tile to create a seamless texture from any image.
enum Repeat {
  /// Leave uncovered portions of the box transparent.
  noRepeat,

  /// Repeat the image in both the x and y directions until the box is filled.
  repeat,

  /// Repeat the image in the x direction until the box is filled horizontally.
  repeatX,

  /// Repeat the image in the y direction until the box is filled vertically.
  repeatY,

  /// Mirror the image in both the x and y directions, alternating with every
  /// drawn image tile, until the box is filled.
  ///
  /// This will render a seamlessly-tiling image, which may have noticeable
  /// "kaleidoscopic" edges depending on the provided image.
  ///
  /// According to the situation, this may be desirable over the standard hard
  /// edge of a non-mirroring [repeat]ed image.
  mirror,

  /// Mirror the image in the x direction, alternating with every drawn image
  /// tile, until the box is filled horizontally.
  mirrorX,

  /// Mirror the image in the y direction, alternating with every drawn image
  /// tile until the box is filled vertically.
  mirrorY,
}
