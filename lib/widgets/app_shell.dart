import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  const AppShell({super.key, required this.child, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            height: MediaQuery.of(context).size.height - 24,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 24)],
            ),
            child: Column(
              children: [
                Expanded(child: child),
                // leave space for bottom nav (we place a BottomNavigationBar in screens)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
