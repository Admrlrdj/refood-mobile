import 'package:flutter/material.dart';

class ReceiverDashboard extends StatefulWidget {
  const ReceiverDashboard({Key? key}) : super(key: key);

  @override
  State<ReceiverDashboard> createState() => _ReceiverDashboardState();
}

class _ReceiverDashboardState extends State<ReceiverDashboard> {
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    // Definisi warna utama
    const Color primaryColor = Color(0xFF56AB2F);
    const Color backgroundColor = Color(0xFFF9FBF8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildBanner(),
              _buildMenuGrid(primaryColor),
              _buildSectionTitle("Rekomendasi Makanan", primaryColor),
              _buildHorizontalFoodList(primaryColor),
              const SizedBox(height: 30), // Padding bawah tambahan
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(primaryColor),
    );
  }

  // --- WIDGET HELPERS ---

  // 1. Header (Profil dan Sapaan)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?name=Panti+Asuhan&background=56AB2F&color=fff',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, Panti Asuhan 👋",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    "Siap menerima kebaikan hari ini?",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.black87,
              ),
              onPressed: () {
                // TODO: Aksi notifikasi
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2. Banner Informasi Utama
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF86D538), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Jemput\nMakanan\nSekarang",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: -10,
                  child: Icon(
                    Icons.delivery_dining_rounded,
                    size: 130,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Indikator Carousel (titik-titik)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildDot(true), _buildDot(false), _buildDot(false)],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 16 : 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF56AB2F) : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // 3. Grid Menu Aksi
  Widget _buildMenuGrid(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMenuItem(
            Icons.takeout_dining_rounded,
            "Ambil\nSendiri",
            primaryColor,
          ),
          _buildMenuItem(
            Icons.two_wheeler_rounded,
            "Diantar\nRelawan",
            primaryColor,
          ),
          _buildMenuItem(Icons.history_rounded, "Riwayat", primaryColor),
          _buildMenuItem(Icons.menu_book_rounded, "Edukasi", primaryColor),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // 4. Judul Section (Rekomendasi Makanan)
  Widget _buildSectionTitle(String title, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            "Lihat Semua",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Horizontal List Rekomendasi Makanan
  Widget _buildHorizontalFoodList(Color primaryColor) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
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
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 8,
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
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    food['image'],
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Error builder agar tidak crash jika gambar gagal dimuat
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 110,
                      color: Colors.grey[300],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Makanan
                      Text(
                        food['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Lokasi
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
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Waktu Ketersediaan
                      Text(
                        food['time'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tombol Ambil
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // TODO: Aksi ambil makanan
                          },
                          child: const Text(
                            "Ambil",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

  // 6. Bottom Navigation Bar
  Widget _buildBottomNavigationBar(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[400],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Cari',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Peta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
