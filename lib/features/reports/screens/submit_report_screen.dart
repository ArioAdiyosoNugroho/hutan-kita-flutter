import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // ✅ tambah ini
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/app_button.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});
  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _api          = ApiService();
  final _picker       = ImagePicker();
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _latCtrl      = TextEditingController();
  final _lngCtrl      = TextEditingController();
  final _areaCtrl     = TextEditingController();
  final _treesCtrl    = TextEditingController();

  String?     _reportType;
  String?     _severity = 'medium';
  File?       _photo;        // mobile
  Uint8List?  _photoBytes;   // ✅ web
  String?     _photoName;    // ✅ web
  bool        _loading = false;
  String?     _error;

  static const _types = {
    'sawit_expansion': '🌴 Ekspansi Sawit',
    'illegal_logging': '🪓 Penebangan Liar',
    'forest_fire':     '🔥 Kebakaran Hutan',
    'land_clearing':   '🚜 Pembukaan Lahan',
    'mining':          '⛏️ Pertambangan',
    'other':           '📍 Lainnya',
  };

  static const _severities = {
    'low':      'Rendah',
    'medium':   'Sedang',
    'high':     'Tinggi',
    'critical': 'Kritis',
  };

  bool get _hasPhoto => kIsWeb ? _photoBytes != null : _photo != null;

  Future<void> _pickPhoto() async {
    // Web tidak support kamera, langsung galeri
    if (kIsWeb) {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (img != null && mounted) {
        final bytes = await img.readAsBytes();
        setState(() {
          _photoBytes = bytes;
          _photoName  = img.name;
        });
      }
      return;
    }

    // Mobile: tampilkan pilihan kamera / galeri
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.14),
                borderRadius: BorderRadius.circular(99)),
            ),
            Text('Tambah Foto Bukti',
              style: GoogleFonts.syne(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.textDk)),
            const SizedBox(height: 20),
            Row(
              children: [
                // Kamera
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (!mounted) return;
                      final img = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                        maxWidth: 1280,
                      );
                      if (img != null && mounted) {
                        setState(() => _photo = File(img.path));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.green.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 26),
                          ),
                          const SizedBox(height: 10),
                          Text('Kamera',
                            style: GoogleFonts.dmSans(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.textDk)),
                          const SizedBox(height: 2),
                          Text('Foto langsung',
                            style: GoogleFonts.dmSans(
                              fontSize: 11, color: AppColors.textLt)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Galeri
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (!mounted) return;
                      final img = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                        maxWidth: 1280,
                      );
                      if (img != null && mounted) {
                        setState(() => _photo = File(img.path));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.textLt.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.photo_library_rounded,
                              color: AppColors.textMd, size: 26),
                          ),
                          const SizedBox(height: 10),
                          Text('Galeri',
                            style: GoogleFonts.dmSans(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.textDk)),
                          const SizedBox(height: 2),
                          Text('Pilih dari galeri',
                            style: GoogleFonts.dmSans(
                              fontSize: 11, color: AppColors.textLt)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text('Batal',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.textLt)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget preview foto (support web & mobile) ────────────────────────────
  Widget _buildPhotoPreview() {
    Widget imageWidget;

    if (kIsWeb && _photoBytes != null) {
      imageWidget = Image.memory(_photoBytes!, fit: BoxFit.cover);
    } else if (!kIsWeb && _photo != null) {
      imageWidget = Image.file(_photo!, fit: BoxFit.cover);
    } else {
      imageWidget = const SizedBox();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        Positioned(
          top: 8, right: 8,
          child: GestureDetector(
            onTap: () => setState(() {
              _photo      = null;
              _photoBytes = null;
              _photoName  = null;
            }),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Judul wajib diisi'); return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Deskripsi wajib diisi'); return;
    }
    if (_latCtrl.text.trim().isEmpty || _lngCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Koordinat wajib diisi'); return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      MultipartFile? photoFile;

      if (kIsWeb && _photoBytes != null) {
        // ✅ Web: pakai bytes
        photoFile = MultipartFile.fromBytes(
          _photoBytes!, filename: _photoName ?? 'photo.jpg');
      } else if (!kIsWeb && _photo != null) {
        // ✅ Mobile: pakai file path
        photoFile = await MultipartFile.fromFile(
          _photo!.path, filename: 'photo.jpg');
      }

      final formData = FormData.fromMap({
        'title':         _titleCtrl.text.trim(),
        'description':   _descCtrl.text.trim(),
        'lat':           _latCtrl.text.trim(),
        'lng':           _lngCtrl.text.trim(),
        'location_text': _locationCtrl.text.trim(),
        if (_reportType != null) 'report_type': _reportType,
        'severity':      _severity ?? 'medium',
        if (_areaCtrl.text.isNotEmpty) 'area_affected': _areaCtrl.text.trim(),
        if (_treesCtrl.text.isNotEmpty) 'trees_lost': _treesCtrl.text.trim(),
        if (photoFile != null) 'photo': photoFile,
      });

      await _api.createReport(formData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Laporan berhasil dikirim!'),
            backgroundColor: AppColors.greenMd));
        context.pop();
      }
    } catch (e) {
      setState(() => _error = 'Gagal mengirim laporan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: Text('Buat Laporan',
          style: GoogleFonts.syne(
            fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded,
                    size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.error))),
                ]),
              ),

            // ── Photo Upload ──────────────────────────────────────────
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 180, width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hasPhoto ? AppColors.greenMd : AppColors.border,
                    width: _hasPhoto ? 2 : 1.5),
                ),
                clipBehavior: Clip.hardEdge,
                // ✅ pakai _hasPhoto dan _buildPhotoPreview
                child: _hasPhoto
                    ? _buildPhotoPreview()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_photo_alternate_outlined,
                              size: 28, color: AppColors.textLt),
                          ),
                          const SizedBox(height: 10),
                          Text('Tambah Foto Bukti',
                            style: GoogleFonts.dmSans(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.textMd)),
                          Text(
                            kIsWeb
                                ? 'Opsional — Tap untuk memilih dari galeri'
                                : 'Opsional — Tap untuk kamera / galeri',
                            style: GoogleFonts.dmSans(
                              fontSize: 12, color: AppColors.textLt)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            _buildCard(children: [
              _label('Judul Laporan *'),
              const SizedBox(height: 8),
              _Input(controller: _titleCtrl, hint: 'Contoh: Penebangan liar di area X'),
              const SizedBox(height: 16),
              _label('Deskripsi *'),
              const SizedBox(height: 8),
              _Input(controller: _descCtrl,
                hint: 'Jelaskan situasi secara detail...', maxLines: 4),
            ]),
            const SizedBox(height: 14),

            _buildCard(children: [
              _label('Jenis Ancaman'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _types.entries.map((e) {
                  final active = _reportType == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _reportType = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.green : AppColors.offWhite,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: active ? AppColors.green : AppColors.border,
                          width: 1.5),
                      ),
                      child: Text(e.value,
                        style: GoogleFonts.dmSans(
                          fontSize: 12.5, fontWeight: FontWeight.w500,
                          color: active ? Colors.white : AppColors.textMd)),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 14),

            _buildCard(children: [
              _label('Tingkat Keparahan'),
              const SizedBox(height: 10),
              Row(
                children: _severities.entries.map((e) {
                  final active = _severity == e.key;
                  final color  = AppColors.severityColor(e.key);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _severity = e.key),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? color : AppColors.offWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active ? color : AppColors.border,
                            width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                color: active ? Colors.white : color,
                                shape: BoxShape.circle),
                            ),
                            const SizedBox(height: 4),
                            Text(e.value,
                              style: GoogleFonts.dmSans(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: active ? Colors.white : AppColors.textMd),
                              textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 14),

            _buildCard(children: [
              _label('Lokasi'),
              const SizedBox(height: 8),
              _Input(controller: _locationCtrl,
                hint: 'Nama lokasi (desa, kecamatan, dll)'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _Input(controller: _latCtrl,
                  hint: 'Latitude',
                  keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _Input(controller: _lngCtrl,
                  hint: 'Longitude',
                  keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 6),
              Text('Buka Google Maps untuk mendapatkan koordinat.',
                style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.textLt)),
            ]),
            const SizedBox(height: 14),

            _buildCard(children: [
              _label('Data Kerusakan (Opsional)'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Luas Terdampak (ha)'),
                    const SizedBox(height: 6),
                    _Input(controller: _areaCtrl, hint: 'Mis. 10.5',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true)),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Pohon Hilang'),
                    const SizedBox(height: 6),
                    _Input(controller: _treesCtrl, hint: 'Mis. 200',
                      keyboardType: TextInputType.number),
                  ],
                )),
              ]),
            ]),
            const SizedBox(height: 24),

            AppButton(
              label: 'Kirim Laporan',
              loading: _loading,
              onTap: _submit,
              width: double.infinity,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _label(String text) => Text(text,
    style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDk));
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Input({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
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