import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // MENGAMBIL DATA INVENTARIS
  Stream<List<ItemModel>> getItems() {
    return _firestore
        .collection('items')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data());
      }).toList();
    });
  }

  // MENAMBAH INVENTARIS
  Future<void> addItem(ItemModel item) async {
    final doc = _firestore.collection('items').doc();

    final newItem = ItemModel(
      itemId: doc.id,
      itemName: item.itemName,
      category: item.category,
      code: item.code,
      status: item.availableStock > 0
          ? 'Available'
          : 'Borrowed',
      image: item.image,
      spesification: item.spesification,
      createdAt: DateTime.now(),
      totalStock: item.totalStock,
      availableStock: item.availableStock,
    );

    await doc.set(newItem.toMap());
  }

  // MENGEDIT INVENTARIS
  Future<void> updateItem(ItemModel item) async {
    await _firestore
        .collection('items')
        .doc(item.itemId)
        .update(item.toMap());
  }

  // MENGHAPUS INVENTARIS
  Future<void> deleteItem(String itemId) async {
    await _firestore
        .collection('items')
        .doc(itemId)
        .delete();
  }

  // MENGAMBIL PROFIL SISWA
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  // MENGAJUKAN PEMINJAMAN DAN MENGURANGI STOK
  Future<void> addBorrowing({
    required String userId,
    required ItemModel item,
    required int quantity,
    required DateTime startDateTime,
    required DateTime returnDateTime,
  }) async {
    final itemRef =
        _firestore.collection('items').doc(item.itemId);

    final borrowingRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('borrowings')
        .doc();

    await _firestore.runTransaction((transaction) async {
      final itemSnapshot = await transaction.get(itemRef);

      if (!itemSnapshot.exists) {
        throw Exception('Data alat tidak ditemukan');
      }

      final itemData = itemSnapshot.data()!;
      final availableStock =
          (itemData['available_stock'] as num?)?.toInt() ?? 0;

      if (quantity <= 0) {
        throw Exception('Jumlah peminjaman tidak valid');
      }

      if (availableStock < quantity) {
        throw Exception('Stok alat tidak mencukupi');
      }

      final newAvailableStock = availableStock - quantity;

      transaction.update(itemRef, {
        'available_stock': newAvailableStock,
        'status': newAvailableStock > 0
            ? 'Available'
            : 'Borrowed',
      });

      transaction.set(borrowingRef, {
        'borrow_id': borrowingRef.id,
        'item_id': item.itemId,
        'item_name': item.itemName,
        'quantity': quantity,
        'borrow_date': Timestamp.now(),
        'start_datetime': Timestamp.fromDate(startDateTime),
        'return_datetime': Timestamp.fromDate(returnDateTime),
        'status': 'Disetujui',
      });
    });
  }

  // MENGEMBALIKAN ALAT DAN MENAMBAH STOK
  Future<void> returnBorrowing({
    required String userId,
    required String borrowingId,
  }) async {
    final borrowingRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('borrowings')
        .doc(borrowingId);

    await _firestore.runTransaction((transaction) async {
      final borrowingSnapshot =
          await transaction.get(borrowingRef);

      if (!borrowingSnapshot.exists) {
        throw Exception('Data peminjaman tidak ditemukan');
      }

      final borrowing = borrowingSnapshot.data()!;

      if (borrowing['status'] == 'Selesai') {
        throw Exception('Alat sudah dikembalikan');
      }

      final itemId = borrowing['item_id']?.toString() ?? '';
      final quantity =
          (borrowing['quantity'] as num?)?.toInt() ?? 0;

      if (itemId.isEmpty || quantity <= 0) {
        throw Exception('Data peminjaman tidak valid');
      }

      final itemRef =
          _firestore.collection('items').doc(itemId);

      final itemSnapshot = await transaction.get(itemRef);

      if (!itemSnapshot.exists) {
        throw Exception('Data inventaris tidak ditemukan');
      }

      final itemData = itemSnapshot.data()!;

      final totalStock =
          (itemData['total_stock'] as num?)?.toInt() ?? 0;

      final availableStock =
          (itemData['available_stock'] as num?)?.toInt() ?? 0;

      final newAvailableStock =
          (availableStock + quantity).clamp(0, totalStock);

      transaction.update(itemRef, {
        'available_stock': newAvailableStock,
        'status': newAvailableStock > 0
            ? 'Available'
            : 'Borrowed',
      });

      transaction.update(borrowingRef, {
        'status': 'Selesai',
        'actual_return_date': Timestamp.now(),
      });
    });
  }
}