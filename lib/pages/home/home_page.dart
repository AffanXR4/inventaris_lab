import 'package:flutter/material.dart';

import '../../models/item_model.dart';
import '../../services/firestore_service.dart';
import '../inventory/detail_item_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController =
      TextEditingController();

  String selectedCategory = 'Semua';
  String selectedStatus = 'Semua';

  final List<String> banners = [
    'https://images.pexels.com/photos/6804594/pexels-photo-6804594.jpeg',
    'https://images.pexels.com/photos/18471533/pexels-photo-18471533.jpeg',
    'https://images.pexels.com/photos/12741849/pexels-photo-12741849.jpeg',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ItemModel> filterItems(List<ItemModel> items) {
    return items.where((item) {
      final search = _searchController.text.toLowerCase();

      final matchesSearch =
          item.itemName.toLowerCase().contains(search) ||
          item.code.toLowerCase().contains(search);

      final matchesCategory =
          selectedCategory == 'Semua' ||
          item.category == selectedCategory;

      final matchesStatus =
          selectedStatus == 'Semua' ||
          item.status == selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // APP BAR
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 75,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.science_outlined,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LabInventory',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Sistem Inventaris Laboratorium',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: StreamBuilder<List<ItemModel>>(
        stream: _firestoreService.getItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil data inventaris'),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final items = snapshot.data ?? [];

          final categories = items
              .map((item) => item.category)
              .where((category) => category.isNotEmpty)
              .toSet()
              .toList();

          final filteredItems = filterItems(items);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SAPAAN
                  const Text(
                    'Halo, Selamat Datang!',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Temukan dan kelola alat laboratoriummu.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // SEARCH BAR
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau kode alat...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BANNER CAROUSEL
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: banners.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.network(
                            banners[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFEAF2FA),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 45,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // KATEGORI
                  const Text(
                    'Kategori Alat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'Semua',
                        ...categories,
                      ].map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected:
                                selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory =
                                    selected ? category : 'Semua';
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // STATUS
                  const Text(
                    'Status Ketersediaan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'Semua',
                        'Available',
                        'Borrowed',
                      ].map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              status == 'Semua' ? 'Semua' : status,
                            ),
                            selected: selectedStatus == status,
                            onSelected: (selected) {
                              setState(() {
                                selectedStatus =
                                    selected ? status : 'Semua';
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // HORIZONTAL SCROLL INVENTARIS
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Alat Laboratorium',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${filteredItems.length} alat',
                        style: const TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  if (filteredItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 45,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Belum ada alat yang ditemukan',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 205,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildItemCard(item);
                        },
                      ),
                    ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ITEM CARD
  Widget _buildItemCard(ItemModel item) {
  final isAvailable = item.availableStock > 0;

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
    child: Container(
      width: 175,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.image.isNotEmpty
                  ? Image.network(
                      item.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.itemName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.code,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Stok: ${item.availableStock}/${item.totalStock}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isAvailable
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAvailable ? 'Available' : 'Borrowed',
              style: TextStyle(
                color: isAvailable
                    ? Colors.green.shade700
                    : Colors.orange.shade800,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // IMAGE PLACEHOLDER
  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFEAF2FA),
      child: const Icon(
        Icons.science_outlined,
        size: 45,
        color: Color(0xFF1976D2),
      ),
    );
  }
}
