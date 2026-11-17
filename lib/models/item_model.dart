class ItemModel {
  final String itemId;
  final String itemName;
  final String category;
  final String code;
  final String status;
  final String image;
  final String spesification;
  final DateTime createdAt;
  final int totalStock;
  final int availableStock;

  ItemModel({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.code,
    required this.status,
    required this.image,
    required this.spesification,
    required this.createdAt,
    this.totalStock = 0,
    this.availableStock = 0,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      itemId: map['item_id'] ?? '',
      itemName: map['item_name'] ?? '',
      category: map['category'] ?? '',
      code: map['code'] ?? '',
      status: map['status'] ?? 'Available',
      image: map['image'] ?? '',
      spesification: map['spesification'] ?? '',
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : (map['created_at'] as dynamic).toDate(),
      totalStock: (map['total_stock'] as num?)?.toInt() ?? 0,
      availableStock:
          (map['available_stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'category': category,
      'code': code,
      'status': status,
      'image': image,
      'spesification': spesification,
      'created_at': createdAt,
      'total_stock': totalStock,
      'available_stock': availableStock,
    };
  }
}