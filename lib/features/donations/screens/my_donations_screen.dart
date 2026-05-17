import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/donation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/common_widgets.dart';

// ══ My Donations ══════════════════════════════════════════════════
class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key});
  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  final _api = ApiService();
  List<Donation> _donations = [];
  bool _loading = true;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getMyDonations(page: 1);
      final data = res.data;
      setState(() {
        _donations = (data['data'] as List)
            .map((e) => Donation.fromJson(e)).toList();
        _hasMore = data['next_page_url'] != null;
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
      title: Text('Riwayat Donasi',
        style: GoogleFonts.syne(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: _loading
        ? ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const ShimmerBox(height: 100, radius: 14),
          )
        : _donations.isEmpty
            ? EmptyState(
                icon: Icons.park_rounded,
                title: 'Belum ada donasi',
                subtitle: 'Mulai donasi untuk menanam pohon!',
                action: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.textDk),
                  onPressed: () => context.go('/donate'),
                  child: const Text('Donasi Sekarang'),
                ),
              )
            : RefreshIndicator(
                color: AppColors.greenMd,
                onRefresh: _fetch,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _donations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _DonationTile(donation: _donations[i]),
                ),
              ),
  );
}

class _DonationTile extends StatelessWidget {
  final Donation donation;
  const _DonationTile({required this.donation});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (donation.status) {
      'paid'    => AppColors.greenMd,
      'failed'  => AppColors.error,
      'expired' => AppColors.textLt,
      _         => AppColors.medium,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌱', style: TextStyle(fontSize: 20)),
                Text('${donation.treesCount}',
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
                    Text(donation.formattedAmount,
                      style: GoogleFonts.syne(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.textDk)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(donation.statusLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${donation.treesCount} pohon akan ditanam',
                  style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.textMd)),
                const SizedBox(height: 2),
                Text(_fmt(donation.createdAt),
                  style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textLt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','Mei','Jun',
                'Jul','Ags','Sep','Okt','Nov','Des'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

// ══ Donation Success ══════════════════════════════════════════════
class DonationSuccessScreen extends StatefulWidget {
  final int? donationId;
  const DonationSuccessScreen({super.key, this.donationId});
  @override
  State<DonationSuccessScreen> createState() => _DonationSuccessScreenState();
}

class _DonationSuccessScreenState extends State<DonationSuccessScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  Donation? _donation;
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
    if (widget.donationId != null) _fetch();
  }

  @override
  void dispose() { 
    _ctrl.stop();
    _ctrl.dispose(); 
    super.dispose(); 
  }

  Future<void> _fetch() async {
    try {
      final res = await _api.getDonation(widget.donationId!, allowPublic: true);
      if (mounted) setState(() => _donation = Donation.fromJson(res.data));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.green,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: AppColors.lime.withOpacity(0.4),
                    blurRadius: 32, spreadRadius: 8)],
                ),
                child: const Icon(Icons.check_rounded,
                  size: 64, color: AppColors.textDk),
              ),
            ),
            const SizedBox(height: 32),
            Text('Terima Kasih!',
              style: GoogleFonts.syne(
                fontSize: 36, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -1)),
            const SizedBox(height: 12),
            Text(
              _donation != null
                  ? '${_donation!.treesCount} pohon akan segera ditanam\natas nama ${_donation!.donorName ?? "Anda"}'
                  : 'Donasi Anda akan segera diproses.\nTerima kasih telah menjaga hutan Indonesia!',
              style: GoogleFonts.dmSans(
                fontSize: 16, color: Colors.white.withOpacity(0.65),
                height: 1.7),
              textAlign: TextAlign.center),
            const SizedBox(height: 32),
            if (_donation != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Info(label: 'Nominal',
                      value: _donation!.formattedAmount),
                    Container(width: 1, height: 40,
                      color: Colors.white.withOpacity(0.15)),
                    _Info(label: 'Pohon',
                      value: '${_donation!.treesCount} 🌱'),
                    Container(width: 1, height: 40,
                      color: Colors.white.withOpacity(0.15)),
                    _Info(label: 'Status',
                      value: _donation!.statusLabel),
                  ],
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Kembali ke Beranda',
                  style: GoogleFonts.dmSans(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.textDk),
                  textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/my-donations'),
              child: Text('Lihat Riwayat Donasi',
                style: GoogleFonts.dmSans(
                  fontSize: 14, color: Colors.white.withOpacity(0.55),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withOpacity(0.3))),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

class _Info extends StatelessWidget {
  final String label, value;
  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label,
        style: GoogleFonts.dmSans(
          fontSize: 11, color: Colors.white.withOpacity(0.5))),
      const SizedBox(height: 4),
      Text(value,
        style: GoogleFonts.syne(
          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
    ],
  );
}
