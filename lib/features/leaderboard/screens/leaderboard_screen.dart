import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/donation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/common_widgets.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _api = ApiService();
  List<LeaderboardEntry> _leaders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getDonationLeaderboard();
      setState(() {
        _leaders = (res.data as List)
            .map((e) => LeaderboardEntry.fromJson(e)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.offWhite,
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 240,
          backgroundColor: AppColors.green,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppColors.green,
              child: Stack(
                children: [
                  // Decoration circles
                  Positioned(right: -40, top: -40,
                    child: Container(width: 200, height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.lime.withOpacity(0.07),
                        shape: BoxShape.circle))),
                  Positioned(left: -20, bottom: -50,
                    child: Container(width: 140, height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.lime.withOpacity(0.05),
                        shape: BoxShape.circle))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('🏆',
                          style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 6),
                        Text('Papan Peringkat',
                          style: GoogleFonts.syne(
                            fontSize: 28, fontWeight: FontWeight.w800,
                            color: Colors.white, height: 1.1)),
                        Text('Pejuang hutan terbaik Indonesia',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.55))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Top 3 podium
        if (!_loading && _leaders.length >= 3)
          SliverToBoxAdapter(child: _buildPodium()),

        // Full list
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: _loading
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ShimmerBox(height: 70, radius: 14)),
                    childCount: 10))
              : _leaders.isEmpty
                  ? const SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.leaderboard_rounded,
                        title: 'Belum ada donatur',
                        subtitle: 'Jadilah yang pertama!'))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LeaderTile(entry: _leaders[i])),
                        childCount: _leaders.length)),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    ),
  );

  Widget _buildPodium() {
    final top3 = _leaders.take(3).toList();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd
          Expanded(child: _PodiumItem(
            entry: top3[1], height: 80, medal: '🥈')),
          const SizedBox(width: 8),
          // 1st
          Expanded(child: _PodiumItem(
            entry: top3[0], height: 110, medal: '🥇')),
          const SizedBox(width: 8),
          // 3rd
          Expanded(child: _PodiumItem(
            entry: top3[2], height: 60, medal: '🥉')),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final String medal;
  const _PodiumItem({required this.entry, required this.height, required this.medal});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.greenMd.withOpacity(0.15),
        child: Text(
          (entry.user?.name ?? 'A')[0].toUpperCase(),
          style: GoogleFonts.syne(
            fontSize: 20, fontWeight: FontWeight.w700,
            color: AppColors.greenMd)),
      ),
      const SizedBox(height: 6),
      Text(entry.user?.name ?? 'Anonim',
        style: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: AppColors.textDk),
        maxLines: 1, overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center),
      Text('${entry.totalTrees} 🌱',
        style: GoogleFonts.syne(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: AppColors.green)),
      const SizedBox(height: 8),
      Text(medal, style: const TextStyle(fontSize: 22)),
      Container(
        height: height, width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Text('#${entry.rank}',
          style: GoogleFonts.syne(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: AppColors.lime)),
      ),
    ],
  );
}

class _LeaderTile extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderTile({required this.entry});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: entry.rank <= 3 ? AppColors.green.withOpacity(0.04) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: entry.rank == 1 ? AppColors.lime.withOpacity(0.3) : AppColors.border,
        width: entry.rank == 1 ? 1.5 : 1),
    ),
    child: Row(
      children: [
        // Rank
        SizedBox(
          width: 36,
          child: entry.rank <= 3
              ? Text(
                  entry.rank == 1 ? '🥇' : entry.rank == 2 ? '🥈' : '🥉',
                  style: const TextStyle(fontSize: 22),
                  textAlign: TextAlign.center)
              : Text('#${entry.rank}',
                  style: GoogleFonts.syne(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.textLt),
                  textAlign: TextAlign.center),
        ),
        const SizedBox(width: 12),
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.greenMd.withOpacity(0.12),
          child: Text(
            (entry.user?.name ?? 'A')[0].toUpperCase(),
            style: GoogleFonts.syne(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.greenMd)),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.user?.name ?? 'Anonim',
                style: GoogleFonts.dmSans(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.textDk)),
              Text('${entry.donationCount}× donasi · ${entry.totalAmount}',
                style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.textLt)),
            ],
          ),
        ),
        // Trees
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${entry.totalTrees}',
              style: GoogleFonts.syne(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: AppColors.green)),
            Text('pohon 🌱',
              style: GoogleFonts.dmSans(
                fontSize: 10, color: AppColors.textLt)),
          ],
        ),
      ],
    ),
  );
}
