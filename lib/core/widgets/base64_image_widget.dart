import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64ImageWidget extends StatelessWidget {
  final String? base64String;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const Base64ImageWidget({
    super.key,
    required this.base64String,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (base64String == null || base64String!.isEmpty) {
      return placeholder ?? _defaultPlaceholder();
    }

    try {
      // Extract base64 data from data URL if present
      String base64Data = base64String!;
      if (base64Data.startsWith('data:image')) {
        final commaIndex = base64Data.indexOf(',');
        if (commaIndex != -1) {
          base64Data = base64Data.substring(commaIndex + 1);
        }
      }

      final Uint8List bytes = base64Decode(base64Data);
      
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _defaultErrorWidget();
        },
      );
    } catch (e) {
      return errorWidget ?? _defaultErrorWidget();
    }
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width ?? 100,
      height: height ?? 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image,
        color: Colors.grey,
        size: 40,
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width ?? 100,
      height: height ?? 100,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.error,
        color: Colors.red,
        size: 40,
      ),
    );
  }
}
