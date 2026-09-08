// lib/presentation/widgets/test_tube_widget.dart

import 'package:flutter/material.dart';
import '../../domain/entities/game_engine.dart';

class TestTubeWidget extends StatelessWidget {
  final TestTube tube;
  final bool isSelected;
  final VoidCallback onTap;

  const TestTubeWidget({
    Key? key,
    required this.tube,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  Color _getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      case 'transparent':
        return Colors.transparent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey[400]!,
            width: isSelected ? 4 : 2,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(12),
            bottomRight: const Radius.circular(12),
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
          ),
          color: Colors.white,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Water layers
            ...tube.colors.asMap().entries.map((entry) {
              final index = entry.key;
              final color = entry.value;
              final displayColor = _getColorFromString(color);

              return Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: displayColor,
                    border: Border(
                      top: index > 0
                          ? BorderSide(
                              color: displayColor == Colors.transparent
                                  ? Colors.transparent
                                  : Colors.black12,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: displayColor != Colors.transparent
                      ? Center(
                          child: Opacity(
                            opacity: 0.3,
                            child: Icon(
                              Icons.water_drop,
                              color: displayColor,
                              size: 20,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
