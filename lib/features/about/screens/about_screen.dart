import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _stats = [
    {'icon': '🌿', 'val': '1,200+', 'label': 'Laporan Diterima'},
    {'icon': '🌳', 'val': '5,400+', 'label': 'Pohon Ditanam'},
    {'icon': '👥', 'val': '320+',   'label': 'Relawan Aktif'},
    {'icon': '📍', 'val': '15',     'label': 'Provinsi Terpantau'},
  ];

  static const _missions = [
    {
      'icon': '🔍',
      'title': 'Pantau Nyata',
      'desc': 'Sistem pelaporan berbasis komunitas untuk mendeteksi deforestasi lebih awal.',
    },
    {
      'icon': '🗺️',
      'title': 'Peta Ancaman',
      'desc': 'Visualisasi titik-titik rawan kerusakan hutan secara real-time di seluruh Indonesia.',
    },
    {
      'icon': '🌱',
      'title': 'Restorasi Aktif',
      'desc': 'Setiap donasi langsung digunakan untuk menanam pohon di lahan terdegradasi.',
    },
    {
      'icon': '📊',
      'title': 'Transparansi Data',
      'desc': 'Semua laporan dan donasi tercatat publik untuk akuntabilitas penuh.',
    },
  ];

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
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=700&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: AppColors.greenMd),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        AppColors.green.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Tentang HutanKita',
                        style: GoogleFonts.syne(
                          fontSize: 28, fontWeight: FontWeight.w800,
                          color: Colors.white, height: 1.1)),
                      const SizedBox(height: 6),
                      Text('Platform pemantauan hutan berbasis komunitas',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.65))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  crossAxisSpacing: 12, mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: _stats.map((s) => _StatCard(
                    icon: s['icon']!, val: s['val']!, label: s['label']!)).toList(),
                ),
              ),

              // Mission
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Misi Kami',
                      style: GoogleFonts.syne(
                        fontSize: 24, fontWeight: FontWeight.w700,
                        color: AppColors.textDk, letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Text('Empat pilar gerakan HutanKita',
                      style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.textLt)),
                    const SizedBox(height: 20),
                    ..._missions.map((m) => _MissionCard(
                      icon: m['icon']!, title: m['title']!, desc: m['desc']!)),
                  ],
                ),
              ),

              // About text
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Digerakkan Data,\nDipandu Komunitas',
                      style: GoogleFonts.syne(
                        fontSize: 24, fontWeight: FontWeight.w700,
                        color: AppColors.textDk, height: 1.2)),
                    const SizedBox(height: 16),
                    Text(
                      'HutanKita adalah jaringan intelijen publik yang menghubungkan masyarakat, aktivis, dan pengambil kebijakan untuk aksi nyata menjaga hutan Indonesia.',
                      style: GoogleFonts.dmSans(
                        fontSize: 15, color: AppColors.textMd, height: 1.8)),
                    const SizedBox(height: 12),
                    Text(
                      'Setiap laporan yang masuk diverifikasi oleh tim kami dan dipetakan secara transparan. Kami percaya bahwa informasi yang akurat adalah kunci untuk melindungi 125 juta hektar hutan tropis Indonesia.',
                      style: GoogleFonts.dmSans(
                        fontSize: 15, color: AppColors.textMd, height: 1.8)),
                    const SizedBox(height: 20),
                    // Tags
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: ['Transparan', 'Aksi Nyata', 'Berbasis Data', 'Komunitas',
                                 'Open Source', 'Terverifikasi']
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.lime,
                                  borderRadius: BorderRadius.circular(99)),
                                child: Text(t,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: AppColors.textDk)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // CTA
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bergabunglah\nBersama Kami',
                        style: GoogleFonts.syne(
                          fontSize: 26, fontWeight: FontWeight.w700,
                          color: Colors.white, height: 1.15)),
                      const SizedBox(height: 10),
                      Text('Setiap laporan dan donasi membuat perbedaan nyata bagi hutan Indonesia.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.55), height: 1.7)),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: AppButton(
                          label: 'Laporkan',
                          onTap: () => context.push('/submit-report'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: AppButtonDark(
                          label: 'Donasi',
                          onTap: () => context.go('/donate'),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String icon, val, label;
  const _StatCard({required this.icon, required this.val, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.offWhite,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(val,
                style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDk)),
              Text(label,
                style: GoogleFonts.dmSans(
                  fontSize: 10, color: AppColors.textLt),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
  );
}
class _MissionCard extends StatelessWidget {
  final String icon, title, desc;
  const _MissionCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: GoogleFonts.syne(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.textDk)),
              const SizedBox(height: 4),
              Text(desc,
                style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textMd, height: 1.6)),
            ],
          ),
        ),
      ],
    ),
  );
}
