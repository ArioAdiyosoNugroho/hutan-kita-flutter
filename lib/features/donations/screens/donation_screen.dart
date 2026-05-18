import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/donation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});
  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _api         = ApiService();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _msgCtrl     = TextEditingController();

  DonationSummary? _summary;
  int    _amount  = 25000;
  bool   _loading = false;
  bool   _loadingSum = true;
  String? _error;

  static const _presets = [5000, 10000, 25000, 50000, 100000, 250000];

  @override
  void initState() {
    super.initState();
    _fetchSummary();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuth && auth.user != null) {
      _nameCtrl.text  = auth.user!.name;
      _emailCtrl.text = auth.user!.email;
    }
  }

  Future<void> _fetchSummary() async {
    try {
      final res = await _api.getDonationSummary();
      if (mounted) setState(() {
        _summary = DonationSummary.fromJson(res.data);
        _loadingSum = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingSum = false);
    }
  }

  int get _trees => (_amount / 5000).floor();

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuth) { context.push('/login'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.createDonationOrder({
        'amount':        _amount,
        'donor_name':    _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        'donor_email':   _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'donor_message': _msgCtrl.text.trim().isEmpty  ? null : _msgCtrl.text.trim(),
      });
      final checkoutUrl = res.data['checkout_url'] as String?;
      if (checkoutUrl != null && await canLaunchUrl(Uri.parse(checkoutUrl))) {
        await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
      } else {
        setState(() => _error = 'Gagal membuka halaman pembayaran');
      }
    } catch (_) {
      setState(() => _error = 'Gagal membuat donasi. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.green,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.green,
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min, // ✅ tambah ini
                  children: [
                    Text('DONASI POHON',
                      style: GoogleFonts.dmSans(
                        fontSize: 10, color: AppColors.lime,
                        fontWeight: FontWeight.w600, letterSpacing: 2)),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.syne(
                          fontSize: 24, // ✅ kecilkan dari 28 → 24
                          fontWeight: FontWeight.w800,
                          color: Colors.white, height: 1.1),
                        children: const [
                          TextSpan(text: 'Rp 5.000 = 1 Pohon\n'),
                          TextSpan(text: 'di Lahan Nyata',
                            style: TextStyle(color: AppColors.lime)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Stats bar
                _buildSummaryBar(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error.withOpacity(0.2)),
                          ),
                          child: Text(_error!,
                            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.error)),
                        ),

                      // Amount selection
                      _buildCard(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pilih Nominal',
                              style: GoogleFonts.syne(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: AppColors.textDk)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.lime,
                                borderRadius: BorderRadius.circular(99)),
                              child: Text('🌱 $_trees pohon',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: AppColors.textDk)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 3, shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 8, mainAxisSpacing: 8,
                          childAspectRatio: 2.2,
                          children: _presets.map((amt) {
                            final active = _amount == amt;
                            return GestureDetector(
                              onTap: () => setState(() => _amount = amt),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: active ? AppColors.green : AppColors.offWhite,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: active ? AppColors.green : AppColors.border,
                                    width: 1.5),
                                ),
                                child: Text(_fmtAmt(amt),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.5, fontWeight: FontWeight.w600,
                                    color: active ? Colors.white : AppColors.textDk),
                                  textAlign: TextAlign.center),
                              ),
                            );
                          }).toList(),
                        ),
                      ]),
                      const SizedBox(height: 14),

                      // Donor info
                      _buildCard(children: [
                        Text('Informasi Donatur',
                          style: GoogleFonts.syne(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: AppColors.textDk)),
                        const SizedBox(height: 14),
                        _lbl('Nama'),
                        const SizedBox(height: 6),
                        _Inp(controller: _nameCtrl, hint: 'Nama lengkap (opsional)'),
                        const SizedBox(height: 12),
                        _lbl('Email'),
                        const SizedBox(height: 6),
                        _Inp(controller: _emailCtrl, hint: 'Email (opsional)',
                          type: TextInputType.emailAddress),
                        const SizedBox(height: 12),
                        _lbl('Pesan (Opsional)'),
                        const SizedBox(height: 6),
                        _Inp(controller: _msgCtrl,
                          hint: 'Pesan penyemangat untuk relawan...', maxLines: 3),
                      ]),
                      const SizedBox(height: 14),

                      // Summary
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Donasi',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12, color: Colors.white.withOpacity(0.55))),
                                Text(_fmtAmt(_amount),
                                  style: GoogleFonts.syne(
                                    fontSize: 26, fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Setara dengan',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12, color: Colors.white.withOpacity(0.55))),
                                Text('$_trees Pohon 🌱',
                                  style: GoogleFonts.syne(
                                    fontSize: 22, fontWeight: FontWeight.w700,
                                    color: AppColors.lime)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      AppButton(
                        label: 'Lanjut ke Pembayaran',
                        loading: _loading,
                        onTap: _submit,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 12),

                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/leaderboard'),
                          child: Text('Lihat Papan Peringkat Donatur →',
                            style: GoogleFonts.dmSans(
                              fontSize: 13, color: AppColors.greenMd,
                              fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    child: _loadingSum
        ? const ShimmerBox(height: 48, radius: 8)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SumItem(
                label: 'Pohon Ditanam',
                value: '${_summary?.totalTreesPlanted ?? 0}',
                icon: '🌱'),
              _div(),
              _SumItem(
                label: 'Total Donatur',
                value: '${_summary?.totalDonors ?? 0}',
                icon: '👥'),
              _div(),
              _SumItem(
                label: 'Total Donasi',
                value: '${_summary?.totalDonations ?? 0}×',
                icon: '💚'),
            ],
          ),
  );

  Widget _div() => Container(width: 1, height: 32, color: AppColors.border);

  Widget _buildCard({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _lbl(String t) => Text(t,
    style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDk));

  String _fmtAmt(int amt) {
    if (amt >= 1000000) return 'Rp ${(amt / 1000000).toStringAsFixed(1)}jt';
    if (amt >= 1000)    return 'Rp ${(amt / 1000).round()}rb';
    return 'Rp $amt';
  }
}

class _SumItem extends StatelessWidget {
  final String label, value, icon;
  const _SumItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(value,
        style: GoogleFonts.syne(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDk)),
      Text(label,
        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textLt)),
    ],
  );
}

class _Inp extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? type;
  const _Inp({required this.controller, required this.hint,
    this.maxLines = 1, this.type});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, maxLines: maxLines, keyboardType: type,
    style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textDk),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textLt),
      filled: true, fillColor: AppColors.offWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.greenMd, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    ),
  );
}
