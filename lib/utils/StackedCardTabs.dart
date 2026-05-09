import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class StackedCardTabs extends StatelessWidget {
  final Widget expensesCard;
  final Widget balancesCard;

  const StackedCardTabs({
    Key? key,
    required this.expensesCard,
    required this.balancesCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the TabController from the nearest DefaultTabController
    final TabController? tabController = DefaultTabController.of(context);
    if (tabController == null) {
      return const SizedBox();
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Simple drag to switch tabs when dragging the card itself
        if (details.primaryVelocity! < 0 && tabController.index == 0) {
          tabController.animateTo(1);
        } else if (details.primaryVelocity! > 0 && tabController.index == 1) {
          tabController.animateTo(0);
        }
      },
      child: AnimatedBuilder(
        animation: tabController.animation!,
        builder: (context, child) {
          // val goes from 0.0 (Expenses) to 1.0 (Balances)
          double val = tabController.animation!.value;
          double width = MediaQuery.of(context).size.width;

          double c0Offset = 0;
          double c1Offset = 0;
          double c0Scale = 1.0;
          double c1Scale = 1.0;
          double activeScale = 0.94;
          double inactiveScale = 0.88;
          double activeOffsetMargin = 12.0;
          double inactiveOffsetMargin = 28.0;
          double swoopOffset = width * 0.55;

          AnimationStatus status = tabController.animation!.status;
          bool movingForward = true;
          if (status == AnimationStatus.forward) {
            movingForward = true;
          } else if (status == AnimationStatus.reverse) {
            movingForward = false;
          } else {
            movingForward = tabController.index == 1;
          }

          if (movingForward) {
            // Card 0 (active) sinks to left
            c0Offset =
                ui.lerpDouble(-activeOffsetMargin, -inactiveOffsetMargin, val)!;
            c0Scale = ui.lerpDouble(activeScale, inactiveScale, val)!;

            // Card 1 (inactive) swoops out right, lifts up, comes to active right
            c1Offset =
                ui.lerpDouble(inactiveOffsetMargin, activeOffsetMargin, val)! +
                    swoopOffset * math.sin(val * math.pi);
            c1Scale = ui.lerpDouble(inactiveScale, activeScale, val)! +
                0.12 * math.sin(val * math.pi);
          } else {
            // Card 1 (active) sinks to right
            c1Offset =
                ui.lerpDouble(inactiveOffsetMargin, activeOffsetMargin, val)!;
            c1Scale = ui.lerpDouble(inactiveScale, activeScale, val)!;

            // Card 0 (inactive) swoops out left, lifts up, comes to active left
            c0Offset = ui.lerpDouble(
                    -activeOffsetMargin, -inactiveOffsetMargin, val)! -
                swoopOffset * math.sin(val * math.pi);
            c0Scale = ui.lerpDouble(activeScale, inactiveScale, val)! +
                0.12 * math.sin(val * math.pi);
          }

          double c0Opacity = ui.lerpDouble(1.0, 0.7, val)!;
          double c1Opacity = ui.lerpDouble(0.7, 1.0, val)!;

          Widget card0Content = expensesCard;

          Widget card1Content = balancesCard;

          Widget card0 = Transform.translate(
            offset: Offset(c0Offset, 0),
            child: Transform.scale(
              scale: c0Scale,
              child: Opacity(
                opacity: c0Opacity,
                child: card0Content,
              ),
            ),
          );

          Widget card1 = Transform.translate(
            offset: Offset(c1Offset, 0),
            child: Transform.scale(
              scale: c1Scale,
              child: Opacity(
                opacity: c1Opacity,
                child: card1Content,
              ),
            ),
          );

          return SizedBox(
            child: Stack(
              alignment: Alignment.center,
              children: val > 0.5 ? [card0, card1] : [card1, card0],
            ),
          );
        },
      ),
    );
  }
}
