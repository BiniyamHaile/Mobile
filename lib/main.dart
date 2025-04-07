import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/ui/routes/app_routes.dart';

void main() => runApp(
  MaterialApp.router(
    routerConfig: AppRoutes.router,
    debugShowCheckedModeBanner: false,
    theme:ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme(),
      ),
  )
);

