import 'package:flutter/material.dart';

import '../../models/item_model.dart';
import 'form_item_page.dart';
import 'borrowing_form_page.dart';

class DetailItemPage extends StatelessWidget {
  final ItemModel item;

  const DetailItemPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = item.availableStock > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detail Inventaris'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Inventaris',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormItemPage(item: item),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: item.image.isNotEmpty
                  ? Image.network(
                      item.image,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),

            const SizedBox(height: 22),

            Text(
              item.itemName,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isAvailable
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isAvailable ? 'Available' : 'Borrowed',
                style: TextStyle(
                  color: isAvailable
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Informasi Alat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _infoItem('Nama Alat', item.itemName),
            _infoItem('Kode Serial', item.code),
            _infoItem('Kategori', item.category),
            _infoItem('Total Stok', '${item.totalStock}'),
            _infoItem('Stok Tersedia', '${item.availableStock}'),

            const SizedBox(height: 20),

            const Text(
              'Spesifikasi Alat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                item.spesification.isNotEmpty
                    ? item.spesification
                    : 'Belum ada spesifikasi alat.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isAvailable
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BorrowingFormPage(item: item),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.assignment_turned_in),
                label: Text(
                  isAvailable
                      ? 'Ajukan Peminjaman'
                      : 'Stok Tidak Tersedia',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: const Color(0xFFEAF2FA),
      child: const Icon(
        Icons.science_outlined,
        size: 65,
        color: Color(0xFF1976D2),
      ),
    );
  }
}