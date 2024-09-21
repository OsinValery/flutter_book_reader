import 'package:flutter/material.dart';

class BackgroundView extends StatelessWidget {
  const BackgroundView({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor,
        image: const DecorationImage(
          fit: BoxFit.fill,
          opacity: 0.6,
          image: AssetImage("assets/images/paper.jpeg"),
        ),
      ),
      child: child,
    );
  }
}
