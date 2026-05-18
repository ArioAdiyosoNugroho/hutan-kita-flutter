import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';

class ShellNavigation extends StatelessWidget {
  final Widget child;
  const ShellNavigation({super.key, required this.child});

  static const _tabs = [
    _TabItem(path: '/',            icon: Icons.home_rounded,         iconOutlined: Icons.home_outlined,          label: 'Beranda'),
    _TabItem(path: '/map',         icon: Icons.map_rounded,          iconOutlined: Icons.map_outlined,           label: 'Peta'),
    _TabItem(path: '/donate',      icon: Icons.park_rounded,         iconOutlined: Icons.park_outlined,          label: 'Donasi'),
    _TabItem(path: '/leaderboard', icon: Icons.leaderboard_rounded,  iconOutlined: Icons.leaderboard_outlined,   label: 'Peringkat'),
    _TabItem(path: '/profile',     icon: Icons.person_rounded,       iconOutlined: Icons.person_outline_rounded, label: 'Profil'),
  ];

  int _currentIndex(String loc) {
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc   = GoRouterState.of(context).matchedLocation;
    final index = _currentIndex(loc);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: child,
      floatingActionButton: _FabButton(
        isActive: index == 2,
        onPressed: () => context.go('/donate'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: index,
        tabs: _tabs,
        onTap: (i) => context.go(_tabs[i].path),
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────
class _FabButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;

  const _FabButton({required this.onPressed, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.green, AppColors.greenMd],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: isActive
                ? Border.all(color: Colors.white, width: 3)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: onPressed,
              child: const Icon(
                Icons.park_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Donasi',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.green : AppColors.textLt,
          ),
        ),
      ],
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(tabs.length, (i) {
              if (i == 2) {
                return const Expanded(child: SizedBox());
              }
              return Expanded(
                child: _NavItem(
                  tab: tabs[i],
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.green.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? tab.icon : tab.iconOutlined,
                  key: ValueKey(isActive),
                  size: 22,
                  color: isActive ? AppColors.green : AppColors.textLt,
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.green : AppColors.textLt,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Item Model ────────────────────────────────────────────────────────────
class _TabItem {
  final String path;
  final IconData icon;
  final IconData iconOutlined;
  final String label;

  const _TabItem({
    required this.path,
    required this.icon,
    required this.iconOutlined,
    required this.label,
  });
}
