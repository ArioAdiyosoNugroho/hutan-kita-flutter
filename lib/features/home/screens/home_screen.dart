// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/donation.dart';
import '../../../core/models/report.dart';
import '../../../core/models/stats.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/severity_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();

  static ReportStats?     _cachedStats;
  static DonationSummary? _cachedSummary;
  static List<Report>     _cachedReports = [];
  static DateTime?        _lastFetch;

  ReportStats?     _stats;
  DonationSummary? _summary;
  List<Report>     _reports = [];
  bool             _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWithCache();
  }

  Future<void> _loadWithCache() async {
    if (_cachedStats != null) {
      setState(() {
        _stats   = _cachedStats;
        _summary = _cachedSummary;
        _reports = _cachedReports;
        _loading = false;
      });

      final fresh = _lastFetch != null &&
          DateTime.now().difference(_lastFetch!) < const Duration(minutes: 5);
      if (fresh) return;
    }

    await _fetch();
  }

Future<void> _fetch() async {
  try {
    final results = await Future.wait([
      _api.getReportStats(),
      _api.getDonationSummary(),
      _api.getReports(params: {'per_page': '6'}),
    ]);
    if (!mounted) return;

    final raw = results[2].data;

    final reports = ((raw['data'] ?? raw) as List)
        .map((e) => Report.fromJson(e))
        .toList();

    final stats   = ReportStats.fromJson(results[0].data);
    final summary = DonationSummary.fromJson(results[1].data);

    _cachedStats   = stats;
    _cachedSummary = summary;
    _cachedReports = reports;
    _lastFetch     = DateTime.now();

    if (!mounted) return;
    setState(() {
      _stats   = stats;
      _summary = summary;
      _reports = reports;
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
        onRefresh: _fetch,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          cacheExtent: 800,
          slivers: [
            const _HeroSection(),
            SliverToBoxAdapter(
              child: _WhoWeAreSection(
                stats: _stats,
                summary: _summary,
                loading: _loading,
              ),
            ),
            _RecentReportsSection(
              reports: _reports,
              loading: _loading,
            ),
            SliverToBoxAdapter(
              child: ColoredBox(
                color: Colors.white,
                child: const _CTASection(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: AppColors.green,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Lindungi Hutan,\nSelamatkan\nMasa Depan',
                style: AppTextStyles.heroTitle,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Laporkan deforestasi, pantau titik rawan, dan ikut dalam restorasi hutan Indonesia.',
                style: AppTextStyles.bodyHero,
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
            RepaintBoundary(child: const _HeroImage()),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 300,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        color: AppColors.greenMd,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&auto=format&fit=crop&q=80',
            fit: BoxFit.cover,
            memCacheHeight: 300,
            memCacheWidth: 600,
            errorWidget: (_, __, ___) =>
                const ColoredBox(color: AppColors.greenMd),
          ),
          const _HeroGradient(),
          Positioned(
            bottom: 14,
            left: 14,
            child: const _HeroStatsCard(),
          ),
          const Positioned(
            top: 14,
            right: 14,
            child: _LiveBadge(),
          ),
        ],
      ),
    );
  }
}

class _HeroGradient extends StatelessWidget {
  const _HeroGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
    );
  }
}

class _HeroStatsCard extends StatelessWidget {
  const _HeroStatsCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('LIVE MONITORING AKTIF', style: AppTextStyles.heroStatLabel),
            const SizedBox(height: 6),
          Text('Hutan Indonesia', style: AppTextStyles.heroStat),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(
                    value: 0.72,
                    minHeight: 4,
                    backgroundColor: Color(0x24FFFFFF),
                    valueColor: AlwaysStoppedAnimation(AppColors.lime),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('72%', style: AppTextStyles.tinyLime),
            ],
          ),
            const SizedBox(height: 4),
            Text('area terpantau aktif', style: AppTextStyles.heroStatSub),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ FIX 1: hapus const — _PulseDot adalah StatefulWidget
          RepaintBoundary(child: _PulseDot()),
          const SizedBox(width: 6),
          const Text(
            'Live Monitoring',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.lime,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WHO WE ARE
// ─────────────────────────────────────────────────────────────────────────────
class _WhoWeAreSection extends StatelessWidget {
  final ReportStats?     stats;
  final DonationSummary? summary;
  final bool             loading;

  const _WhoWeAreSection({
    required this.stats,
    required this.summary,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PillTag(label: 'Tentang Platform'),
            const SizedBox(height: 16),
            Text(
              'Digerakkan Data,\nDipandu Komunitas',
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 16),
            RepaintBoundary(child: const _WhoWeAreImage()),
            const SizedBox(height: 20),
            Text(
              'Dengan komunitas sebagai inti, kami menghadirkan transparansi penuh dalam pemantauan dan pemulihan hutan Indonesia.',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            Text(
              'HutanKita adalah jaringan intelijen publik yang menghubungkan masyarakat, aktivis, dan pengambil kebijakan untuk aksi nyata. Setiap laporan diverifikasi, dipetakan, dan ditindaklanjuti — karena hutan Indonesia adalah warisan kita bersama.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 20),
            _StatsGrid(stats: stats, summary: summary, loading: loading),
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
                      Text(
                        'Tim Kami',
                        style: AppTextStyles.label.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textLt,
                        ),
                      ),
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
      ),
    );
  }
}

class _WhoWeAreImage extends StatelessWidget {
  const _WhoWeAreImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        color: Color(0xFFC8D5C8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400&auto=format&fit=crop&q=60',
            fit: BoxFit.cover,
            memCacheHeight: 250,
            memCacheWidth: 500,
            errorWidget: (_, __, ___) =>
                const ColoredBox(color: Color(0xFFC8D5C8)),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: const [
                _TagPill(label: 'Transparan'),
                _TagPill(label: 'Aksi Nyata'),
                _TagPill(label: 'Berbasis Data'),
                _TagPill(label: 'Komunitas'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: AppTextStyles.tagBadge),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final ReportStats?     stats;
  final DonationSummary? summary;
  final bool             loading;

  const _StatsGrid({
    required this.stats,
    required this.summary,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return ShimmerWrap(
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: List.generate(
            4,
            (_) => const ShimmerBox(height: 60, radius: 14),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        StatChip(
          icon: Icons.warning_amber_rounded,
          value: '${stats?.totalReports ?? '—'}',
          label: 'Total Laporan',
          color: AppColors.warning,
        ),
        StatChip(
          icon: Icons.park_rounded,
          value: summary?.totalTreesPlanted.toString() ?? '—',
          label: 'Pohon Ditanam',
          color: AppColors.greenMd,
        ),
        StatChip(
          icon: Icons.people_rounded,
          value: '${summary?.totalDonors ?? '—'}',
          label: 'Relawan Aktif',
          color: AppColors.info,
        ),
        StatChip(
          icon: Icons.favorite_rounded,
          value: '${stats?.criticalReports ?? '—'}',
          label: 'Kasus Kritis',
          color: AppColors.error,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECENT REPORTS
// ─────────────────────────────────────────────────────────────────────────────
class _RecentReportsSection extends StatelessWidget {
  final List<Report> reports;
  final bool         loading;

  const _RecentReportsSection({
    required this.reports,
    required this.loading,
  });

  // ✅ FIX 2: build() tertutup dengan benar, _ReportsHeader di luar method ini
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: AppColors.offWhite,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ReportsHeader(),
              const SizedBox(height: 20),
              if (loading)
                ShimmerWrap(
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerBox(height: 280, radius: 20),
                      ),
                    ),
                  ),
                )
              else if (reports.isEmpty)
                const EmptyState(
                  icon: Icons.forest_rounded,
                  title: 'Belum ada laporan',
                  subtitle: 'Jadilah yang pertama melaporkan!',
                )
              else
                ...List.generate(
                  reports.length.clamp(0, 6),
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: RepaintBoundary(
                      child: _ReportCard(report: reports[i]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  } // ← closing brace build()
} // ← closing brace class _RecentReportsSection

// ✅ FIX 3: _ReportsHeader sekarang di luar class _RecentReportsSection
class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Laporan Terbaru', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text(
                'Pantauan langsung dari masyarakat di lapangan',
                style: AppTextStyles.tiny,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => GoRouter.of(context).go('/map'),
          child: Row(
            children: [
              Text('Semua', style: AppTextStyles.captionGreen),
              const Icon(Icons.open_in_new_rounded,
                  size: 13, color: AppColors.greenMd),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA
// ─────────────────────────────────────────────────────────────────────────────
class _CTASection extends StatelessWidget {
  const _CTASection();

  @override
  Widget build(BuildContext context) {
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
            Text('DONASI POHON', style: AppTextStyles.ctaOverline),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: AppTextStyles.ctaTitle,
                children: const [
                  TextSpan(text: 'Rp 5.000 1 Pohon\n'),
                  TextSpan(
                    text: 'di Lahan Nyata',
                    style: TextStyle(color: AppColors.lime),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Setiap pohon dipantau melalui satelit. Donasi kamu dicatat secara transparan untuk lahan-lahan terdeforestasi Indonesia.',
              style: AppTextStyles.bodyHero,
            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// REPORT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  final Report report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/reports/${report.id}'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 12),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReportCardImage(report: report),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
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
                          child: Text(
                            report.locationText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDate(report.createdAt),
                          style: AppTextStyles.dateLabel),
                      Row(
                        children: [
                          Text('Detail', style: AppTextStyles.captionGreen),
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
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _ReportCardImage extends StatelessWidget {
  final Report report;
  const _ReportCardImage({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Color(0xFFDDE4D8),
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
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.52),
                ],
                stops: const [0.48, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: SeverityBadge(severity: report.severity),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '${report.typeEmoji} ${report.typeLabel}',
                style: AppTextStyles.tiny.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFDDE4D8),
      child: Center(
        child: Icon(Icons.forest_rounded, size: 44, color: Color(0x1F000000)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _PillTag extends StatelessWidget {
  final String label;
  const _PillTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.lime,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text('Tentang Platform', style: AppTextStyles.label),
        ],
      ),
    );
  }
}

class _LimeButton extends StatelessWidget {
  final String       label;
  final VoidCallback onTap;
  const _LimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            Text(label, style: AppTextStyles.labelDk),
            const SizedBox(width: 8),
            const _ArrowCircle(
              bg: AppColors.textDk,
              iconColor: AppColors.lime,
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  final String       label;
  final VoidCallback onTap;
  const _DarkButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            Text(label, style: AppTextStyles.labelWhite),
            const SizedBox(width: 8),
            const _ArrowCircle(
              bg: AppColors.lime,
              iconColor: AppColors.textDk,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowCircle extends StatelessWidget {
  final Color bg;
  final Color iconColor;
  const _ArrowCircle({required this.bg, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(Icons.arrow_forward_rounded, size: 14, color: iconColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PULSE DOT
// ─────────────────────────────────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  // ✅ FIX 4: tidak ada const constructor — StatefulWidget tidak bisa const
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _anim = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl
      ..stop()
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: 6,
        height: 6,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.lime,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.lime.withValues(alpha: 0.55 * _anim.value),
                blurRadius: 7 * _anim.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
