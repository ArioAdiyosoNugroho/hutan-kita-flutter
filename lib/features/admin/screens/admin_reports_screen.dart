import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/report.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/severity_badge.dart';

// ══ Admin Reports ══════════════════════════════════════════════════
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _api = ApiService();
  List<Report> _reports = [];
  bool _loading = true;
  String _filter = 'all';

  static const _statuses = {
    'all':      'Semua',
    'pending':  'Menunggu',
    'verified': 'Terverifikasi',
    'resolved': 'Selesai',
    'rejected': 'Ditolak',
  };

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{'per_page': '50'};
      if (_filter != 'all') params['status'] = _filter;
      final res = await _api.getAdminReports(params: params);
      final data = res.data;
      setState(() {
        _reports = ((data['data'] ?? data) as List)
            .map((e) => Report.fromJson(e)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(Report report, String status, String? notes) async {
    try {
      await _api.updateAdminReport(report.id, {
        'status': status,
        if (notes != null && notes.isNotEmpty) 'admin_notes': notes,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diperbarui: $status'),
          backgroundColor: AppColors.greenMd));
      _fetch();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.offWhite,
    appBar: AppBar(
      backgroundColor: AppColors.green,
      title: Text('Kelola Laporan',
        style: GoogleFonts.syne(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetch),
      ],
    ),
    body: Column(
      children: [
        // Filter tabs
        Container(
          color: AppColors.green,
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _statuses.entries.map((e) {
                final active = _filter == e.key;
                return GestureDetector(
                  onTap: () { setState(() => _filter = e.key); _fetch(); },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: active ? AppColors.lime : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: active ? AppColors.lime : Colors.white.withOpacity(0.15))),
                    child: Text(e.value,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.5, fontWeight: FontWeight.w500,
                        color: active ? AppColors.textDk : Colors.white)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(
          child: _loading
              ? ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: 8,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, __) => const ShimmerBox(height: 110, radius: 14))
              : _reports.isEmpty
                  ? const EmptyState(
                      icon: Icons.fact_check_rounded,
                      title: 'Tidak ada laporan')
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: _reports.length,
                      itemBuilder: (_, i) => _AdminReportTile(
                        report: _reports[i],
                        onUpdateStatus: (status, notes) =>
                            _updateStatus(_reports[i], status, notes),
                        onView: () => context.push('/reports/${_reports[i].id}'),
                      )),
        ),
      ],
    ),
  );
}

class _AdminReportTile extends StatelessWidget {
  final Report report;
  final Function(String, String?) onUpdateStatus;
  final VoidCallback onView;
  const _AdminReportTile({required this.report,
    required this.onUpdateStatus, required this.onView});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          SeverityBadge(severity: report.severity, small: true),
          const SizedBox(width: 8),
          StatusBadge(status: report.status),
          const Spacer(),
          Text(_fmt(report.createdAt),
            style: GoogleFonts.dmSans(
              fontSize: 10, color: AppColors.textLt)),
        ]),
        const SizedBox(height: 8),
        Text(report.title,
          maxLines: 2, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSans(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDk)),
        const SizedBox(height: 4),
        Text('${report.user?.name ?? 'Anonim'} · ${report.typeLabel}',
          style: GoogleFonts.dmSans(
            fontSize: 12, color: AppColors.textLt)),
        const SizedBox(height: 12),

        // Action buttons
        Row(children: [
          GestureDetector(
            onTap: onView,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border)),
              child: Text('Lihat',
                style: GoogleFonts.dmSans(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: AppColors.textMd)),
            ),
          ),
          const SizedBox(width: 8),
          if (report.status == 'pending') ...[
            _ActionBtn('Verifikasi', AppColors.greenMd,
              () => onUpdateStatus('verified', null)),
            const SizedBox(width: 8),
            _ActionBtn('Tolak', AppColors.error,
              () => _showRejectDialog(context)),
          ] else if (report.status == 'verified')
            _ActionBtn('Selesaikan', AppColors.info,
              () => onUpdateStatus('resolved', null)),
        ]),
      ],
    ),
  );

  Widget _ActionBtn(String label, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3))),
        child: Text(label,
          style: GoogleFonts.dmSans(
            fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ),
    );

  Future<void> _showRejectDialog(BuildContext context) async {
    final notesCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tolak Laporan',
          style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Alasan penolakan (opsional):',
            style: GoogleFonts.dmSans(fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: notesCtrl, maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Catatan untuk pelapor...',
              border: OutlineInputBorder()),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.dmSans(color: AppColors.textMd))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onUpdateStatus('rejected', notesCtrl.text);
            },
            child: Text('Tolak',
              style: GoogleFonts.dmSans(
                color: AppColors.error, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','Mei','Jun',
                'Jul','Ags','Sep','Okt','Nov','Des'];
    return '${d.day} ${m[d.month-1]}';
  }
}

// ══ Admin Donations ════════════════════════════════════════════════
class AdminDonationsScreen extends StatefulWidget {
  const AdminDonationsScreen({super.key});
  @override
  State<AdminDonationsScreen> createState() => _AdminDonationsScreenState();
}

class _AdminDonationsScreenState extends State<AdminDonationsScreen> {
  final _api = ApiService();
  List<dynamic> _donations = [];
  bool _loading = true;
  String _filter = 'all';

  static const _statuses = {
    'all':     'Semua',
    'pending': 'Menunggu',
    'paid':    'Berhasil',
    'failed':  'Gagal',
  };

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{'per_page': '50'};
      if (_filter != 'all') params['status'] = _filter;
      final res = await _api.getAdminDonations(params: params);
      final data = res.data;
      setState(() {
        _donations = (data['data'] ?? data) as List;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.offWhite,
    appBar: AppBar(
      backgroundColor: AppColors.green,
      title: Text('Kelola Donasi',
        style: GoogleFonts.syne(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetch),
      ],
    ),
    body: Column(
      children: [
        Container(
          color: AppColors.green,
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _statuses.entries.map((e) {
                final active = _filter == e.key;
                return GestureDetector(
                  onTap: () { setState(() => _filter = e.key); _fetch(); },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: active ? AppColors.lime : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: active ? AppColors.lime : Colors.white.withOpacity(0.15))),
                    child: Text(e.value,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.5, fontWeight: FontWeight.w500,
                        color: active ? AppColors.textDk : Colors.white)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(
          child: _loading
              ? ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: 8,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, __) => const ShimmerBox(height: 90, radius: 14))
              : _donations.isEmpty
                  ? const EmptyState(
                      icon: Icons.volunteer_activism_rounded,
                      title: 'Tidak ada donasi')
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: _donations.length,
                      itemBuilder: (_, i) {
                        final d = _donations[i] as Map<String, dynamic>;
                        return _AdminDonationTile(data: d);
                      }),
        ),
      ],
    ),
  );
}

class _AdminDonationTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AdminDonationTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final statusColor = switch (status) {
      'paid'    => AppColors.greenMd,
      'failed'  => AppColors.error,
      'expired' => AppColors.textLt,
      _         => AppColors.warning,
    };
    final statusLabel = switch (status) {
      'paid'    => 'Berhasil',
      'failed'  => 'Gagal',
      'expired' => 'Kedaluwarsa',
      _         => 'Menunggu',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌱', style: TextStyle(fontSize: 18)),
                Text('${data['trees_count'] ?? 0}',
                  style: GoogleFonts.syne(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppColors.lime)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['amount_formatted'] ?? 'Rp —',
                      style: GoogleFonts.syne(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppColors.textDk)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: statusColor.withOpacity(0.3))),
                      child: Text(statusLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(data['donor_name'] ?? data['user']?['name'] ?? 'Anonim',
                  style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.textMd)),
                Text(data['donor_email'] ?? data['user']?['email'] ?? '',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textLt)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
