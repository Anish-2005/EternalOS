import 'package:flutter/material.dart';

class OverlayOrb extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const OverlayOrb({super.key, this.onTap, this.onLongPress});

  @override
  State<OverlayOrb> createState() => _OverlayOrbState();
}

class _OverlayOrbState extends State<OverlayOrb> {
  Offset position = const Offset(20, 120);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: _orb(),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) => setState(() => position = details.offset),
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: _orb(),
        ),
      ),
    );
  }

  Widget _orb() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
                colors: [Colors.cyan.shade200, Colors.deepPurple.shade700]),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 188, 212, 0.25), blurRadius: 12)
            ]),
        child: Center(child: Icon(Icons.blur_on, color: Colors.white)),
      );
}
