// lib/screens/pengaduan/pengaduan_detail_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../models/pengaduan.dart';
import '../../services/api_service.dart';
import 'edit_pengaduan_screen.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PengaduanDetailScreen extends StatefulWidget {
  final Pengaduan pengaduan;

  const PengaduanDetailScreen({
    super.key,
    required this.pengaduan,
  });

  @override
  State<PengaduanDetailScreen> createState() => _PengaduanDetailScreenState();
}

class _PengaduanDetailScreenState extends State<PengaduanDetailScreen> {
  final ApiService _apiService = ApiService();
  late Pengaduan _pengaduan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pengaduan = widget.pengaduan;
    _refreshPengaduan();
  }

  Future<void> _refreshPengaduan() async {
    try {
      final updated =
          await _apiService.getPengaduanDetail(_pengaduan.idPengaduan);
      setState(() {
        _pengaduan = updated;
      });
    } catch (e) {
      // Silently fail, use existing data
    }
  }

  Future<void> _deletePengaduan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengaduan'),
        content: const Text('Apakah Anda yakin ingin menghapus pengaduan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.deletePengaduan(_pengaduan.idPengaduan);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaduan berhasil dihapus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal hapus pengaduan: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getStatusColor(_pengaduan.status);
    final canEdit = _pengaduan.status == 'Diajukan';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
        actions: canEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditPengaduanScreen(pengaduan: _pengaduan),
                      ),
                    ).then((result) {
                      if (result == true) {
                        _refreshPengaduan();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isLoading ? null : _deletePengaduan,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image (if exists)
                  if (_pengaduan.foto != null && _pengaduan.foto!.isNotEmpty)
                    Image.network(
                      _pengaduan.foto!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 250,
                          color: Colors.grey[200],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Gambar tidak dapat dimuat',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.getStatusBackgroundColor(
                                _pengaduan.status),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            _pengaduan.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          _pengaduan.namaPengaduan,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info Cards
                        _buildInfoCard(
                          Icons.location_on,
                          'Lokasi',
                          _pengaduan.lokasi,
                        ),
                        const SizedBox(height: 12),

                        if (_pengaduan.item != null)
                          _buildInfoCard(
                            Icons.category,
                            'Item',
                            _pengaduan.item!.namaItem,
                          ),
                        const SizedBox(height: 12),

                        _buildInfoCard(
                          Icons.calendar_today,
                          'Tanggal Pengajuan',
                          DateFormat('dd MMMM yyyy, HH:mm')
                              .format(_pengaduan.tglPengajuan),
                        ),
                        const SizedBox(height: 24),

                        // Description Section
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _pengaduan.deskripsi,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),

                        // Admin Note (if exists)
                        if (_pengaduan.catatanAdmin != null &&
                            _pengaduan.catatanAdmin!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Catatan Admin',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.infoColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    AppTheme.infoColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info,
                                  color: AppTheme.infoColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _pengaduan.catatanAdmin!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Petugas Note (if exists)
                        if (_pengaduan.saranPetugas != null &&
                            _pengaduan.saranPetugas!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Saran Petugas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    AppTheme.accentColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.support_agent,
                                  color: AppTheme.accentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _pengaduan.saranPetugas!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Petugas Info (if exists)
                        if (_pengaduan.petugas != null) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Petugas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoCard(
                            Icons.person,
                            'Nama Petugas',
                            _pengaduan.petugas!.namaPetugas ??
                                'Belum ditentukan',
                          ),
                        ],

                        // Dates
                        const SizedBox(height: 24),
                        const Text(
                          'Timeline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (_pengaduan.tglVerifikasi != null)
                          _buildTimelineItem(
                            'Diverifikasi',
                            DateFormat('dd MMMM yyyy, HH:mm')
                                .format(_pengaduan.tglVerifikasi!),
                            AppTheme.infoColor,
                          ),

                        if (_pengaduan.tglSelesai != null)
                          _buildTimelineItem(
                            'Selesai',
                            DateFormat('dd MMMM yyyy, HH:mm')
                                .format(_pengaduan.tglSelesai!),
                            AppTheme.successColor,
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
