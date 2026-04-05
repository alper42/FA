import 'package:flutter/material.dart';
import '../models/transit_models.dart';

class LineBadge extends StatelessWidget {
  final TransitLine line;
  final double size;

  const LineBadge({super.key, required this.line, this.size = 28});

  String get _prefix {
    switch (line.type) {
      case LineType.sbahn: return 'S';
      case LineType.ubahn: return 'U';
      case LineType.tram: return '';
      case LineType.bus: return '';
      case LineType.regional: return 'R';
    }
  }

  BorderRadius get _radius {
    switch (line.type) {
      case LineType.sbahn: return BorderRadius.circular(size / 2);
      case LineType.ubahn: return BorderRadius.circular(6);
      case LineType.tram: return BorderRadius.circular(4);
      case LineType.bus: return BorderRadius.circular(4);
      case LineType.regional: return BorderRadius.circular(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _prefix + line.name;
    final isCircle = line.type == LineType.sbahn;

    return Container(
      height: size,
      width: isCircle ? size : null,
      padding: isCircle ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: line.color,
        borderRadius: _radius,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
