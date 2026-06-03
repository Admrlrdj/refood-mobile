import 'package:flutter/material.dart';

class DonorProfilePage extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onLogout; // Fungsi untuk tombol sign out

  const DonorProfilePage({
    Key? key,
    required this.onBackPressed,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        // Catatan: Jika kamu memiliki gambar background polygon hijau (seperti di desain),
        // kamu bisa mengganti gradient ini dengan image: DecorationImage(image: AssetImage('...'))
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF86D538),
            Color(0xFF14532D), // Hijau gelap
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ================= HEADER (Back & Title) =================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: onBackPressed,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Profil",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ================= PROFILE INFO (Avatar & Name) =================
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Donatur16",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_rounded,
                  color: Colors.black.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Avatar dengan Icon Edit
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blueGrey,
                    // TODO: Ganti dengan NetworkImage/AssetImage avatar user nantinya
                    child: Icon(Icons.person, size: 45, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E), // Hijau terang
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Edit Profil Text
            const Text(
              "Edit Profil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // ================= KONTEN BODY (Putih) =================
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB), // Putih sedikit keabu-abuan
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ----- KARTU DATA PROFIL -----
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Data Profil",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildProfileRow("Status Akun", "Aktif"),
                            const SizedBox(height: 12),
                            _buildProfileRow(
                              "Alamat",
                              "Jl. in aja Blok B12, Bogor tenggara",
                            ),
                            const SizedBox(height: 12),
                            _buildProfileRow("Peran", "Donatur"),
                            const SizedBox(height: 12),
                            _buildProfileRow(
                              "Bergabung Sejak",
                              "Kamis, 26 Februari 2026",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ----- KARTU PENGATURAN -----
                      _buildMenuCard(
                        icon: Icons.settings_rounded,
                        title: "Pengaturan",
                      ),
                      const SizedBox(height: 16),

                      // ----- KARTU PRIVASI AKUN -----
                      _buildMenuCard(
                        icon: Icons.privacy_tip_rounded,
                        title: "Privasi Akun",
                      ),
                      const SizedBox(height: 40),

                      // ----- GANTI AKUN -----
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigasi Ganti Akun
                        },
                        child: const Text(
                          "Ganti Akun",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ----- TOMBOL SIGN OUT -----
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF86D538), Color(0xFF4CAF50)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: onLogout, // Panggil fungsi Logout
                          child: const Text(
                            "Sign Out",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
          ],
        ),
      ),
    );
  }

  // WIDGET BANTUAN: Baris Data Profil
  Widget _buildProfileRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET BANTUAN: Kartu Menu (Pengaturan / Privasi)
  Widget _buildMenuCard({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
