import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/report.dart';
import '../../../core/models/report_comment.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../auth/providers/auth_provider.dart';

class ReportDetailScreen extends StatefulWidget {
  final int id;
  const ReportDetailScreen({super.key, required this.id});
  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _api         = ApiService();
  final _commentCtrl = TextEditingController();
  Report? _report;
  bool    _loading   = true;
  bool    _voting    = false;
  bool    _submitting = false;
  bool    _hasVoted  = false;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    try {
      final res = await _api.getReport(widget.id);
      if (mounted) setState(() { _report = Report.fromJson(res.data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _vote() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuth) { context.push('/login'); return; }
    setState(() => _voting = true);
    try {
      await _api.voteReport(widget.id);
      await _fetch();
      setState(() => _hasVoted = !_hasVoted);
    } catch (_) {}
    setState(() => _voting = false);
  }

  Future<void> _submitComment() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuth) { context.push('/login'); return; }
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await _api.addComment(widget.id, text);
      _commentCtrl.clear();
      await _fetch();
    } catch (_) {}
    setState(() => _submitting = false);
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await _api.deleteComment(widget.id, commentId);
      await _fetch();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.greenMd))
          : _report == null
              ? const ErrorState(message: 'Laporan tidak ditemukan')
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(child: _buildBody(auth)),
                  ],
                ),
    );
  }

  SliverAppBar _buildAppBar() => SliverAppBar(
    expandedHeight: _report!.photoUrl != null ? 280 : 120,
    pinned: true,
    backgroundColor: AppColors.green,
    iconTheme: const IconThemeData(color: Colors.white),
    flexibleSpace: FlexibleSpaceBar(
      background: _report!.photoUrl != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: _report!.photoUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: AppColors.greenMd),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
              ],
            )
          : Container(color: AppColors.green),
      title: Text(_report!.title,
        style: GoogleFonts.syne(
          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        maxLines: 2),
      titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
    ),
    actions: [
      IconButton(
        icon: Icon(
          _hasVoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
          color: _hasVoted ? AppColors.lime : Colors.white),
        onPressed: _voting ? null : _vote,
      ),
    ],
  );

  Widget _buildBody(AuthProvider auth) {
    final r = _report!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              SeverityBadge(severity: r.severity),
              StatusBadge(status: r.status),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text('${r.typeEmoji} ${r.typeLabel}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textMd)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(r.title,
            style: GoogleFonts.syne(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: AppColors.textDk, height: 1.2)),
          const SizedBox(height: 12),

          // Meta
          _MetaRow(icon: Icons.person_rounded,
            text: r.user?.name ?? 'Anonim'),
          if (r.locationText != null)
            _MetaRow(icon: Icons.location_on_rounded, text: r.locationText!),
          _MetaRow(icon: Icons.calendar_today_rounded,
            text: _fmt(r.createdAt)),
          _MetaRow(icon: Icons.thumb_up_rounded,
            text: '${r.upvotes} dukungan'),

          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),

          // Description
          Text('Deskripsi',
            style: GoogleFonts.syne(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDk)),
          const SizedBox(height: 8),
          Text(r.description ?? 'Tidak ada deskripsi.',
            style: GoogleFonts.dmSans(
              fontSize: 14, color: AppColors.textMd, height: 1.85)),

          // Stats
          if (r.areaAffected != null || r.treesLost != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (r.areaAffected != null)
                  Expanded(child: _StatBox(
                    label: 'Luas Terdampak',
                    value: '${r.areaAffected!.toStringAsFixed(1)} ha',
                    color: AppColors.warning,
                  )),
                if (r.areaAffected != null && r.treesLost != null)
                  const SizedBox(width: 12),
                if (r.treesLost != null)
                  Expanded(child: _StatBox(
                    label: 'Pohon Hilang',
                    value: '${r.treesLost}',
                    color: AppColors.error,
                  )),
              ],
            ),
          ],

          // Admin notes
          if (r.adminNotes != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.admin_panel_settings_rounded,
                      size: 14, color: AppColors.info),
                    const SizedBox(width: 6),
                    Text('Catatan Admin',
                      style: GoogleFonts.dmSans(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.info)),
                  ]),
                  const SizedBox(height: 8),
                  Text(r.adminNotes!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.textMd, height: 1.6)),
                ],
              ),
            ),
          ],

          // Vote button
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _voting ? null : _vote,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _hasVoted ? AppColors.lime : AppColors.offWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hasVoted ? AppColors.lime : AppColors.border, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _hasVoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                    size: 18,
                    color: _hasVoted ? AppColors.textDk : AppColors.textMd),
                  const SizedBox(width: 8),
                  Text(
                    _hasVoted ? 'Sudah Didukung (${r.upvotes})' : 'Dukung Laporan (${r.upvotes})',
                    style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: _hasVoted ? AppColors.textDk : AppColors.textMd)),
                ],
              ),
            ),
          ),

          // Comments
          const SizedBox(height: 28),
          Text('Komentar (${r.comments.length})',
            style: GoogleFonts.syne(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDk)),
          const SizedBox(height: 12),

          // Comment input
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  maxLines: 3, minLines: 1,
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textDk),
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 14, color: AppColors.textLt),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.greenMd, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _submitting ? null : _submitComment,
                child: Container(
                  width: 46, height: 46,
                  decoration: const BoxDecoration(
                    color: AppColors.lime, shape: BoxShape.circle),
                  child: _submitting
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.textDk))
                      : const Icon(Icons.send_rounded,
                          size: 20, color: AppColors.textDk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comment list
          ...r.comments.map((c) => _CommentCard(
            comment: c,
            canDelete: auth.isAuth &&
                (auth.user?.id == c.userId || auth.isAdmin),
            onDelete: () => _deleteComment(c.id),
          )),
          const SizedBox(height: 80),
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

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(icon, size: 13, color: AppColors.greenMd),
        const SizedBox(width: 6),
        Expanded(child: Text(text,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMd))),
      ],
    ),
  );
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: GoogleFonts.dmSans(
            fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value,
          style: GoogleFonts.syne(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDk)),
      ],
    ),
  );
}

class _CommentCard extends StatelessWidget {
  final ReportComment comment;
  final bool canDelete;
  final VoidCallback onDelete;
  const _CommentCard({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.greenMd.withOpacity(0.15),
          child: Text(
            (comment.user?.name ?? 'A')[0].toUpperCase(),
            style: GoogleFonts.syne(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.greenMd)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(comment.user?.name ?? 'Anonim',
                    style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textDk)),
                  Text(_fmt(comment.createdAt),
                    style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.textLt)),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.body,
                style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textMd, height: 1.6)),
            ],
          ),
        ),
        if (canDelete)
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.delete_outline_rounded,
                size: 16, color: AppColors.error),
            ),
          ),
      ],
    ),
  );

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','Mei','Jun',
                'Jul','Ags','Sep','Okt','Nov','Des'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
