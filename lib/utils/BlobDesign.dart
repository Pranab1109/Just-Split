import 'package:flutter/material.dart';
import 'package:just_split/utils/Cooloors.dart';

// Lightweight decorative elements that replace expensive Blob rendering
final List<Widget> designs = [
  Positioned(
    bottom: -60.0,
    left: -60.0,
    child: Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Cooloors.success.withOpacity(0.4),
            Cooloors.success.withOpacity(0.0),
          ],
        ),
      ),
    ),
  ),
  Positioned(
    bottom: -40.0,
    left: -40.0,
    child: Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Cooloors.success.withOpacity(0.25),
          width: 2,
        ),
      ),
    ),
  ),
  Positioned(
    top: -60.0,
    right: -60.0,
    child: Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Cooloors.primary.withOpacity(0.4),
            Cooloors.primary.withOpacity(0.0),
          ],
        ),
      ),
    ),
  ),
  Positioned(
    top: -40.0,
    right: -40.0,
    child: Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Cooloors.primary.withOpacity(0.25),
          width: 2,
        ),
      ),
    ),
  ),
];
