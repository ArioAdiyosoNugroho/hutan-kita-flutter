import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuth) return _buildGuest(context);
    return _buildProfile(context, auth);
  }

  Widget _buildGuest(BuildContext context) => Scaffold(
    backgroundColor: AppColors.offWhite,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.08),
                shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded,
                size: 52, color: AppColors.textLt),
            ),
            const SizedBox(height: 20),
            Text('Belum Masuk',
              style: GoogleFonts.syne(
                fontSize: 22, fontWeight: FontWeight.w700,
                color: AppColors.textDk)),
            const SizedBox(height: 8),
            Text(
              'Masuk untuk melihat profil, riwayat laporan, dan donasi Anda.',
              style: GoogleFonts.dmSans(
                fontSize: 14, color: AppColors.textLt, height: 1.7),
              textAlign: TextAlign.center),
            const SizedBox(height: 28),
            AppButton(
              label: 'Masuk',
              onTap: () => context.push('/login'),
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Daftar Akun Baru',
              outline: true,
              onTap: () => context.push('/register'),
              width: double.infinity,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildProfile(BuildContext context, AuthProvider auth) {
    final user = auth.user!;
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.green,
            iconTheme: const IconThemeData(color: Colors.white),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.green,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.lime,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: GoogleFonts.syne(
                                fontSize: 28, fontWeight: FontWeight.w700,
                                color: AppColors.textDk)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(user.name,
                                    style: GoogleFonts.syne(
                                      fontSize: 20, fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                                  if (user.isAdmin) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.lime,
                                        borderRadius: BorderRadius.circular(99)),
                                      child: Text('ADMIN',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 10, fontWeight: FontWeight.w700,
                                          color: AppColors.textDk)),
                                    ),
                                  ],
                                ]),
                                const SizedBox(height: 4),
                                Text(user.email,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.55))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(children: [
                    Expanded(child: _StatBox(
                      icon: Icons.report_rounded,
                      label: 'Laporan',
                      value: '${user.totalReports ?? user.reportsCount ?? 0}',
                      color: AppColors.warning)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatBox(
                      icon: Icons.park_rounded,
                      label: 'Pohon Ditanam',
                      value: '${user.totalTreesPlanted ?? 0}',
                      color: AppColors.greenMd)),
                  ]),
                  const SizedBox(height: 20),

                  // Menu
                  _MenuSection(title: 'Aktivitas Saya', items: [
                    _MenuItem(
                      icon: Icons.history_rounded,
                      label: 'Riwayat Donasi',
                      onTap: () => context.push('/my-donations')),
                    _MenuItem(
                      icon: Icons.article_rounded,
                      label: 'Laporan Saya',
                      onTap: () => context.push('/reports')),
                  ]),
                  const SizedBox(height: 12),

                  if (user.isAdmin)
                    _MenuSection(title: 'Administrasi', items: [
                      _MenuItem(
                        icon: Icons.dashboard_rounded,
                        label: 'Dashboard Admin',
                        onTap: () => context.push('/admin'),
                        isHighlighted: true),
                      _MenuItem(
                        icon: Icons.fact_check_rounded,
                        label: 'Kelola Laporan',
                        onTap: () => context.push('/admin/reports')),
                      _MenuItem(
                        icon: Icons.volunteer_activism_rounded,
                        label: 'Kelola Donasi',
                        onTap: () => context.push('/admin/donations')),
                    ]),

                  if (user.isAdmin) const SizedBox(height: 12),

                  _MenuSection(title: 'Lainnya', items: [
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang HutanKita',
                      onTap: () => context.go('/about')),
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Keluar',
                      color: AppColors.error,
                      onTap: () => _confirmLogout(context, auth)),
                  ]),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Keluar?',
          style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: Text('Anda akan keluar dari akun ini.',
          style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
              style: GoogleFonts.dmSans(color: AppColors.textMd))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Keluar',
              style: GoogleFonts.dmSans(color: AppColors.error,
                fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (ok == true) await auth.logout();
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatBox({required this.icon, required this.label,
    required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
              style: GoogleFonts.syne(
                fontSize: 22, fontWeight: FontWeight.w700,
                color: AppColors.textDk, height: 1)),
            Text(label,
              style: GoogleFonts.dmSans(
                fontSize: 11, color: AppColors.textLt)),
          ],
        ),
      ],
    ),
  );
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title,
          style: GoogleFonts.dmSans(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.textLt, letterSpacing: 1)),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
        child: Column(children: [
          ...items.asMap().entries.map((e) => Column(children: [
            e.value,
            if (e.key < items.length - 1)
              const Divider(height: 1, indent: 52, color: AppColors.border),
          ])),
        ]),
      ),
    ],
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isHighlighted;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.textDk;
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.lime
              : (color?.withOpacity(0.1) ?? AppColors.offWhite),
          borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18,
          color: isHighlighted ? AppColors.textDk : fg),
      ),
      title: Text(label,
        style: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
        size: 13, color: AppColors.textLt),
    );
  }
}
