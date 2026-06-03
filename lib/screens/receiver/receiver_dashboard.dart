import 'package:flutter/material.dart';

class ReceiverDashboard extends StatefulWidget {
  const ReceiverDashboard({Key? key}) : super(key: key);

  @override
  State<ReceiverDashboard> createState() => _ReceiverDashboardState();
}

class _ReceiverDashboardState extends State<ReceiverDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = false; // Bisa diubah ke true jika nanti sudah disambung API

  final String _receiverName = "Panti Asuhan";

  // Data Dummy Summary
  final Map<String, dynamic> _summary = {
    'waiting': 0,
    'active': 2,
    'history': 15,
  };

  // Daftar data *dummy* untuk rekomendasi makanan
  final List<Map<String, dynamic>> _foodRecommendations = [
    {
      'name': 'Nasi Kotak Ayam Bakar',
      'location': 'Warung Nasi Padang - 1.2 km',
      'image':
          'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      'time': 'Tersedia hingga 20:00',
    },
    {
      'name': 'Roti Manis & Donat',
      'location': 'Toko Roti Makmur - 2.5 km',
      'image':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      'time': 'Tersedia hingga 21:00',
    },
    {
      'name': 'Sayur & Lauk Pauk',
      'location': 'Warteg Sederhana - 0.8 km',
      'image':
          'https://images.unsplash.com/photo-1543826173-70651703c5a4?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      'time': 'Tersedia hingga 19:30',
    },
  ];

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Utama (Sama dengan Donatur)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF86D538), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Butuh Bantuan Makanan?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Temukan donasi makanan berlebih di sekitarmu dan jemput kebaikan hari ini.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    // TODO: Aksi untuk eksplor/peta makanan
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Cari Makanan",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Text(
            "Ringkasan Anda",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 3 Kartu Ringkasan (Sama dengan Donatur)
          Row(
            children: [
              _buildSummaryCard(
                count: _summary['history'].toString(),
                label: "Riwayat",
                gradientColors: [
                  const Color(0xFFFB923C),
                  const Color(0xFFEA580C),
                ],
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                count: _summary['active'].toString(),
                label: "Diproses",
                gradientColors: [
                  const Color(0xFF4ADE80),
                  const Color(0xFF16A34A),
                ],
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                count: _summary['waiting'].toString(),
                label: "Menunggu",
                gradientColors: [
                  const Color(0xFF60A5FA),
                  const Color(0xFF2563EB),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Section Rekomendasi (Mirip "Aktivitas Terkini" di Donatur)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Rekomendasi Makanan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Aksi lihat semua
                },
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF56AB2F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Memakai list horizontal gaya Receiver tapi diadaptasi ke UI Donatur
          _buildHorizontalFoodList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Daftar halaman untuk Bottom Navigation
    final List<Widget> pages = [
      _buildHomeContent(),
      const Center(
        child: Text("Halaman Riwayat Penerima"),
      ), // Ganti dengan komponen History nanti
      const Center(
        child: Text("Halaman Profil Penerima"),
      ), // Ganti dengan komponen Profil nanti
    ];

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6F8,
      ), // Background abu-abu terang standar Donatur
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, $_receiverName 👋",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    "Siap menerima kebaikan hari ini?",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.black87,
                  ),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: pages),

      // Bottom Navigation disamakan strukturnya (3 Tab: Beranda, Riwayat, Profil)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) => setState(() {
            _selectedIndex = index;
          }),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Beranda",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: "Riwayat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSummaryCard({
    required String count,
    required String label,
    required List<Color> gradientColors,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.95),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalFoodList() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        // Menghilangkan padding agar rata kiri sesuai style Donatur
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _foodRecommendations.length,
        itemBuilder: (context, index) {
          final food = _foodRecommendations[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                16,
              ), // Rounded sama dengan aktivitas Donatur
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.02,
                  ), // Bayangan soft khas Donatur UI
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Makanan
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    food['image'],
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 110,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              food['location'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        food['time'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFF1F6D2,
                            ), // Warna soft hijau button
                            foregroundColor: const Color(
                              0xFF2E7D32,
                            ), // Teks hijau tua
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Ambil",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
