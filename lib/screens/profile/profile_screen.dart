// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme_config.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text('User tidak ditemukan'));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar dengan Profile Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Profile Image
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          backgroundImage: user.fotoProfil != null &&
                                  user.fotoProfil!.isNotEmpty
                              ? CachedNetworkImageProvider(user.fotoProfil!)
                              : null,
                          child: user.fotoProfil == null ||
                                  user.fotoProfil!.isEmpty
                              ? Text(
                                  user.namaPengguna[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          user.namaPengguna,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Username
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Bio Section (if exists)
                if (user.bio != null && user.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Bio',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.bio!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Info Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.email,
                        title: 'Username',
                        value: user.username,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.phone,
                        title: 'No. Telepon',
                        value: user.telpUser ?? 'Belum diatur',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.verified_user,
                        title: 'Role',
                        value: user.role.toUpperCase(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Menu List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        icon: Icons.edit,
                        title: 'Edit Profil',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.lock,
                        title: 'Ubah Password',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.info,
                        title: 'Tentang Aplikasi',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Sipras',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(
                              Icons.build_circle,
                              size: 48,
                              color: AppTheme.primaryColor,
                            ),
                            children: const [
                              Text('Sistem Pengaduan Sarana dan Prasarana'),
                            ],
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.logout,
                        title: 'Keluar',
                        textColor: AppTheme.errorColor,
                        onTap: () => _handleLogout(authService),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(AuthService authService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await authService.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
