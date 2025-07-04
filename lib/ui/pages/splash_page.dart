import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/widgets/widgets.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  void splashing(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () async {
        if (context.mounted) context.push(RouteNames.feed);
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
