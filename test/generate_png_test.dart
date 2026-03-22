import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  testWidgets('Generate PNG from SVG', (WidgetTester tester) async {
    final key = GlobalKey();

    // Pump a 1024x1024 widget with our SVG scaled up
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: RepaintBoundary(
            key: key,
            child: Container(
              width: 1024,
              height: 1024,
              color: Colors.white,
              child: Center(
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  width: 800,
                  height: 600,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Give it time to render the SVG asset properly...
    await tester.pumpAndSettle();

    // Capture the image
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Write it to disk
    File('assets/logo.png').writeAsBytesSync(pngBytes);
  });
}
