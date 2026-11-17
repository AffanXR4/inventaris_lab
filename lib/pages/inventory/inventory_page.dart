import 'package:flutter/material.dart';
import 'detail_item_page.dart';
import '../../models/item_model.dart';
import '../../services/firestore_service.dart';
import 'form_item_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';
  String selectedStatus = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteItem(ItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Barang'),
          content: Text(
            'Apakah kamu yakin ingin menghapus ${item.itemName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteItem(item.itemId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil dihapus')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus barang: $e')),
        );
      }
    }
  }

  void _openForm({ItemModel? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormItemPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Inventaris Alat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama atau kode alat...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _statusChip('Semua'),
                _statusChip('Available'),
                _statusChip('Borrowed'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<ItemModel>>(
              stream: _firestoreService.getItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Terjadi kesalahan saat mengambil data.'),
                  );
                }

                final items = snapshot.data ?? [];

                final filteredItems = items.where((item) {
                  final matchesSearch =
                      item.itemName.toLowerCase().contains(searchQuery) ||
                      item.code.toLowerCase().contains(searchQuery);

                  final matchesStatus = selectedStatus == 'Semua' ||
                      item.status == selectedStatus;

                  return matchesSearch && matchesStatus;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 65,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada data alat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Tekan tombol Tambah Alat untuk memulai.'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    return InkWell(
  borderRadius: BorderRadius.circular(16),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailItemPage(item: item),
      ),
    );
  },
  child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: item.image.isNotEmpty
                                  ? Image.network(
                                      item.image,
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _imagePlaceholder();
                                      },
                                    )
                                  : _imagePlaceholder(),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.itemName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Kode: ${item.code}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.status == 'Available'
                                          ? Colors.green.withValues(alpha: 0.12)
                                          : Colors.orange.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: TextStyle(
                                        color: item.status == 'Available'
                                            ? Colors.green
                                            : Colors.orange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _openForm(item: item);
                                } else if (value == 'delete') {
                                  _deleteItem(item);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Hapus'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

  Widget _statusChip(String status) {
    final isSelected = selectedStatus == status;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedStatus = status;
          });
        },
        selectedColor: const Color(0xFFBBDEFB),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 75,
      height: 75,
      color: const Color(0xFFE3F2FD),
      child: const Icon(
        Icons.science_outlined,
        size: 35,
        color: Color(0xFF1976D2),
      ),
    );
  }
}
