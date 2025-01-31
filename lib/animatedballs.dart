import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedBallsContainer extends StatefulWidget {
  const AnimatedBallsContainer({super.key});

  @override
  State createState() => _AnimatedBallsContainerState();
}

class _AnimatedBallsContainerState extends State<AnimatedBallsContainer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _ballAnimations;
  late Random _random;

  @override
  void initState() {
    super.initState();
    _random = Random();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Repeat the animation infinitely

    _ballAnimations = List.generate(3, (index) {
      // Create a random path for each ball to follow
      return Tween<Offset>(
        begin: Offset(_random.nextDouble() * 400, _random.nextDouble() * 400), // Random starting position
        end: Offset(_random.nextDouble() * 400, _random.nextDouble() * 400),   // Random end position
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      color: Colors.blue,
      child: Stack(
        children: [
          // Ball 1
          AnimatedBuilder(
            animation: _ballAnimations[0],
            builder: (context, child) {
              return Positioned(
                left: _ballAnimations[0].value.dx,
                top: _ballAnimations[0].value.dy,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          // Ball 2
          AnimatedBuilder(
            animation: _ballAnimations[1],
            builder: (context, child) {
              return Positioned(
                left: _ballAnimations[1].value.dx,
                top: _ballAnimations[1].value.dy,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          // Ball 3
          AnimatedBuilder(
            animation: _ballAnimations[2],
            builder: (context, child) {
              return Positioned(
                left: _ballAnimations[2].value.dx,
                top: _ballAnimations[2].value.dy,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          // Text in the center
          Center(
            child: Text(
              'Capture this screen!',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ],
      ),
    ));
  }
}