import 'package:image/image.dart' as img;
import 'dart:io' as io;

main(List<String> arguments) {
  print("Hello World and welcome to depth_blur_algo experience!");
  img.Image image1, image2, depth, mainImage, background, resultImage;
  mainImage =
      (img.decodeImage(io.File(arguments[0] + "/main.jpg").readAsBytesSync()));
  image1 =
      (img.decodeImage(io.File(arguments[0] + "/1.jpg").readAsBytesSync()));
  image2 =
      (img.decodeImage(io.File(arguments[0] + "/2.jpg").readAsBytesSync()));
  mainImage = img.copyRotate(img.decodePng(img.encodePng(mainImage)), 90);
  depth = img.copyRotate(img.decodePng(img.encodePng(mainImage)), 0);
  image1 = img.copyRotate(img.decodePng(img.encodePng(image1)), 90);
  image2 = img.copyRotate(img.decodePng(img.encodePng(image2)), 90);
  resultImage = img.copyRotate(img.decodePng(img.encodePng(mainImage)), 0);
  background = img.copyRotate(img.decodePng(img.encodePng(mainImage)), 0);
  img.gaussianBlur(background, 20);
  img.adjustColor(img.grayscale(image1), gamma: 15);
  img.adjustColor(img.grayscale(image2), gamma: 15);
  for (var x = 0; x < resultImage.width; x++) {
    for (var y = 0; y < resultImage.height; y++) {
      if (image1.getPixel(x, y) != image2.getPixel(x, y)) {
        depth.setPixel(x, y, 0);
      } else {
        depth.setPixel(x, y, 4294967295);
      }
    }
  }

  for (var y = 0; y < depth.height - 2; y++) {
    for (var x = 0; x < depth.width - 2; x++) {
      var avgPixel = ((depth.getPixel(x, y) +
                  depth.getPixel(x, y + 1) +
                  depth.getPixel(x, y + 2) +
                  depth.getPixel(x + 1, y) +
                  depth.getPixel(x + 1, y + 1) +
                  depth.getPixel(x + 1, y + 2) +
                  depth.getPixel(x + 2, y) +
                  depth.getPixel(x + 2, y + 1) +
                  depth.getPixel(x + 2, y + 2)) /
              9)
          .floor();
      depth.setPixel(x, y, avgPixel);
      depth.setPixel(x, y + 1, avgPixel);
      depth.setPixel(x, y + 2, avgPixel);
      depth.setPixel(x + 1, y, avgPixel);
      depth.setPixel(x + 1, y + 1, avgPixel);
      depth.setPixel(x + 1, y + 2, avgPixel);
      depth.setPixel(x + 2, y, avgPixel);
      depth.setPixel(x + 2, y + 1, avgPixel);
      depth.setPixel(x + 2, y + 2, avgPixel);
      x += 2;
    }
  }

  //depth = img.pixelate(depth, 3,mode: img.PixelateMode.average);

  for (var x = 0; x < resultImage.width; x++) {
    for (var y = 0; y < resultImage.height; y++) {
      if ((depth.getPixel(x, y) >= 4294967295) ||
          (depth.getPixel(x, y) <= 4294967285)) {
        resultImage.setPixel(x, y, background.getPixel(x, y));
        depth.setPixel(x, y, 4294967295);
      } else {
        depth.setPixel(x, y, 0);
      }
    }
  }
  io.File outputDepth = io.File(arguments[0] + '/result/rawdepth.png');
  outputDepth.writeAsBytesSync(img.encodeJpg(depth));
  io.File outputMain = io.File(arguments[0] + '/result/color_image.png');
  outputMain.writeAsBytesSync(img.encodeJpg(mainImage));
  io.File outputResult = io.File(arguments[0] + '/result/result.png');
  outputResult.writeAsBytesSync(img.encodeJpg(resultImage));
  io.File outputBackground = io.File(arguments[0] + '/result/background.png');
  outputBackground.writeAsBytesSync(img.encodeJpg(background));

  print("DONE!");
}
