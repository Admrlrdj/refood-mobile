import 'package:flutter/material.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Warung Barokah 👋',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Siap membagikan kebaikan hari ini?',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundImage: NetworkImage(
              'https://ui-avatars.com/api/?name=W+B',
            ),
            radius: 16,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu Metrik (UI Gamifikasi Figma)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Donasi',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '120 Porsi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Emisi Dicegah',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '15 Kg',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Donasi Aktif',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // List Makanan
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color: Colors.orange.shade100,
                child: const Icon(Icons.fastfood, color: Colors.orange),
              ),
              title: const Text(
                'Ayam Bakar Sisa Katering',
                style: FontWeight.bold,
              ),
              subtitle: const Text('20 Porsi • Exp: 15:00 WIB'),
              trailing: const Chip(
                label: Text(
                  'Menunggu Kurir',
                  style: TextStyle(fontSize: 10, color: Colors.orange),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button "Tambah Donasi"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke Form Tambah Donasi
        },
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Donasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
