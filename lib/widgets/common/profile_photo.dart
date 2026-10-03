import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Profile photo from a network URL or a `data:` URL, with a themed
/// placeholder for loading, errors and profiles without photos.
class ProfilePhoto extends StatelessWidget {
  final String? source;
  final String semanticLabel;
  final int cacheWidth;
  final double? width;
  final double? height;

  const ProfilePhoto({
    super.key,
    required this.source,
    required this.semanticLabel,
    this.cacheWidth = 900,
    this.width,
    this.height,
  });

  static final Map<String, Uint8List> _decoded = {};

  /// Decodes once and reuses the same bytes so the image cache hits.
  static Uint8List? _bytesOf(String dataUrl) {
    final cached = _decoded[dataUrl];
    if (cached != null) return cached;
    final comma = dataUrl.indexOf(',');
    if (comma < 0) return null;
    try {
      final bytes = base64Decode(dataUrl.substring(comma + 1));
      if (_decoded.length >= 40) _decoded.remove(_decoded.keys.first);
      return _decoded[dataUrl] = bytes;
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: Icon(Icons.person_outline_rounded, size: AppTheme.iconXl, color: colors.onSurfaceVariant),
        ),
      ),
    );
    final url = source;
    if (url == null) return placeholder;
    if (url.startsWith('data:')) {
      final bytes = _bytesOf(url);
      if (bytes == null) return placeholder;
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        gaplessPlayback: true,
        semanticLabel: semanticLabel,
        errorBuilder: (_, _, _) => placeholder,
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      semanticLabel: semanticLabel,
      loadingBuilder: (_, child, progress) => progress == null ? child : placeholder,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
