import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/report.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/severity_badge.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _api        = ApiService();
  final _mapCtrl    = MapController();

  List<Report> _reports  = [];
  List<Report> _filtered = [];
  String       _filter   = 'all';
  bool         _loading  = true;
  Report?      _selected;
  bool         _showList = false;

  static const _types = {
    'all':             ('Semua',          '🗺️'),
    'sawit_expansion': ('Ekspansi Sawit', '🌴'),
    'illegal_logging': ('Penebangan',     '🪓'),
    'forest_fire':     ('Kebakaran',      '🔥'),
    'land_clearing':   ('Buka Lahan',     '🚜'),
    'mining':          ('Tambang',        '⛏️'),
  };

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getReportMapPins();
      final data = res.data;
      final list = (data is List ? data : (data['data'] ?? [])) as List;
      _reports = list.map((e) => Report.fromJson(e)).toList();
      _selected = null;
      _applyFilter();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _applyFilter() {
    setState(() {
      _selected = null;
      _filtered = _filter == 'all'
          ? List.from(_reports)
          : _reports.where((r) => r.reportType == _filter).toList();
    });
  }

  Color _markerColor(String? sev) => AppColors.severityColor(sev);

  int get _critCount => _filtered.where((r) => r.severity == 'critical').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Stack(
        children: [
          // ── MAP ──
          FlutterMap(
            mapController: _mapCtrl,
            options: const MapOptions(
              initialCenter: LatLng(-2.5489, 118.0149),
              initialZoom: 5,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a','b','c','d'],
                userAgentPackageName: 'com.hutankita.app',
              ),
              MarkerLayer(
                markers: _filtered
                    .where((r) => r.lat != null && r.lng != null)
                    .take(100)  // Limit markers to prevent lag
                    .map((r) => Marker(
                          point: LatLng(r.lat!, r.lng!),
                          width: 44, height: 44,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selected = _selected?.id == r.id ? null : r;
                            }),
                            child: _MarkerDot(
                              color: _markerColor(r.severity),
                              isSelected: _selected?.id == r.id,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),

          // ── TOP BAR ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12, right: 12,
            child: _buildTopBar(),
          ),

          // ── FILTER CHIPS ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 68,
            left: 0, right: 0,
            child: _buildFilterChips(),
          ),

          // ── POPUP CARD ──
          if (_selected != null)
            Positioned(
              bottom: 100, left: 16, right: 16,
              child: _ReportPopupCard(
                report: _selected!,
                onClose: () => setState(() => _selected = null),
                onTap: () => context.push('/reports/${_selected!.id}'),
              ),
            ),

          // ── LEGEND ──
          if (_selected == null)
            Positioned(
              bottom: 100, right: 12,
              child: _LegendCard(filtered: _filtered),
            ),

          // ── LOADING ──
          if (_loading)
            Container(
              color: AppColors.offWhite.withOpacity(0.88),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.greenMd),
                    const SizedBox(height: 14),
                    Text('Memuat peta…',
                      style: GoogleFonts.dmSans(
                        fontSize: 14, color: AppColors.textMd)),
                  ],
                ),
              ),
            ),

          // ── LIST BOTTOM SHEET toggle ──
          Positioned(
            bottom: 16, left: 12,
            child: _StatsChip(
              count: _filtered.length,
              critCount: _critCount,
            ),
          ),
          Positioned(
            bottom: 16, right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'refresh',
                  onPressed: _fetch,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.refresh_rounded, color: AppColors.greenMd),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: 'add_report',
                  onPressed: () => context.push('/submit-report'),
                  backgroundColor: AppColors.green,
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      // ── SIDE LIST SHEET ──
      bottomSheet: _showList ? _buildListSheet() : null,
    );
  }

  Widget _buildTopBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 20)],
    ),
    child: Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(
            color: AppColors.lime, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('${_filtered.length}',
          style: GoogleFonts.syne(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: AppColors.textDk)),
        Text(' laporan',
          style: GoogleFonts.dmSans(
            fontSize: 11, color: AppColors.textLt)),
        if (_critCount > 0) ...[
          const SizedBox(width: 12),
          const SizedBox(width: 1, height: 18,
            child: ColoredBox(color: AppColors.border)),
          const SizedBox(width: 12),
          const Icon(Icons.warning_amber_rounded,
            size: 12, color: AppColors.error),
          const SizedBox(width: 4),
          Text('$_critCount',
            style: GoogleFonts.syne(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.error)),
          Text(' kritis',
            style: GoogleFonts.dmSans(
              fontSize: 11, color: AppColors.textLt)),
        ],
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _showList = !_showList),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _showList ? AppColors.green : AppColors.offWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.list_rounded,
              size: 18,
              color: _showList ? Colors.white : AppColors.textMd),
          ),
        ),
      ],
    ),
  );

  Widget _buildFilterChips() => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemCount: _types.length,
      itemBuilder: (_, i) {
        final key  = _types.keys.elementAt(i);
        final val  = _types[key]!;
        final cnt  = key == 'all'
            ? _reports.length
            : _reports.where((r) => r.reportType == key).length;
        final active = _filter == key;
        return GestureDetector(
          onTap: () {
            setState(() => _filter = key);
            _applyFilter();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.green : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: active ? AppColors.green : Colors.black.withOpacity(0.1),
                width: 1.5),
              boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${val.$2} ',
                  style: const TextStyle(fontSize: 13)),
                Text(val.$1,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5, fontWeight: FontWeight.w500,
                    color: active ? Colors.white : AppColors.textMd)),
                if (key != 'all') ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text('$cnt',
                      style: GoogleFonts.dmSans(
                        fontSize: 10.5, fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.textLt)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _buildListSheet() => Container(
    height: MediaQuery.of(context).size.height * 0.5,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      boxShadow: [BoxShadow(color: Color(0x29000000), blurRadius: 40, offset: Offset(0, -8))],
    ),
    child: Column(
      children: [
        // Handle
        const SizedBox(height: 10),
        Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.14),
            borderRadius: BorderRadius.circular(99)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              const Icon(Icons.list_rounded, size: 16, color: AppColors.greenMd),
              const SizedBox(width: 8),
              Text('Daftar Laporan',
                style: GoogleFonts.syne(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDk)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(99)),
                child: Text('${_filtered.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lime)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showList = false),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textLt)),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final r = _filtered[i];
              return ListTile(
                onTap: () {
                  setState(() { _selected = r; _showList = false; });
                  if (r.lat != null && r.lng != null) {
                    _mapCtrl.move(LatLng(r.lat!, r.lng!), 12);
                  }
                },
                leading: Container(
                  width: 10, height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: _markerColor(r.severity),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: _markerColor(r.severity).withOpacity(0.3),
                      blurRadius: 6)],
                  ),
                ),
                title: Text(r.title,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: AppColors.textDk)),
                subtitle: Text(
                  '${r.severityLabel} · ${r.typeLabel}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textLt)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: AppColors.textLt),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _MarkerDot extends StatelessWidget {
  final Color color;
  final bool  isSelected;
  const _MarkerDot({required this.color, required this.isSelected});

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 28 : 20,
        height: isSelected ? 28 : 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.44), blurRadius: 8),
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4,
              offset: const Offset(0, 2)),
          ],
        ),
      ),
    ),
  );
}

class _ReportPopupCard extends StatelessWidget {
  final Report      report;
  final VoidCallback onClose;
  final VoidCallback onTap;
  const _ReportPopupCard({
    required this.report,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.lime.withOpacity(0.2)),
      boxShadow: const [BoxShadow(
        color: Color(0x66000000), blurRadius: 40)],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          if (report.photoUrl != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: report.photoUrl!,
                  height: 120, width: double.infinity, fit: BoxFit.cover,
                  memCacheHeight: 120,
                  memCacheWidth: 400,
                  placeholder: (_, __) => Container(color: AppColors.offWhite),
                  errorWidget: (_, __, ___) => Container(color: AppColors.offWhite),
                ),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(report.title,
                      style: GoogleFonts.syne(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.white, height: 1.35),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(Icons.close_rounded,
                      color: Colors.white54, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.severityColor(report.severity).withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.severityColor(report.severity),
                            shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(report.severityLabel,
                          style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(report.typeLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 11, color: Colors.white.withOpacity(0.6))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lihat Detail',
                        style: GoogleFonts.dmSans(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.textDk)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded,
                        size: 13, color: AppColors.textDk),
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

class _LegendCard extends StatelessWidget {
  final List<Report> filtered;
  const _LegendCard({required this.filtered});

  static const _sev = {
    'low':      ('Rendah', AppColors.low),
    'medium':   ('Sedang', AppColors.medium),
    'high':     ('Tinggi', AppColors.high),
    'critical': ('Kritis', AppColors.critical),
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.94),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: const [BoxShadow(
        color: Color(0x1C000000), blurRadius: 24)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('KEPARAHAN',
          style: GoogleFonts.dmSans(
            fontSize: 9.5, color: AppColors.textLt,
            fontWeight: FontWeight.w700, letterSpacing: 1.1)),
        const SizedBox(height: 10),
        ..._sev.entries.map((e) {
          final cnt = filtered.where((r) => r.severity == e.key).length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: e.value.$2,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: e.value.$2.withOpacity(0.28), blurRadius: 4)],
                  ),
                ),
                const SizedBox(width: 8),
                Text(e.value.$1,
                  style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.textDk)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: cnt > 0 ? e.value.$2 : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('$cnt',
                    style: GoogleFonts.dmSans(
                      fontSize: 10.5, fontWeight: FontWeight.w600,
                      color: cnt > 0 ? Colors.white : AppColors.textLt)),
                ),
              ],
            ),
          );
        }),
        const Divider(height: 12, color: AppColors.border),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total',
              style: GoogleFonts.dmSans(
                fontSize: 10.5, color: AppColors.textLt,
                fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            Text('${filtered.length}',
              style: GoogleFonts.syne(
                fontSize: 14, color: AppColors.textDk,
                fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    ),
  );
}

class _StatsChip extends StatelessWidget {
  final int count;
  final int critCount;
  const _StatsChip({required this.count, required this.critCount});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
      boxShadow: const [BoxShadow(
        color: Color(0x1A000000), blurRadius: 20)],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$count',
          style: GoogleFonts.syne(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDk)),
        const SizedBox(width: 4),
        Text('laporan',
          style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textLt)),
        if (critCount > 0) ...[
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: 12),
          Text('$critCount',
            style: GoogleFonts.syne(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.error)),
          const SizedBox(width: 4),
          Text('kritis',
            style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textLt)),
        ],
      ],
    ),
  );
}
