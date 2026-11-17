import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      await AuthService().logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _returnItem(
    BuildContext context,
    String userId,
    String borrowingId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kembalikan Alat'),
          content: const Text(
            'Apakah alat sudah dikembalikan secara fisik '
            'ke laboratorium?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya, Kembalikan'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirestoreService().returnBorrowing(
        userId: userId,
        borrowingId: borrowingId,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alat berhasil dikembalikan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengembalikan alat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(dynamic value) {
    if (value == null) return '-';

    final DateTime date = (value as Timestamp).toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day-$month-$year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Silakan login terlebih dahulu'),
        ),
      );
    }

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profil Saya'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil data profil'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Data profil belum ditemukan'),
            );
          }

          final profile = snapshot.data!.data()!;

          final nama = profile['name']?.toString() ?? 'Nama Siswa';
          final kelas = profile['kelas']?.toString() ?? '-';
          final email = profile['email']?.toString() ?? user.email ?? '-';
          final foto = profile['foto']?.toString() ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KARTU PROFIL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      ClipOval(
                        child: foto.isNotEmpty
                            ? Image.network(
                                foto,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _profilePlaceholder();
                                },
                              )
                            : _profilePlaceholder(),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        nama,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        kelas,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Informasi Akun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _profileInfo(Icons.person_outline, 'Nama Siswa', nama),
                _profileInfo(Icons.school_outlined, 'Kelas', kelas),
                _profileInfo(Icons.email_outlined, 'Email', email),

                const SizedBox(height: 25),

                const Text(
                  'Riwayat Peminjaman',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: userRef
                      .collection('borrowings')
                      .orderBy('borrow_date', descending: true)
                      .snapshots(),
                  builder: (context, borrowingSnapshot) {
                    if (borrowingSnapshot.hasError) {
                      return const Text(
                        'Gagal mengambil riwayat peminjaman',
                      );
                    }

                    if (borrowingSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final borrowings =
                        borrowingSnapshot.data?.docs ?? [];

                    if (borrowings.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 45,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Belum ada riwayat peminjaman',
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: borrowings.map((doc) {
                        final borrowing = doc.data();

                        final namaItem =
                            borrowing['item_name']?.toString() ??
                                'Nama alat';

                        final quantity =
                            borrowing['quantity'] ?? 1;

                        final status =
                            borrowing['status']?.toString() ??
                                'Belum diketahui';

                        final startDate =
                            _formatDateTime(
                          borrowing['start_datetime'],
                        );

                        final returnDate =
                            _formatDateTime(
                          borrowing['return_datetime'],
                        );

                        final isApproved = status == 'Disetujui';

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      color: Color(0xFF1976D2),
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          namaItem,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text('Jumlah: $quantity alat'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(height: 25),

                              _borrowingInfo(
                                'Mulai Peminjaman',
                                startDate,
                              ),

                              _borrowingInfo(
                                'Pengembalian',
                                returnDate,
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  const Text('Status: '),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isApproved
                                          ? Colors.green.shade50
                                          : Colors.blue.shade50,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: isApproved
                                            ? Colors.green.shade700
                                            : Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (isApproved) ...[
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnItem(
                                        context,
                                        user.uid,
                                        doc.id,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.assignment_return,
                                    ),
                                    label: const Text(
                                      'Kembalikan Alat',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileInfo(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1976D2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _borrowingInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFFE3F2FD),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Color(0xFF1976D2),
      ),
    );
  }
}