import 'package:flutter/material.dart';
import 'package:mobile/common/common.dart';
import 'package:mobile/ui/pages/home_page.dart';
import 'package:mobile/widgets/widgets.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  void splashing(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () async {
        if (context.mounted) context.push(route: HomePage.route());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    splashing(context);

    return const Scaffold(
      body: Center(
        child: AppLogo(),
      ),
    );
  }
}
