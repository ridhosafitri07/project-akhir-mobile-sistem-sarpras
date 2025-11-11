// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/pengaduan.dart';
import '../pengaduan/create_pengaduan_screen.dart';
import '../pengaduan/pengaduan_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToPengaduan;

  const HomeScreen({super.key, this.onNavigateToPengaduan});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Pengaduan> _recentPengaduans = [];
  bool _isLoading = true;
  int _totalPengaduan = 0;
  int _pendingCount = 0;
  int _disetujuiCount = 0;
  int _prosesCount = 0;
  int _selesaiCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final pengaduans = await _apiService.getPengaduans();

      setState(() {
        _recentPengaduans = pengaduans.take(5).toList();
        _totalPengaduan = pengaduans.length;
        _pendingCount = pengaduans.where((p) => p.status == 'Diajukan').length;
        _disetujuiCount =
            pengaduans.where((p) => p.status == 'Disetujui').length;
        _prosesCount = pengaduans.where((p) => p.status == 'Diproses').length;
        _selesaiCount = pengaduans.where((p) => p.status == 'Selesai').length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.namaPengguna ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Statistics Cards
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistik Pengaduan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total',
                                  _totalPengaduan.toString(),
                                  Icons.assignment,
                                  AppTheme.infoColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Pending',
                                  _pendingCount.toString(),
                                  Icons.hourglass_empty,
                                  AppTheme.warningColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Disetujui',
                                  _disetujuiCount.toString(),
                                  Icons.thumb_up,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Proses',
                                  _prosesCount.toString(),
                                  Icons.sync,
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Selesai',
                                  _selesaiCount.toString(),
                                  Icons.check_circle,
                                  AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aksi Cepat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 100,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildQuickActionCard(
                                  'Buat Pengaduan',
                                  Icons.add_circle,
                                  AppTheme.accentColor,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CreatePengaduanScreen(),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildQuickActionCard(
                                  'Lihat Semua',
                                  Icons.list_alt,
                                  AppTheme.primaryColor,
                                  () {
                                    // Navigate to pengaduan list screen
                                    widget.onNavigateToPengaduan?.call();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent Pengaduans
                    if (_recentPengaduans.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pengaduan Terbaru',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _recentPengaduans.length,
                              itemBuilder: (context, index) {
                                final pengaduan = _recentPengaduans[index];
                                return _buildPengaduanCard(pengaduan);
                              },
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pengaduan.namaPengaduan,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.getStatusBackgroundColor(pengaduan.status),
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
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppTheme.textSecondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    pengaduan.lokasi,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
      ),
    );
  }
}
