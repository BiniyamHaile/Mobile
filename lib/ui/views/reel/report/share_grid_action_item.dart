import 'package:flutter/material.dart';

class ShareGridActionItem {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  ShareGridActionItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    this.iconColor = Colors.white,
    required this.onTap,
  });
}