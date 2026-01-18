import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Numpad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const Numpad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: _NumpadKey(
                  label: key,
                  onTap: () {
                    if (key == '⌫') {
                      onBackspace();
                    } else {
                      onKeyPressed(key);
                    }
                  },
                  onLongPress: key == '⌫' ? onClear : null,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _NumpadKey({
    required this.label,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.stop()).shimmer(
      duration: 200.ms,
    );
  }
}
