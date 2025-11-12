import 'package:flutter/material.dart';

class InputBar extends StatelessWidget {
  const InputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.hintText,
    required this.isProcessing,
    required this.onStop,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;
  final bool isProcessing;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: hintText, border: InputBorder.none),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            if (isProcessing)
              IconButton(icon: const Icon(Icons.stop_circle_outlined), tooltip: "Stop generation", onPressed: onStop)
            else
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.blueAccent),
                onPressed: onSend,
              ),
          ],
        ),
      ),
    );
  }
}
