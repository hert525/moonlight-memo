import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/action_icons.dart';
import '../widgets/moon_asset_image.dart';
import 'journal_gate.dart';
import 'todo_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [const TodoTab(), const JournalGateTab()];

    return Stack(
      fit: StackFit.expand,
      children: [
        const MoonAssetImage(asset: kHomeBackground, fit: BoxFit.cover),
        Container(color: Colors.black.withAlpha(78)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(child: pages[_currentIndex]),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(45),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(color: kGold.withAlpha(128), width: 1.2),
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: kHotPink.withAlpha(36),
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) =>
                    setState(() => _currentIndex = index),
                destinations: const [
                  NavigationDestination(
                    icon: TabAssetIcon(asset: kTodoTabIcon),
                    selectedIcon: TabAssetIcon(
                      asset: kTodoTabIcon,
                      selected: true,
                    ),
                    label: '日程表',
                  ),
                  NavigationDestination(
                    icon: TabAssetIcon(asset: kJournalTabIcon),
                    selectedIcon: TabAssetIcon(
                      asset: kJournalTabIcon,
                      selected: true,
                    ),
                    label: '手账本',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
