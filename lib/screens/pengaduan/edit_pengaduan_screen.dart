// lib/screens/pengaduan/edit_pengaduan_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme_config.dart';
import '../../services/api_service.dart';
import '../../models/item.dart';
import '../../models/pengaduan.dart';
import '../../widgets/custom_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditPengaduanScreen extends StatefulWidget {
  final Pengaduan pengaduan;

  const EditPengaduanScreen({
    super.key,
    required this.pengaduan,
  });

  @override
  State<EditPengaduanScreen> createState() => _EditPengaduanScreenState();
}

class _EditPengaduanScreenState extends State<EditPengaduanScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _namaPengaduanController;
  late TextEditingController _deskripsiController;
  late TextEditingController _lokasiController;

  List<Item> _items = [];
  Item? _selectedItem;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  bool _isLoadingItems = true;

  @override
  void initState() {
    super.initState();
    
    _namaPengaduanController = TextEditingController(text: widget.pengaduan.namaPengaduan);
    _deskripsiController = TextEditingController(text: widget.pengaduan.deskripsi);
    _lokasiController = TextEditingController(text: widget.pengaduan.lokasi);
    _existingImageUrl = widget.pengaduan.foto;

    _loadItems();
  }

  @override
  void dispose() {
    _namaPengaduanController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final items = await _apiService.getItems();
      setState(() {
        _items = items;
        // Set selected item berdasarkan pengaduan
        if (widget.pengaduan.item != null) {
          _selectedItem = items.firstWhere(
            (item) => item.idItem == widget.pengaduan.item!.idItem,
            orElse: () => items.first,
          );
        }
        _isLoadingItems = false;
      });
    } catch (e) {
      setState(() => _isLoadingItems = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat item: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePengaduan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih item terlebih dahulu'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.updatePengaduan(
        id: widget.pengaduan.idPengaduan,
        namaPengaduan: _namaPengaduanController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        idItem: _selectedItem!.idItem,
        foto: _selectedImage,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaduan berhasil diupdate'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update pengaduan: $e'),
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
        title: const Text('Edit Pengaduan'),
      ),
      body: _isLoadingItems
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker
                    InkWell(
                      onTap: _showImageSourceDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderColor,
                            width: 2,
                          ),
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = null;
                                        });
                                      },
                                      icon: const Icon(Icons.close),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.black54,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: _existingImageUrl!,
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: IconButton(
                                          onPressed: _showImageSourceDialog,
                                          icon: const Icon(Icons.edit),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.black54,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 48,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tambah Foto (Opsional)',
                                        style: TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nama Pengaduan
                    CustomTextField(
                      controller: _namaPengaduanController,
                      label: 'Nama Pengaduan',
                      prefixIcon: Icons.report_problem,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama pengaduan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Lokasi
                    CustomTextField(
                      controller: _lokasiController,
                      label: 'Lokasi',
                      prefixIcon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Item Dropdown
                    DropdownButtonFormField<Item>(
                      value: _selectedItem,
                      decoration: InputDecoration(
                        labelText: 'Item',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _items.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item.namaItem),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedItem = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih item';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Update Button
                    CustomButton(
                      text: 'Update Pengaduan',
                      onPressed: _updatePengaduan,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}