# img
## [pub.dev Listing](https://pub.dev/packages/img) | [API Doc](https://pub.dev/documentation/img/latest) | [GitHub](https://github.com/Zabadam/img)
#### API References: [`Repeat`](https://pub.dev/documentation/img/latest/img/Repeat-class.html) | [`ImageToo`](https://pub.dev/documentation/img/latest/img/ImageToo-class.html) | [`ImageDecorationToo`](https://pub.dev/documentation/img/latest/img/ImageDecorationToo-class.html) | [`paintImageToo()`](https://pub.dev/documentation/img/latest/img/paintImageToo.html) | [`InkImg`](https://pub.dev/documentation/img/latest/img/InkImg-class.html)

## 🙋‍♂️ I'm an `Image` Too!
Easily render mirror-tiling images for seamless edge-to-edge textures from
any source. Defines Repeat, an expansion on ImageRepeat that supports
mirroring, as well as the Widgets, extensions, and methods to support it.

An `ImageToo` or `DecorationImageToo` is used to render images from the
expected array of sources, but their `repeat` property is expanded.

The secret sauce is the [`Repeat`](https://pub.dev/documentation/img/latest/img/Repeat-class.html)
enum with the standard options from `ImageRepeat`, such as `noRepeat` and
`repeatX`, as well as bespoke `mirror` values, spanning `mirrorX`, `mirrorY`,
and global `mirror`.

[![animation demonstrating the example app](https://raw.githubusercontent.com/Zabadam/img/main/doc/example.gif)](https://pub.dev/packages/img/example 'animation demonstrating the example app')

This package forks several of Flutter's vanilla classes and `Widget`s,
rigging them to drive an alternate paint method that is the real meat and
potatoes of 🙋‍♂️ [`img`](https://pub.dev/packages/img).

Predictably named `paintImageToo()`, this method performs mostly the same as
the built-in `paintImage()` method, but it does make a few considerations for
the repeat styles.
 
Some images fare better than others as far as the quality of the output.
Most will appear kaleidoscopic at worst and magical at best.
 
Still, condiering how *few* images out there are designed to support
edge-to-edge tiling with a simple `ImageRepeat.repeat` mode, this functionality
broadly expands the versatility of using any image as a seamless texture.

## Getting Started
To place an image directly into an application *as a `Widget`*, employ a 
`new ImageToo(. . .)`.

```dart
void main() => runApp(const Example0());

class Example extends StatelessWidget {
  const Example({Key? key}): super(key: key);
  
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ImageToo(
            image: NetworkImage(
              'https://gifimage.net/wp-content/uploads/2017/08/transparent-fire-gif-22.gif',
              scale: 1,
            ),
            repeat: Repeat.mirror,
            width: 600,
            height: 600,
          ),
        ),
      ),
    );
  }
}
```

|                                                               Sample code output                                                               |                                                      Original image (1x tile)                                                       |
| :--------------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------: |
| ![Sample code output](https://raw.githubusercontent.com/Zabadam/img/main/doc/readme_sample0.gif 'Sample code output, `repeat: Repeat.mirror`') | ![Original image (1x tile)](https://gifimage.net/wp-content/uploads/2017/08/transparent-fire-gif-22.gif 'Original image (1x tile)') |

This shiny new `Repeat` with its mirror values can also be used to decorate a
`Container` or anywhere else `DecorationImage` might typically be placed.

Just swap out your vanilla `DecorationImage` object with a `DecorationImageToo`
object, replacing the `ImageRepeat repeat` property with a `Repeat repeatMode`.


```dart
void main() => runApp(const FloorIsLava());

class FloorIsLava extends StatelessWidget {
  const FloorIsLava({Key? key}) : super(key: key);

  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: ExampleBody(),
        ),
      );
}

class ExampleBody extends StatelessWidget {
  const ExampleBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.amber,
          image: DecorationImageToo(
            image: NetworkImage(
              'https://gifimage.net/wp-content/uploads/2017/08/transparent-fire-gif-22.gif',
              scale: 14,
            ),
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
    );
  }
}
```

| Sample code output                                                                                                                             | Original image (1x tile)                                                                                                            |
| :--------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
| ![Sample code output](https://raw.githubusercontent.com/Zabadam/img/main/doc/readme_sample1.gif 'Sample code output, `repeat: Repeat.mirror`') | ![Original image (1x tile)](https://gifimage.net/wp-content/uploads/2017/08/transparent-fire-gif-22.gif 'Original image (1x tile)') |

## Advanced Usage

### Extension Methods
```dart
/// URL leading to a Tatsuro Yamashita album cover.
const tatsu = 'https://spice.eplus.jp/images/KefMrp9J1bM7NGRvFqK64ZNOfbTGUDKVCC8ePaiKB1cOcOJz1rEN3DQUJMBZhQJ2.jpg';

/// Extension methods
final extensionExamples = <Widget>[
  tatsu.toSeamlessTexture(),
  tatsu.toSeamlessTexture(scale: 10),
  InteractiveViewer(
    maxScale: 150,
    child: tatsu.toSeamlessTexture(scale: 75),
  );
];
```

Expect output from these widgets to resemble something like this:
[![This code sample comes from the package example](https://raw.githubusercontent.com/Zabadam/img/main/doc/extensions.gif)](https://pub.dev/packages/img/example 'This code sample comes from the package example')

### 🙋‍♂️ `InkImg`
Extends `Ink` and has the same paramters as `Ink.image`, but creates an ink
decoration with a `DecorationImg` that supports `Repeat`ing (mirroring 😉).

For your consideration is an extension for making a quick textured surface from
a single url as `String.toSeamlessTexture()`.

---

When using any of the new mirror modes as the `repeat` property, the
`paintImageToo` method will override the image's alignment to `Alignment.center`.

This is a workaround at the moment for invalid rendering when alignment is not
centered.

To compensate for now, an `Offset` property is available with values that range
`0..maxResolution` where `maxResolution` is the axis length in pixels of the
image for the corresponding offset component, `dx` or `dy`; but this only
*mimics* "alignment" with a `Repeat.mirror` tiled image that is meant to fill
an entire space.

That is, for an image with the resolution 400✖400, an `ImageToo` or
`DecorationImageToo` may have a tile shift maxing out at `Offset(400,400)`
and defaulting to `Offset.none` applied as its `mirrorOffset` property
when its repeat is set one of the mirror modes.

Stay tuned if you would like to, say, align the image left and also
`Repeat.mirrorY`.

### Deep Dive

In order to dig deep enough to the painting method, several intermediate 
image "too" classes had to be forked. All told, from order of direct
developer relevance:

| <h4>🙋‍♂️ `ImageToo`</h4> | <h5>(`Img`)</h5> |
| :-------------------- | :--------------- |

A stateful widget, either `const` via `ImageProvider` or through a variety of
named convenience constructors, that passes along the new `Repeat` value.
Consider `ImageToo.asset` or `ImageToo.network`, etc.

| <h4>🙋‍♂️ `DecorationImageToo`</h4> | <h5>(`DecorationImg`)</h5> |
| :------------------------------ | :------------------------- |

A `Repeat`-conscious variant of a `Decoration.image`-fulfilling
`DecorationImage`.

| <h4>🙋‍♂️ `RawImageToo`</h4> | <h4>🙋‍♂️ `RenderImageToo`</h4> |
| :----------------------- | :-------------------------- |

Not currently exported with the package. Could be. Should they be? \
Dart abstraction and `LeafRenderObjectWidget` created by an `ImageToo` that
then creates the `RenderBox`.

## 🛣️ Roadmap
1. Fix `alignment` and likely remove `mirrorOffset`.

<br />

---

## 🐸 [Zaba.app ― simple packages, simple names.](https://pub.dev/publishers/zaba.app/packages 'Other Flutter packages published by Zaba.app')

<details>
<summary>More by Zaba</summary>

### Widgets to wrap other widgets
- ## 🕹️ [xl](https://pub.dev/packages/xl 'implement accelerometer-fueled interactions with a layering paradigm')
- ## 🌈 [foil](https://pub.dev/packages/foil 'implement accelerometer-reactive gradients in a cinch')
- ## 📜 [curtains](https://pub.dev/packages/curtains 'provide animated shadow decorations for a scrollable to allude to unrevealed content')
---
### Container widget that wraps many functionalities
- ## 🌟 [surface](https://pub.dev/packages/surface 'animated, morphing container with specs for Shape, Appearance, Filter, Tactility')
---
### Side-kick companions, work great alone or employed above
- ## 🙋‍♂️ [icon](https://pub.dev/packages/icon 'An extended Icon \"Too\" for those that are not actually square, plus shadows support + IconUtils')
- ## 🙋‍♂️ [img](https://pub.dev/packages/img 'An extended Image \"Too\" and DecorationImageToo that support an expanded Repeat.mirror painting mode')
- ## 🏓 [ball](https://pub.dev/packages/ball 'a bouncy, position-mirroring splash factory that\'s totally customizable')
- ## 👥 [shadows](https://pub.dev/packages/shadows 'convert a double-based \`elevation\` + BoxShadow and List\<BoxShadow\> extensions')
</details>
