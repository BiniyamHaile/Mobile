import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {

  final String imageUrl;
  final BoxFit? fit;
  const CustomImage({super.key, required this.imageUrl , this.fit});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
     imageUrl: imageUrl,
      fit: fit,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),

    );
  }
}