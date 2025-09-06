import 'package:flutter/material.dart';

class EmptyPagePlaceholder extends StatelessWidget {
  final String title;
  final String message;
  final bool isLoading;

  const EmptyPagePlaceholder({
    super.key,
    required this.title,
    required this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
