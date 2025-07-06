import 'package:flutter/material.dart';

class QrCustom {
  final bool isSmooth;
  final bool isCircle;
  final Color color;
  final bool hasCenterImage;
  final String centerImagePath;

  const QrCustom({
    this.isSmooth = false,
    this.isCircle = false,
    this.color = Colors.black,
    this.hasCenterImage = false,
    this.centerImagePath = '',
  });
}