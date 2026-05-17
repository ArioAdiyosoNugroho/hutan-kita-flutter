import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../features/auth/providers/auth_provider.dart';

class ShellNavigation extends StatelessWidget {
  final Widget child;
  const ShellNavigation({super.key, required this.child});

  static const _tabs = [
    _TabItem(path: '/',            icon: Icons.home_rounded,        label: 'Beranda'),
    _TabItem(path: '/map',         icon: Icons.map_rounded,         label: 'Peta'),
    _TabItem(path: '/donate',      icon: Icons.park_rounded,        label: 'Donasi'),
    _TabItem(path: '/leaderboard', icon: Icons.leaderboard_rounded, label: 'Peringkat'),
    _TabItem(path: '/about',       icon: Icons.info_outline_rounded, label: 'Tentang'),
  ];

  int _currentIndex(String loc) {
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final index = _currentIndex(loc);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!auth.isAuth) {
            context.push('/login');
          } else {
            context.push('/submit-report');
          }
        },
        child: const Icon(Icons.add_rounded, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.white,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => context.go(_tabs[i].path),
          backgroundColor: AppColors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.textLt,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: _tabs.map(
            (tab) => BottomNavigationBarItem(
              icon: Icon(tab.icon, size: 22),
              label: tab.label,
            ),
          ).toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final String path;
  final IconData icon;
  final String label;
  const _TabItem({required this.path, required this.icon, required this.label});
}
