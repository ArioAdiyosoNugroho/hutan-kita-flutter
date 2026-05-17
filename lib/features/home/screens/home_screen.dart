import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/donation.dart';
import '../../../core/models/report.dart';
import '../../../core/models/stats.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../../features/auth/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();

  ReportStats?      _stats;
  DonationSummary?  _summary;
  List<Report>      _reports = [];
  bool              _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _api.getReportStats(),
        _api.getDonationSummary(),
        _api.getReports(params: {'per_page': '6', 'status': 'verified'}),
      ]);
      if (!mounted) return;
      setState(() {
        _stats   = ReportStats.fromJson(results[0].data);
        _summary = DonationSummary.fromJson(results[1].data);
        final raw = results[2].data;
        _reports = ((raw['data'] ?? raw) as List)
            .map((e) => Report.fromJson(e))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: RefreshIndicator(
        color: AppColors.lime,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox.shrink()), // Spacer
            SliverToBoxAdapter(child: _buildHero()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _buildTicker()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: _buildWhoWeAre(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.offWhite,
                child: _buildRecentReports(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: _buildCTA(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  // ── HERO ──────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      color: AppColors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Lindungi Hutan,\nSelamatkan\nMasa Depan',
              style: GoogleFonts.syne(
                fontSize: 42, fontWeight: FontWeight.w800,
                color: Colors.white, height: 0.98, letterSpacing: -1.5),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Laporkan deforestasi, pantau titik rawan, dan ikut dalam restorasi hutan Indonesia.',
              style: GoogleFonts.dmSans(
                fontSize: 14, color: Colors.white.withValues(alpha: 0.55), height: 1.75),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LimeButton(
              label: 'Donasi Pohon',
              onTap: () => context.go('/donate'),
            ),
          ),
          const SizedBox(height: 24),

          // Hero image with stats overlay
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 300,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              color: AppColors.greenMd,
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&auto=format&fit=crop&q=80',
                  fit: BoxFit.cover,
                  memCacheHeight: 300,
                  memCacheWidth: 600,
                  errorWidget: (_, __, ___) => Container(color: AppColors.greenMd),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.72),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
                // Stats card bottom-left
                Positioned(
                  bottom: 14, left: 14,
                  child: _HeroStatsCard(stats: _stats),
                ),
                // Live badge top-right
                Positioned(
                  top: 14, right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RepaintBoundary(child: _PulseDot()),
                        const SizedBox(width: 6),
                        const Text('Live Monitoring',
                          style: TextStyle(fontSize: 12, color: AppColors.lime, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TICKER ────────────────────────────────────────────────────────
  Widget _buildTicker() {
    final items = _reports.isNotEmpty
        ? _reports.map((r) => r.title).toList()
        : [
            'Penebangan Liar · Kalimantan Tengah',
            'Kebakaran Hutan · Riau',
            'Ekspansi Sawit · Sumatra Selatan',
            'Pembukaan Lahan Ilegal · Papua',
          ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: items
              .map((t) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5, height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.lime, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text(t,
                          style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF999999))),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── WHO WE ARE ────────────────────────────────────────────────────
  Widget _buildWhoWeAre() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Pill tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.lime, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text('Tentang Platform',
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5, color: AppColors.textMd)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Digerakkan Data,\nDipandu Komunitas',
            style: GoogleFonts.syne(
              fontSize: 28, fontWeight: FontWeight.w700,
              color: AppColors.textDk, letterSpacing: -0.5)),
          const SizedBox(height: 16),

          // Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFC8D5C8),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400&auto=format&fit=crop&q=60',
                  fit: BoxFit.cover,
                  memCacheHeight: 250,
                  memCacheWidth: 500,
                  errorWidget: (_, __, ___) => Container(color: const Color(0xFFC8D5C8)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12, left: 12,
                  child: Wrap(
                    spacing: 6, runSpacing: 6,
                    children: ['Transparan', 'Aksi Nyata', 'Berbasis Data', 'Komunitas']
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lime.withOpacity(0.93),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(t,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11, fontWeight: FontWeight.w600,
                                  color: AppColors.textDk)),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Dengan komunitas sebagai inti, kami menghadirkan transparansi penuh dalam pemantauan dan pemulihan hutan Indonesia.',
            style: GoogleFonts.syne(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.textDk, height: 1.5)),
          const SizedBox(height: 12),
          Text(
            'HutanKita adalah jaringan intelijen publik yang menghubungkan masyarakat, aktivis, dan pengambil kebijakan untuk aksi nyata. Setiap laporan diverifikasi, dipetakan, dan ditindaklanjuti — karena hutan Indonesia adalah warisan kita bersama.',
            style: GoogleFonts.dmSans(
              fontSize: 14, color: AppColors.textMd, height: 1.85)),
          const SizedBox(height: 20),

          // Stats grid
          if (_loading)
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: List.generate(4, (_) => const ShimmerBox(height: 60, radius: 14)),
            )
          else
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                StatChip(icon: Icons.warning_amber_rounded,
                  value: '${_stats?.totalReports ?? '—'}',
                  label: 'Total Laporan', color: AppColors.warning),
                StatChip(icon: Icons.park_rounded,
                  value: (_summary?.totalTreesPlanted?.toString() ?? '—'),
                  label: 'Pohon Ditanam', color: AppColors.greenMd),
                StatChip(icon: Icons.people_rounded,
                  value: '${_summary?.totalDonors ?? '—'}',
                  label: 'Relawan Aktif', color: AppColors.info),
                StatChip(icon: Icons.favorite_rounded,
                  value: '${_stats?.criticalReports ?? '—'}',
                  label: 'Kasus Kritis', color: AppColors.error),
              ],
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _DarkButton(
                  label: 'Pelajari Lebih',
                  onTap: () => context.go('/about'),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => context.go('/map'),
                child: Row(
                  children: [
                    Text('Tim Kami',
                      style: GoogleFonts.dmSans(
                        fontSize: 14, color: AppColors.textMd,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textLt)),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new_rounded,
                      size: 14, color: AppColors.textMd),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── RECENT REPORTS ────────────────────────────────────────────────
  Widget _buildRecentReports() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Laporan Terbaru',
                      style: GoogleFonts.syne(
                        fontSize: 24, fontWeight: FontWeight.w700,
                        color: AppColors.textDk, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Pantauan langsung dari masyarakat di lapangan',
                      style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.textLt)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/map'),
                child: Row(
                  children: [
                    Text('Semua',
                      style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.greenMd,
                        fontWeight: FontWeight.w500)),
                    const Icon(Icons.open_in_new_rounded,
                      size: 13, color: AppColors.greenMd),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading)
            Column(children: List.generate(3, (_) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: const ShimmerBox(height: 280, radius: 20),
              )))
          else if (_reports.isEmpty)
            const EmptyState(
              icon: Icons.forest_rounded,
              title: 'Belum ada laporan',
              subtitle: 'Jadilah yang pertama melaporkan!',
            )
          else
            ..._reports.take(6).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ReportCard(report: r),
            )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── CTA ───────────────────────────────────────────────────────────
  Widget _buildCTA() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DONASI POHON',
              style: GoogleFonts.dmSans(
                fontSize: 10, color: AppColors.lime,
                fontWeight: FontWeight.w600, letterSpacing: 2)),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: GoogleFonts.syne(
                  fontSize: 32, fontWeight: FontWeight.w700,
                  color: Colors.white, height: 1.1, letterSpacing: -0.5),
                children: const [
                  TextSpan(text: 'Rp 5.000 = 1 Pohon\n'),
                  TextSpan(text: 'di Lahan Nyata',
                    style: TextStyle(color: AppColors.lime)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Setiap pohon dipantau melalui satelit. Donasi kamu dicatat secara transparan untuk lahan-lahan terdeforestasi Indonesia.',
              style: GoogleFonts.dmSans(
                fontSize: 14, color: Colors.white.withOpacity(0.48), height: 1.8)),
            const SizedBox(height: 24),
            _LimeButton(
              label: 'Tanam Sekarang',
              onTap: () => context.go('/donate'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub widgets ────────────────────────────────────────────────────

class _HeroStatsCard extends StatelessWidget {
  final ReportStats? stats;
  const _HeroStatsCard({this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalReports;
    final crit  = stats?.criticalReports;
    final pct   = (total != null && total > 0 && crit != null)
        ? (crit / total * 100).round()
        : 72;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      constraints: const BoxConstraints(minWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('TOTAL LAPORAN MASUK',
            style: GoogleFonts.dmSans(
              fontSize: 9, color: Colors.white.withOpacity(0.45),
              letterSpacing: 0.7, fontWeight: FontWeight.w400)),
          const SizedBox(height: 4),
          Text(total?.toString() ?? '—',
            style: GoogleFonts.syne(
              fontSize: 30, fontWeight: FontWeight.w700,
              color: Colors.white, height: 1)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.14),
                    valueColor: const AlwaysStoppedAnimation(AppColors.lime),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$pct%',
                style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.lime, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${crit ?? '—'} kasus kritis',
            style: GoogleFonts.dmSans(
              fontSize: 11, color: Colors.white.withOpacity(0.38))),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _anim = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() { 
    _ctrl.stop();
    _ctrl.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: 6, height: 6,
      decoration: BoxDecoration(
        color: AppColors.lime,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(
          color: AppColors.lime.withValues(alpha: 0.55 * _anim.value),
          blurRadius: 7 * _anim.value,
        )],
      ),
    ),
  );
}

class _ReportCard extends StatelessWidget {
  final Report report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/reports/${report.id}'),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: const Color(0xFFDDE4D8),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (report.photoUrl != null)
                  CachedNetworkImage(
                    imageUrl: report.photoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const _PlaceholderIcon(),
                  )
                else
                  const _PlaceholderIcon(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.52)],
                      stops: const [0.48, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 10, right: 10,
                  child: SeverityBadge(severity: report.severity),
                ),
                Positioned(
                  bottom: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.58),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text('${report.typeEmoji} ${report.typeLabel}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11, color: Colors.white.withOpacity(0.88))),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: AppColors.textDk, height: 1.48)),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                if (report.locationText != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                        size: 12, color: AppColors.greenMd),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(report.locationText!,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 12, color: const Color(0xFFAAAAAA))),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(report.createdAt),
                      style: GoogleFonts.dmSans(
                        fontSize: 11, color: const Color(0xFFCCCCCC))),
                    Row(
                      children: [
                        Text('Detail',
                          style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.greenMd,
                            fontWeight: FontWeight.w500)),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_rounded,
                          size: 12, color: AppColors.greenMd),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun',
                    'Jul','Ags','Sep','Okt','Nov','Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFDDE4D8),
    child: const Center(
      child: Icon(Icons.forest_rounded, size: 44,
        color: Color(0x1F000000)),
    ),
  );
}

class _LimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.only(left: 20, right: 10, top: 9, bottom: 9),
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 13.5, fontWeight: FontWeight.w600,
              color: AppColors.textDk)),
          const SizedBox(width: 8),
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              color: AppColors.textDk, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_rounded,
              size: 14, color: AppColors.lime),
          ),
        ],
      ),
    ),
  );
}

class _DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DarkButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.only(left: 20, right: 10, top: 9, bottom: 9),
      decoration: BoxDecoration(
        color: AppColors.textDk,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 13.5, fontWeight: FontWeight.w600,
              color: Colors.white)),
          const SizedBox(width: 8),
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              color: AppColors.lime, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_rounded,
              size: 14, color: AppColors.textDk),
          ),
        ],
      ),
    ),
  );
}
