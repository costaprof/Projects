import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final ValueChanged<int> onItemSelected;
  const BottomNavBar({super.key, required this.onItemSelected});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Start',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Einkaufsliste',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist),
          label: 'Inventar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Kochverlauf',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_stories),
          label: 'Meine Rezepte',
        ),
      ],
      currentIndex: _selectedIndex,
      unselectedItemColor: Colors.grey,
      unselectedLabelStyle: const TextStyle(
        color: Colors.grey,
      ),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      onTap: _onItemTapped,
    );
  }
}
