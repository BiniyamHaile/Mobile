import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/ui/pages/contents_page.dart';

class ReelsPage extends StatelessWidget {
  final List<String> videos = [
    'https://filesamples.com/samples/video/mp4/sample_640x360.mp4',
    'https://filesamples.com/samples/video/mp4/sample_1280x720.mp4',
    'https://filesamples.com/samples/video/mp4/sample_640x360.mp4',
    'https://filesamples.com/samples/video/mp4/sample_1280x720.mp4',
        'https://filesamples.com/samples/video/mp4/sample_640x360.mp4',
    'https://filesamples.com/samples/video/mp4/sample_1280x720.mp4',
        'https://filesamples.com/samples/video/mp4/sample_640x360.mp4',
    'https://filesamples.com/samples/video/mp4/sample_1280x720.mp4',
  ];
  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: EdgeInsets.only(top: 50),
          child: Stack(
            children: [
              //We need swiper for every content
              Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return ContentScreen(
                    src: videos[index],
                  );
                },
                itemCount: videos.length,
                scrollDirection: Axis.vertical,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Flutter Shorts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.camera_alt),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}