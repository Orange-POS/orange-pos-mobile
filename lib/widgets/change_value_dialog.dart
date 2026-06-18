import 'package:flutter/material.dart';

class ChangeValueDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final VoidCallback onSave;

  const ChangeValueDialog({
    super.key,
    required this.title,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
            Text(title),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Input field',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
