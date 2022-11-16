import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAnimatedLoading extends StatefulWidget {
  final Offset offsetSpeed;
  final List<MaterialColor> colors;
  final double width;
  final double height;

  const MyAnimatedLoading(
      {Key? key,
      required this.offsetSpeed,
      required this.colors,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  State<MyAnimatedLoading> createState() => _MyAnimatedLoadingState();
}

class _MyAnimatedLoadingState extends State<MyAnimatedLoading> {
  late List<Node> nodes;
  late double width;

  @override
  void initState() {
    super.initState();
    width = widget.width / (widget.colors.length);

    nodes = List.generate(widget.colors.length, (index) {
      return Node(
        rect: Rect.fromCenter(
            center: Offset(index * width + width / 2, widget.height / 2),
            width: width,
            height: widget.height),
        color: widget.colors[index],
      );
    });

    List<Node> tempNodes = <Node>[];
    for (int i = -widget.colors.length; i <= -1; i++) {
      tempNodes.add(Node(
        rect: Rect.fromCenter(
            center: Offset(i * width + width / 2, widget.height / 2),
            width: width,
            height: widget.height),
        color: widget.colors.first,
      ));
    }

    for (int i = 0; i < tempNodes.length; i++) {
      tempNodes[i].color = widget.colors[i];
    }

    nodes.addAll(tempNodes);

    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _calculateNewPositions();
    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: MyCustomPaint(nodes: nodes),
      ),
    );
  }

  void _calculateNewPositions() {
    for (final node in nodes) {
      final offset = node.rect.center;

      if (offset.dx - width / 2 >= widget.width) {
        node.rect = Rect.fromCenter(
            center: Offset(
                    (-width / 2) * (widget.colors.length * 2) + width / 2,
                    widget.height / 2) +
                widget.offsetSpeed,
            width: width,
            height: widget.height);
      } else {
        node.rect = Rect.fromCenter(
            center: offset + widget.offsetSpeed,
            width: width,
            height: widget.height);
      }
    }
  }
}

class Node {
  Rect rect;
  Color color;

  Node({required this.rect, required this.color});

  @override
  String toString() {
    return 'Node{rect: $rect, color: $color}\n';
  }
}

class MyCustomPaint extends CustomPainter {
  List<Node> nodes;

  MyCustomPaint({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < nodes.length; i++) {
      canvas.drawRect(nodes[i].rect, Paint()..color = nodes[i].color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

