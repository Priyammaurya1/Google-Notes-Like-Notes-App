import 'package:flutter/material.dart';

class CustomNoteRoute extends PageRouteBuilder {
  final Widget child;
  final Offset startPosition;

  CustomNoteRoute({required this.child, required this.startPosition})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          final tween = Tween(begin: begin, end: end);
          final fadeAnimation = animation.drive(tween);

          return Stack(
            children: [FadeTransition(opacity: fadeAnimation, child: child)],
          );
        },
      );
}
