import 'package:flutter/material.dart';

class ShareProfileItem {
  final String imageUrl;
  final String name;
  final IconData? icon;
  final Color? bgColor;
  final Color? iconColor;

  ShareProfileItem({
    required this.imageUrl,
    required this.name,
    this.icon,
    this.bgColor,
    this.iconColor,
  });
}