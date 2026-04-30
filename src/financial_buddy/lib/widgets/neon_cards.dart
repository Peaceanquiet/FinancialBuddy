import 'package:flutter/material.dart';
import 'package:financial_buddy/theme/app_theme.dart';

// Reusable neon/glow card used across the app.
// This lets us build the "bubble box" style once, then reuse it on Accounts, Goals, Transactions, etc.
class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double borderRadius;

  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.backgroundColor,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.cardGradient, // needed to add gradients in app_theme.dart
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
