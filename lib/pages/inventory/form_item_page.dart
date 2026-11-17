import 'package:flutter/material.dart';

import '../../models/item_model.dart';
import '../../services/firestore_service.dart';

class FormItemPage extends StatefulWidget {
  final ItemModel? item;

  const FormItemPage({super.key, this.item});

  @override
  State<FormItemPage> createState() => _FormItemPageState();
}

class _FormItemPageState extends State<FormItemPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _specificationController =
      TextEditingController();

  final TextEditingController _totalStockController =
      TextEditingController();

  final TextEditingController _availableStockController =
      TextEditingController();

  bool isLoading = false;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final item = widget.item!;

      _nameController.text = item.itemName;
      _categoryController.text = item.category;
      _codeController.text = item.code;
      _imageController.text = item.image;
      _specificationController.text = item.spesification;

      _totalStockController.text = item.totalStock.toString();
      _availableStockController.text =
          item.availableStock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _codeController.dispose();
    _imageController.dispose();
    _specificationController.dispose();
    _totalStockController.dispose();
    _availableStockController.dispose();

    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final totalStock = int.tryParse(_totalStockController.text);
    final availableStock =
        int.tryParse(_availableStockController.text);

    if (totalStock == null || availableStock == null) return;

    if (availableStock > totalStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Stok tersedia tidak boleh melebihi total stok',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final item = ItemModel(
        itemId: widget.item?.itemId ?? '',
        itemName: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        code: _codeController.text.trim(),
        status: availableStock > 0 ? 'Available' : 'Borrowed',
        image: _imageController.text.trim(),
        spesification: _specificationController.text.trim(),
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        totalStock: totalStock,
        availableStock: availableStock,
      );

      if (isEditing) {
        await _firestoreService.updateItem(item);
      } else {
        await _firestoreService.addItem(item);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Data alat berhasil diperbarui'
                : 'Data alat berhasil ditambahkan',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Alat' : 'Tambah Alat',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                controller: _nameController,
                label: 'Nama Alat',
                hint: 'Contoh: Multimeter Digital',
                icon: Icons.science_outlined,
              ),
              _buildField(
                controller: _categoryController,
                label: 'Kategori',
                hint: 'Contoh: Elektronika',
                icon: Icons.category_outlined,
              ),
              _buildField(
                controller: _codeController,
                label: 'Kode Alat',
                hint: 'Contoh: LAB-001',
                icon: Icons.qr_code,
              ),
              _buildField(
                controller: _imageController,
                label: 'URL Gambar',
                hint: 'Masukkan link gambar (opsional)',
                icon: Icons.image_outlined,
                required: false,
              ),
              _buildField(
                controller: _specificationController,
                label: 'Spesifikasi',
                hint: 'Tuliskan spesifikasi alat',
                icon: Icons.description_outlined,
                maxLines: 3,
                required: false,
              ),

              const SizedBox(height: 10),

              const Text(
                'Jumlah Stok Alat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              _buildField(
                controller: _totalStockController,
                label: 'Total Stok',
                hint: 'Contoh: 10',
                icon: Icons.inventory_2_outlined,
                numberOnly: true,
              ),

              _buildField(
                controller: _availableStockController,
                label: 'Stok Tersedia',
                hint: 'Contoh: 10',
                icon: Icons.check_circle_outline,
                numberOnly: true,
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Stok tersedia adalah jumlah alat yang masih '
                  'bisa dipinjam. Status alat akan diatur otomatis.',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : _saveItem,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    isLoading ? 'Menyimpan...' : 'Simpan Data',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = true,
    bool numberOnly = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: numberOnly
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (required &&
                  (value == null || value.trim().isEmpty)) {
                return '$label tidak boleh kosong';
              }

              if (numberOnly && value != null && value.isNotEmpty) {
                final number = int.tryParse(value);

                if (number == null || number < 0) {
                  return 'Masukkan angka bulat yang valid';
                }
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}