import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';

List<Widget> designs = [
  Positioned(
    bottom: -80.0,
    left: -80.0,
    child: Blob.random(
      size: 200,
      styles: BlobStyles(
        color: const Color(0xff87B28A),
        fillType: BlobFillType.fill,
        strokeWidth: 3,
      ),
    ),
  ),
  Positioned(
    bottom: -60.0,
    left: -60.0,
    child: Blob.random(
      size: 200,
      styles: BlobStyles(
        color: const Color(0xff87B28A),
        fillType: BlobFillType.stroke,
        strokeWidth: 3,
      ),
    ),
  ),
  Positioned(
    top: -80.0,
    right: -80.0,
    child: Blob.random(
      size: 200,
      styles: BlobStyles(
        color: const Color(0xff86778E),
        fillType: BlobFillType.fill,
        strokeWidth: 3,
      ),
    ),
  ),
  Positioned(
    top: -60.0,
    right: -60.0,
    child: Blob.random(
      size: 200,
      styles: BlobStyles(
        color: const Color(0xff86778E),
        fillType: BlobFillType.stroke,
        strokeWidth: 3,
      ),
    ),
  ),
];
