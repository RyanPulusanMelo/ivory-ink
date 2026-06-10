import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'errands.dart';
import 'settings.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: const Color(0xFF0A0A0A),
        activeColor: CupertinoColors.white,
        inactiveColor: const Color(0xFF3A3A3C),
        border: const Border(
          top: BorderSide(color: Color(0xFF1C1C1E), width: 0.5),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.square_list_fill, size: 22),
            ),
            label: 'Errands',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.settings_solid, size: 22),
            ),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == 0) {
          return const Errands();
        } else {
          return const Settings();
        }
      },
    );
  }
}