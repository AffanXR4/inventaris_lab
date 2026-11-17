import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/item_model.dart';
import '../../services/firestore_service.dart';

class BorrowingFormPage extends StatefulWidget {
  final ItemModel item;

  const BorrowingFormPage({
    super.key,
    required this.item,
  });

  @override
  State<BorrowingFormPage> createState() =>
      _BorrowingFormPageState();
}

class _BorrowingFormPageState extends State<BorrowingFormPage> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _quantityController =
      TextEditingController(text: '1');

  DateTime? startDate;
  DateTime? returnDate;

  TimeOfDay? startTime;
  TimeOfDay? returnTime;

  bool isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (startDate ?? now)
          : (returnDate ?? startDate ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      setState(() {
        if (isStart) {
          startDate = selected;
        } else {
          returnDate = selected;
        }
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selected != null) {
      setState(() {
        if (isStart) {
          startTime = selected;
        } else {
          returnTime = selected;
        }
      });
    }
  }

  DateTime _combineDateTime(
    DateTime date,
    TimeOfDay time,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';

    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Pilih jam';

    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitBorrowing() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
        ),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text);

    if (quantity == null || quantity <= 0) {
      _showMessage('Jumlah peminjaman tidak valid');
      return;
    }

    if (quantity > widget.item.availableStock) {
      _showMessage('Stok alat tidak mencukupi');
      return;
    }

    if (startDate == null ||
        returnDate == null ||
        startTime == null ||
        returnTime == null) {
      _showMessage('Lengkapi tanggal dan jam peminjaman');
      return;
    }

    final startDateTime =
        _combineDateTime(startDate!, startTime!);

    final returnDateTime =
        _combineDateTime(returnDate!, returnTime!);

    if (!returnDateTime.isAfter(startDateTime)) {
      _showMessage(
        'Waktu pengembalian harus setelah waktu peminjaman',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _firestoreService.addBorrowing(
        userId: user.uid,
        item: widget.item,
        quantity: quantity,
        startDateTime: startDateTime,
        returnDateTime: returnDateTime,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peminjaman berhasil disetujui!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Gagal meminjam alat: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Form Peminjaman'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Kode: ${item.code}'),
                  const SizedBox(height: 5),
                  Text('Stok tersedia: ${item.availableStock}'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Jumlah Alat yang Dipinjam',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah alat',
                prefixIcon: const Icon(Icons.numbers),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Waktu Mulai Peminjaman',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _dateTimeButton(
              'Tanggal Mulai',
              _formatDate(startDate),
              Icons.calendar_today,
              () => _selectDate(true),
            ),

            _dateTimeButton(
              'Jam Mulai',
              _formatTime(startTime),
              Icons.access_time,
              () => _selectTime(true),
            ),

            const SizedBox(height: 20),

            const Text(
              'Waktu Pengembalian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _dateTimeButton(
              'Tanggal Pengembalian',
              _formatDate(returnDate),
              Icons.calendar_today,
              () => _selectDate(false),
            ),

            _dateTimeButton(
              'Jam Pengembalian',
              _formatTime(returnTime),
              Icons.access_time,
              () => _selectTime(false),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Text(
                'Peminjaman akan langsung disetujui setelah '
                'berhasil disimpan. Pastikan alat dikembalikan '
                'sesuai waktu yang telah ditentukan.',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    isLoading ? null : _submitBorrowing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Ajukan Peminjaman',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeButton(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1976D2)),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}