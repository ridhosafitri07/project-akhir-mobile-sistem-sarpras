// lib/screens/pengaduan/create_pengaduan_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme_config.dart';
import '../../services/api_service.dart';
import '../../models/item.dart';
import '../../widgets/custom_widget.dart';

class CreatePengaduanScreen extends StatefulWidget {
  const CreatePengaduanScreen({super.key});

  @override
  State<CreatePengaduanScreen> createState() => _CreatePengaduanScreenState();
}

class _CreatePengaduanScreenState extends State<CreatePengaduanScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  final _namaPengaduanController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();

  List<Item> _items = [];
  Item? _selectedItem;
  File? _selectedImage;
  XFile? _selectedImageWeb;
  bool _isLoading = false;
  bool _isLoadingItems = true;

  @override
  void initState() {
    super.initState();
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
        if (kIsWeb) {
          _selectedImageWeb = image;
        } else {
          _selectedImage = File(image.path);
        }
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
        if (kIsWeb) {
          _selectedImageWeb = image;
        } else {
          _selectedImage = File(image.path);
        }
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (!kIsWeb) // Kamera tidak tersedia di web
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

  Future<void> _submitPengaduan() async {
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
      await _apiService.createPengaduan(
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
            content: Text('Pengaduan berhasil dibuat'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pengaduan: $e'),
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
        title: const Text('Buat Pengaduan'),
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
                        child: (_selectedImage == null &&
                                _selectedImageWeb == null)
                            ? const Column(
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
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb && _selectedImageWeb != null
                                        ? Image.network(
                                            _selectedImageWeb!.path,
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(Icons.error),
                                              );
                                            },
                                          )
                                        : _selectedImage != null
                                            ? Image.file(
                                                _selectedImage!,
                                                width: double.infinity,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              )
                                            : const SizedBox(),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = null;
                                          _selectedImageWeb = null;
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

                    // Submit Button
                    CustomButton(
                      text: 'Kirim Pengaduan',
                      onPressed: _submitPengaduan,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
