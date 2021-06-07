import 'package:flutter/material.dart';

import 'package:img/img.dart';

void main() => runApp(const ExampleFrame());

/// [MaterialApp] frame.
class ExampleFrame extends StatelessWidget {
  /// [MaterialApp] frame.
  const ExampleFrame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Example(),
      );
}

/// Construct a [new Example] `Widget` to fill an [ExampleFrame].
class Example extends StatelessWidget {
  /// Fill an [ExampleFrame] with a [Scaffold] and [AppBar] whose body is a
  /// [PageView]. The `children` of this swiping page view are each built by
  /// [buildView], save for an example that is recreated from a README sample
  /// and another example demonstrating [StringToTexture].
  const Example({Key? key}) : super(key: key);

  /// One entire page for a [PageView]. Comprised of a [SingleChildScrollView]
  /// and a [Column], it presents a series of [Text] and [Img].
  Widget buildView({
    required Repeat repeat,
    required double w,
    required double h,
    required String url,
    required double scale1,
    required double scale2,
    required String mode,
    required String subtitle,
  }) =>
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            ImageToo(image: NetworkImage(url, scale: scale1)),
            const SizedBox(height: 25),
            Text(
              'Repeat.$mode',
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            Center(
              /// Equivalent to [ImageToo]
              child: Img(
                image: NetworkImage(url, scale: scale2),
                repeat: repeat,
                width: w,
                height: h,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    final w = s.width;
    final h = s.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('img')),
      body: PageView(
        physics: const BouncingScrollPhysics(),
        children: [
          buildView(
            repeat: Repeat.noRepeat,
            w: w,
            h: h,
            url: window,
            scale1: 3,
            scale2: 1,
            mode: 'noRepeat',
            subtitle: '',
          ),
          buildView(
            repeat: Repeat.repeatX,
            w: w,
            h: h,
            url: fire,
            scale1: 3,
            scale2: 1,
            mode: 'repeatX',
            subtitle: 'Works great because this image naturally tiles',
          ),
          buildView(
            repeat: Repeat.repeat,
            w: w,
            h: h,
            url: fire,
            scale1: 3,
            scale2: 2,
            mode: 'repeat',
            subtitle: 'but uh oh... what if we need fire everywhere?',
          ),
          buildView(
            repeat: Repeat.mirror,
            w: w,
            h: h,
            url: fire,
            scale1: 3,
            scale2: 4,
            mode: 'mirror',
            subtitle: 'Now that\'s strange, but a little better!',
          ),
          buildView(
            repeat: Repeat.mirror,
            w: w,
            h: h,
            url: glitter,
            scale1: 3,
            scale2: 6,
            mode: 'mirror',
            subtitle: 'Turn any image into a seamless texture.',
          ),
          buildView(
            repeat: Repeat.mirror,
            w: w,
            h: h,
            url: frog,
            scale1: 3,
            scale2: 2,
            mode: 'mirror',
            subtitle: 'Or create a kalediscopic dreamworld!',
          ),

          /// Sample from README, adjusted
          Center(
            child: Container(
              width: w * 2 / 3,
              height: h * 2 / 3,
              decoration: const BoxDecoration(
                color: Colors.amber,
                image: DecorationImageToo(
                  image: NetworkImage(fire, scale: 14),
                  repeatMode: Repeat.mirror,
                ),
              ),
              child: const Center(
                child: Text(
                  'THE\nFLOOR\nIS\nLAVA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 75,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          /// Extension methods
          tatsu.toSeamlessTexture(),
          tatsu.toSeamlessTexture(scale: 10),
          InteractiveViewer(
            maxScale: 150,
            child: tatsu.toSeamlessTexture(scale: 75),
          ),

          const LovelyRainyDay(),
        ],
      ),
    );
  }
}

/// Construct a [Stack] of mirror-tiling images formed by
/// `String.toSeamlessTexture` method with a [new LovelyRainyDay].
class LovelyRainyDay extends StatelessWidget {
  /// A [Stack] of mirror-tiling images formed by
  /// `String.toSeamlessTexture` method.
  ///
  /// Draws a scene of a lovely spring day with clouds, hills, a pond,
  /// and some rain.
  const LovelyRainyDay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: clouds.toSeamlessTexture(scale: 2, height: 300)),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            child: field.toSeamlessRow(height: 300),
          ),
        ),
        for (var hill in hillLayers) hill,
        for (var shower in rainLayers) shower,
      ],
    );
  }
}

/// A group of [Positioned] images that are formed into mirroring textures
/// from simple `String`s.
final hillLayers = [
  Positioned(
    bottom: 300,
    left: 0,
    right: 0,
    child: hills.toSeamlessRow(
      height: 190,
      color: Colors.blueGrey[900]!.withOpacity(0.75),
      blendMode: BlendMode.srcATop,
    ),
  ),
  Positioned(
    bottom: 235,
    left: 0,
    right: 0,
    child: hills.toSeamlessRow(
      height: 190,
      color: Colors.black.withOpacity(0.35),
      blendMode: BlendMode.srcATop,
    ),
  ),
  Positioned(
    bottom: 180,
    left: 0,
    right: 0,
    child: hills.toSeamlessRow(
      height: 100,
      color: Colors.blueGrey[800]!.withOpacity(0.4),
      blendMode: BlendMode.srcATop,
    ),
  ),
  Positioned(
    bottom: 145,
    left: 0,
    right: 0,
    child: hills.toSeamlessRow(height: 50, offset: const Offset(20, 0)),
  ),
];

/// A group of [Positioned] images that are formed into mirroring textures
/// from simple `String`s.
final rainLayers = [
  Positioned(
    left: -450,
    top: 0,
    right: 0,
    bottom: 0,
    child: rain.toSeamlessColumn(scale: 2),
  ),
  Positioned(
    left: -400,
    top: 0,
    right: 0,
    bottom: 0,
    child: rain.toSeamlessColumn(scale: 3),
  ),
  Positioned(
    left: -225,
    top: 0,
    right: 0,
    bottom: 0,
    child: rain.toSeamlessColumn(scale: 5),
  ),
];

/// URL leading to an animated image of a window with a moon and tain.
const window = 'https://www.gifstop.com/images/weathergifs/raingif.gif';

/// URL leading to an animated image of fire.
const fire = 'https://gifimage.net/wp-content/uploads/2017/08/'
    'transparent-fire-gif-22.gif';

/// URL leading to an animated image colored glitter.
const glitter = 'https://i.giphy.com/media/R2B4OcBpN7YS4/giphy.gif';

/// URL leading to an animated image of a frog floating in water.
const frog = 'https://www.gifmania.it/Gif-Animate-Animali/'
    'Immagini-Animate-Rane/Gif-Animati-Immagini-Di-Rane/'
    'Immagini-Di-Rane-66777.gif';

/// URL leading to a Tatsuro Yamashita album cover.
const tatsu = 'https://spice.eplus.jp/images/'
    'KefMrp9J1bM7NGRvFqK64ZNOfbTGUDKVCC8ePaiKB1cOcOJz1rEN3DQUJMBZhQJ2.jpg';

/// URL leading to an image of clouds.
const clouds = 'https://i.pinimg.com/736x/9e/03/4d/'
    '9e034dec913971c7750e4836dc1f479b.jpg';

/// URL leading to an image of a field.
const field =
    'https://static.vecteezy.com/system/resources/previews/000/519/977/original/open-field-vector.jpg';

/// URL leading to an image of hills.
const hills = 'http://clipart-library.com/img1/1255972.png';

/// URL leading to an animated image of rain.
const rain = 'https://i.giphy.com/media/495IrnWutQBc4hhhoL/giphy.gif';
