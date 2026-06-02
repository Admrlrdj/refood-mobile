import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'auth/role_selection_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

// Tambahkan SingleTickerProviderStateMixin untuk animasi
class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Mengatur animasi mengambang (floating) berdurasi 2 detik (bolak-balik)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Menggunakan RadialGradient untuk efek cahaya (sunburst/spotlight) di tengah
          gradient: RadialGradient(
            center: Alignment(0, -0.1),
            radius: 0.8,
            colors: [
              Color(0xFF9DE44A), // Hijau terang (tengah)
              Color(0xFF56AB2F), // Hijau gelap (tepi)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 40.0,
            ),
            child: Column(
              children: [
                // ================= LOGO =================
                const Column(
                  children: [
                    Text(
                      "RE",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      "food",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),

                const Spacer(), // Mendorong elemen ke tengah secara proporsional
                // ================= ILUSTRASI KERANJANG (ANIMASI) =================
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    // Membuat efek naik-turun menggunakan sin(x)
                    return Transform.translate(
                      offset: Offset(
                        0,
                        12 * math.sin(_animationController.value * math.pi),
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    height: 240,
                    width: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Efek glow / cahaya putih memudar di belakang keranjang
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.15),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Placeholder Ikon Keranjang (Ganti dengan Image.asset jika gambar 3D sudah ada)
                        const Icon(
                          Icons.shopping_basket_rounded,
                          size: 160,
                          color: Colors.white,
                        ),
                        // Hiasan tambahan (seperti bayangan hitam halus di bawah ikon)
                        Positioned(
                          bottom: 25,
                          child: Container(
                            width: 100,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // ================= TEKS DESKRIPSI =================
                const Text(
                  "Solusi mengurangi food wasting",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Platform Manajemen Distribusi Makanan Berlebih yang Dirancang untuk Menjembatani Sektor Kuliner dengan Lembaga Sosial.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // ================= TOMBOL LANJUTKAN =================
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    // Menambahkan Drop Shadow yang halus agar tombol terlihat melayang
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B5E20).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFF1F6D2,
                      ), // Warna krem sesuai desain
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Navigasi ke halaman Role Selection Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoleSelectionPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Lanjutkan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E7D32), // Warna teks hijau gelap
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
