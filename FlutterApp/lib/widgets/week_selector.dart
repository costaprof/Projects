import 'package:flutter/material.dart';

class WeekSelector extends StatelessWidget {
  final String weekRange;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const WeekSelector({super.key, 
    required this.weekRange,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.green),
          onPressed: onPreviousWeek,
        ),
        Column(
          children: [
            const Text(
              'Diese Woche',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              weekRange,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.green),
          onPressed: onNextWeek,
        ),
      ],
    );
  }
}
