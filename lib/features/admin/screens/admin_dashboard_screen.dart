import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/stats.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/common_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _api = ApiService();
  AdminDashboard? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.getAdminDashboard();
      if (mounted) setState(() {
        _data = AdminDashboard.fromJson(res.data);
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Gagal memuat data. Pastikan Anda memiliki akses admin.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.offWhite,
    appBar: AppBar(
      backgroundColor: AppColors.green,
      title: Text('Dashboard Admin',
        style: GoogleFonts.syne(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _fetch),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.greenMd))
        : _error != null
            ? ErrorState(message: _error!, onRetry: _fetch)
            : RefreshIndicator(
                color: AppColors.greenMd,
                onRefresh: _fetch,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick nav
                      Row(children: [
                        Expanded(child: _QuickNavCard(
                          icon: Icons.fact_check_rounded,
                          label: 'Kelola Laporan',
                          count: _data?.reports['pending'] ?? 0,
                          countLabel: 'menunggu',
                          onTap: () => context.push('/admin/reports'))),
                        const SizedBox(width: 12),
                        Expanded(child: _QuickNavCard(
                          icon: Icons.volunteer_activism_rounded,
                          label: 'Kelola Donasi',
                          count: _data?.donations['pending'] ?? 0,
                          countLabel: 'menunggu',
                          onTap: () => context.push('/admin/donations'))),
                      ]),
                      const SizedBox(height: 20),

                      // Users stats
                      _sectionTitle('Pengguna'),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _StatCard(
                          label: 'Total Pengguna',
                          value: '${_data?.users['total'] ?? 0}',
                          icon: Icons.people_rounded,
                          color: AppColors.info)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(
                          label: 'Baru Hari Ini',
                          value: '${_data?.users['new_today'] ?? 0}',
                          icon: Icons.person_add_rounded,
                          color: AppColors.greenMd)),
                      ]),
                      const SizedBox(height: 20),

                      // Reports stats
                      _sectionTitle('Laporan'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2, shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12, mainAxisSpacing: 12,
                        childAspectRatio: 2.0,
                        children: [
                          _StatCard(
                            label: 'Total',
                            value: '${_data?.reports['total'] ?? 0}',
                            icon: Icons.article_rounded,
                            color: AppColors.textMd),
                          _StatCard(
                            label: 'Menunggu',
                            value: '${_data?.reports['pending'] ?? 0}',
                            icon: Icons.pending_rounded,
                            color: AppColors.warning),
                          _StatCard(
                            label: 'Terverifikasi',
                            value: '${_data?.reports['verified'] ?? 0}',
                            icon: Icons.verified_rounded,
                            color: AppColors.greenMd),
                          _StatCard(
                            label: 'Selesai',
                            value: '${_data?.reports['resolved'] ?? 0}',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.info),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Donations stats
                      _sectionTitle('Donasi'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2, shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12, mainAxisSpacing: 12,
                        childAspectRatio: 2.0,
                        children: [
                          _StatCard(
                            label: 'Total Berhasil',
                            value: '${_data?.donations['total_paid'] ?? 0}',
                            icon: Icons.payments_rounded,
                            color: AppColors.greenMd),
                          _StatCard(
                            label: 'Total Pohon',
                            value: '${_data?.donations['total_trees'] ?? 0}',
                            icon: Icons.park_rounded,
                            color: AppColors.lime,
                            textColor: AppColors.green),
                          _StatCard(
                            label: 'Total Nominal',
                            value: _fmtAmt(_data?.donations['total_amount'] ?? 0),
                            icon: Icons.monetization_on_rounded,
                            color: AppColors.warning),
                          _StatCard(
                            label: 'Menunggu',
                            value: '${_data?.donations['pending'] ?? 0}',
                            icon: Icons.hourglass_empty_rounded,
                            color: AppColors.textLt),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Recent reports
                      if (_data?.recentReports.isNotEmpty == true) ...[
                        _sectionTitle('Laporan Terbaru'),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border)),
                          child: Column(children: [
                            ..._data!.recentReports.asMap().entries.map((e) {
                              final r = e.value as Map<String, dynamic>;
                              return Column(children: [
                                ListTile(
                                  dense: true,
                                  title: Text(r['title'] ?? '',
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13, fontWeight: FontWeight.w500,
                                      color: AppColors.textDk)),
                                  subtitle: Text(r['user']?['name'] ?? 'Anonim',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11, color: AppColors.textLt)),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(r['status']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(99)),
                                    child: Text(_statusLabel(r['status']),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10, fontWeight: FontWeight.w600,
                                        color: _statusColor(r['status']))),
                                  ),
                                  onTap: () => context.push('/reports/${r['id']}'),
                                ),
                                if (e.key < _data!.recentReports.length - 1)
                                  const Divider(height: 1, color: AppColors.border),
                              ]);
                            }),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
  );

  Widget _sectionTitle(String t) => Text(t,
    style: GoogleFonts.syne(
      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDk));

  Color _statusColor(String? s) => switch (s) {
    'verified' => AppColors.greenMd,
    'resolved' => AppColors.info,
    'rejected' => AppColors.error,
    _          => AppColors.warning,
  };

  String _statusLabel(String? s) => switch (s) {
    'verified' => 'Terverifikasi',
    'resolved' => 'Selesai',
    'rejected' => 'Ditolak',
    _          => 'Menunggu',
  };

  String _fmtAmt(dynamic amt) {
    final n = (amt as num).toInt();
    if (n >= 1000000) return 'Rp ${(n/1000000).toStringAsFixed(1)}jt';
    if (n >= 1000)    return 'Rp ${(n/1000).round()}rb';
    return 'Rp $n';
  }
}

class _QuickNavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final String countLabel;
  final VoidCallback onTap;
  const _QuickNavCard({required this.icon, required this.label,
    required this.count, required this.countLabel, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.lime),
          const SizedBox(height: 12),
          Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.lime.withOpacity(0.2),
                borderRadius: BorderRadius.circular(99)),
              child: Text('$count $countLabel',
                style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.lime, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final Color? textColor;
  const _StatCard({required this.label, required this.value,
    required this.icon, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border)),
    child: Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                style: GoogleFonts.syne(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: textColor ?? AppColors.textDk, height: 1)),
              Text(label,
                style: GoogleFonts.dmSans(
                  fontSize: 10, color: AppColors.textLt),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
  );
}
