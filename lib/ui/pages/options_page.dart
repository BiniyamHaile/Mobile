import 'package:flutter/material.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/string_extension.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 110),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.person, size: 18),
                      ),
                      const SizedBox(width: 6),
                      const Text('flutter_developer02'),
                      const SizedBox(width: 10),
                      const Icon(Icons.verified, size: 15),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          AppStrings.follow.tr(context),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Text('Flutter is beautiful and fast 💙❤💛 ..'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.music_note,
                        size: 15,
                      ),
                      Text('${AppStrings.originalAudio.tr(context)} - ${AppStrings.musicTrack.tr(context)}'),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.favorite_outline),
                  Text(AppStrings.likes.tr(context)),
                  const SizedBox(height: 20),
                  const Icon(Icons.comment_rounded),
                  Text(AppStrings.comments.tr(context)),
                  const SizedBox(height: 20),
                  Transform(
                    transform: Matrix4.rotationZ(5.8),
                    child: Icon(Icons.send),
                  ),
                  Text(AppStrings.share.tr(context)),
                  const SizedBox(height: 50),
                  const Icon(Icons.more_vert),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}