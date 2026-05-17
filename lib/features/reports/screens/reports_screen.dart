import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/report.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/severity_badge.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _api = ApiService();
  List<Report> _reports  = [];
  bool _loading = true;
  bool _loadingMore = false;
  String _filter = 'all';
  int _page = 1;
  bool _hasMore = true;
  final _scroll = ScrollController();

  static const _types = {
    'all':             'Semua',
    'sawit_expansion': 'Sawit',
    'illegal_logging': 'Penebangan',
    'forest_fire':     'Kebakaran',
    'land_clearing':   'Buka Lahan',
    'mining':          'Tambang',
  };

  @override
  void initState() {
    super.initState();
    _fetch();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300
        && !_loadingMore && _hasMore) {
      _fetchMore();
    }
  }

  Future<void> _fetch({String? type}) async {
    setState(() { _loading = true; _page = 1; _reports = []; });
    try {
      final params = <String, dynamic>{'per_page': '20', 'page': '1'};
      if (_filter != 'all') params['type'] = _filter;
      final res = await _api.getReports(params: params);
      final data = res.data;
      final list = (data['data'] ?? []) as List;
      if (mounted) setState(() {
        _reports = list.map((e) => Report.fromJson(e)).toList();
        _hasMore = data['next_page_url'] != null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchMore() async {
    setState(() { _loadingMore = true; _page++; });
    try {
      final params = <String, dynamic>{'per_page': '20', 'page': '$_page'};
      if (_filter != 'all') params['type'] = _filter;
      final res = await _api.getReports(params: params);
      final data = res.data;
      final list = (data['data'] ?? []) as List;
      if (mounted) setState(() {
        _reports.addAll(list.map((e) => Report.fromJson(e)));
        _hasMore = data['next_page_url'] != null;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() { _loadingMore = false; _page--; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: Text('Semua Laporan',
          style: GoogleFonts.syne(
            fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: AppColors.green,
            child: SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: _types.entries.map((e) {
                  final active = _filter == e.key;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _filter = e.key);
                      _fetch();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: active ? AppColors.lime : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: active ? AppColors.lime : Colors.white.withOpacity(0.15)),
                      ),
                      child: Text(e.value,
                        style: GoogleFonts.dmSans(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: active ? AppColors.textDk : Colors.white)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // List
          Expanded(
            child: _loading
                ? ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, __) => const ShimmerBox(height: 100, radius: 16),
                  )
                : _reports.isEmpty
                    ? const EmptyState(
                        icon: Icons.forest_rounded,
                        title: 'Belum ada laporan',
                      )
                    : ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: _reports.length + (_loadingMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == _reports.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  color: AppColors.greenMd),
                              ),
                            );
                          }
                          return _ReportListTile(report: _reports[i]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ReportListTile extends StatelessWidget {
  final Report report;
  const _ReportListTile({required this.report});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/reports/${report.id}'),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 90, height: 90,
              child: report.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: report.photoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _thumb(),
                    )
                  : _thumb(),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SeverityBadge(severity: report.severity, small: true),
                      const SizedBox(width: 6),
                      StatusBadge(status: report.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(report.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5, fontWeight: FontWeight.w600,
                      color: AppColors.textDk, height: 1.4)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                        size: 11, color: AppColors.greenMd),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(report.locationText ?? '—',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 11, color: AppColors.textLt)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_fmt(report.createdAt),
                    style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.textLt)),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: AppColors.textLt),
          ),
        ],
      ),
    ),
  );

  Widget _thumb() => Container(
    color: const Color(0xFFDDE4D8),
    child: const Center(child: Icon(Icons.forest_rounded, size: 28,
      color: Color(0x1F000000))),
  );

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','Mei','Jun',
                'Jul','Ags','Sep','Okt','Nov','Des'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
