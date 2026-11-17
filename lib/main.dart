import 'package:flutter/material.dart';

import 'app_info.dart';
import 'pages/about_page.dart';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';
import 'widgets/app_drawer.dart';

void main() {
  runApp(const BaggageFeeApp());
}

/// Root widget of the Excess Baggage Fee Calculator.
class BaggageFeeApp extends StatelessWidget {
  const BaggageFeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}

/// Holds the shared AppBar, drawer and the currently selected page.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppInfo.appName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              tooltip: 'About this app',
              onPressed: () => _onDestinationSelected(1),
              icon: const Icon(Icons.info_outline),
            ),
        ],
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      // IndexedStack keeps the Home page inputs and results when the user
      // visits the About page and comes back.
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomePage(),
          AboutPage(),
        ],
      ),
    );
  }
}
