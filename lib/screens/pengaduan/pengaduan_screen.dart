// lib/screens/pengaduan/pengaduan_list_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../services/api_service.dart';
import '../../models/pengaduan.dart';
import 'pengaduan_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PengaduanScreen extends StatefulWidget {
  const PengaduanScreen({super.key});

  @override
  State<PengaduanScreen> createState() => _PengaduanScreenState();
}

class _PengaduanScreenState extends State<PengaduanScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<Pengaduan> _allPengaduans = [];
  List<Pengaduan> _filteredPengaduans = [];
  bool _isLoading = true;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadPengaduans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _currentFilter = 'all';
            _filteredPengaduans = _allPengaduans;
            break;
          case 1:
            _currentFilter = 'pending';
            _filteredPengaduans =
                _allPengaduans.where((p) => p.status == 'Diajukan').toList();
            break;
          case 2:
            _currentFilter = 'disetujui';
            _filteredPengaduans =
                _allPengaduans.where((p) => p.status == 'Disetujui').toList();
            break;
          case 3:
            _currentFilter = 'proses';
            _filteredPengaduans =
                _allPengaduans.where((p) => p.status == 'Diproses').toList();
            break;
          case 4:
            _currentFilter = 'selesai';
            _filteredPengaduans =
                _allPengaduans.where((p) => p.status == 'Selesai').toList();
            break;
          case 5:
            _currentFilter = 'ditolak';
            _filteredPengaduans =
                _allPengaduans.where((p) => p.status == 'Ditolak').toList();
            break;
        }
      });
    }
  }

  Future<void> _loadPengaduans() async {
    setState(() => _isLoading = true);

    try {
      final pengaduans = await _apiService.getPengaduans();

      setState(() {
        _allPengaduans = pengaduans;
        _filteredPengaduans = pengaduans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pengaduan: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengaduan'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pending'),
            Tab(text: 'Disetujui'),
            Tab(text: 'Proses'),
            Tab(text: 'Selesai'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPengaduans,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredPengaduans.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPengaduans.length,
                    itemBuilder: (context, index) {
                      return _buildPengaduanCard(_filteredPengaduans[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pengaduan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyMessage(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_currentFilter) {
      case 'pending':
        return 'Tidak ada pengaduan yang menunggu';
      case 'disetujui':
        return 'Tidak ada pengaduan yang disetujui';
      case 'proses':
        return 'Tidak ada pengaduan yang sedang diproses';
      case 'selesai':
        return 'Tidak ada pengaduan yang selesai';
      case 'ditolak':
        return 'Tidak ada pengaduan yang ditolak';
      default:
        return 'Belum ada pengaduan yang dibuat';
    }
  }

  Widget _buildPengaduanCard(Pengaduan pengaduan) {
    final statusColor = AppTheme.getStatusColor(pengaduan.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PengaduanDetailScreen(pengaduan: pengaduan),
            ),
          ).then((_) => _loadPengaduans());
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (if exists)
            if (pengaduan.foto != null && pengaduan.foto!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Builder(
                  builder: (context) {
                    print('Image URL: ${pengaduan.foto}');
                    return Image.network(
                      pengaduan.foto!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Image Error: $error');
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Gambar tidak dapat dimuat',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          pengaduan.namaPengaduan,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.getStatusBackgroundColor(
                              pengaduan.status),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          pengaduan.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    pengaduan.deskripsi,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Location and Item
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppTheme.textSecondaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pengaduan.lokasi,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (pengaduan.item != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.category,
                            size: 16, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          pengaduan.item!.namaItem,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: AppTheme.textSecondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm')
                            .format(pengaduan.tglPengajuan),
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
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
}
