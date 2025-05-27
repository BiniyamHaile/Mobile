import 'package:flutter/material.dart';

class LikeIcon extends StatelessWidget {
  const LikeIcon({super.key});

  Future<int> tempFuture() async {
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: tempFuture(),
        builder: (context, snapshot) =>
            snapshot.connectionState != ConnectionState.done
                ? const Icon(Icons.favorite, size: 110)
                : const SizedBox(),
      ),
    );
  }
}