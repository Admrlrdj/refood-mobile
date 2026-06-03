import 'package:flutter/material.dart';

class DonorHistoryPage extends StatelessWidget {
  final VoidCallback onBackPressed;

  // Menerima fungsi onBackPressed agar tombol panah kiri bisa mengembalikan tab ke Beranda
  const DonorHistoryPage({Key? key, required this.onBackPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy Data Riwayat yang dikelompokkan berdasarkan tanggal
    final List<Map<String, dynamic>> historyData = [
      {
        "date": "Minggu, 1 Maret 2026",
        "items": [
          {
            "name": "Ayam Bakar",
            "type": "Makanan",
            "status": "Menunggu Kurir",
            "statusColor": const Color(0xFFFBBF24), // Kuning/Orange
            "icon": Icons.fastfood_rounded,
          },
          {
            "name": "Nasi Goreng",
            "type": "Makanan",
            "status": "Berhasil",
            "statusColor": const Color(0xFF22C55E), // Hijau
            "icon": Icons.fastfood_rounded,
          },
        ],
      },
      {
        "date": "Sabtu, 28 Februari 2026",
        "items": [
          {
            "name": "Es Teh",
            "type": "Minuman",
            "status": "Gagal",
            "statusColor": const Color(0xFFEF4444), // Merah
            "icon": Icons.local_drink_rounded,
          },
        ],
      },
      {"date": "Jum'at, 27 Februari 2026", "items": []},
    ];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF86D538), Color(0xFF56AB2F)],
        ),
      ),
      child: SafeArea(
        bottom:
            false, // Membiarkan container putih menyentuh area bawah (bottom nav)
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  // Tombol Back (Mengarahkan kembali ke Tab Beranda)
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
                    "Riwayat",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const Spacer(),

                  // Dropdown Filter Tanggal
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Tanggal",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ================= KONTEN LIST RIWAYAT =================
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final group = historyData[index];
                    final date = group["date"];
                    final items = group["items"] as List<dynamic>;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Teks Tanggal
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Jika Kosong
                          if (items.isEmpty)
                            const Text(
                              "Tidak ada aktivitas di hari ini.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                          // Iterasi Item Makanan/Minuman
                          ...items.asMap().entries.map((entry) {
                            int itemIndex = entry.key;
                            var item = entry.value;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      item["icon"],
                                      color: Colors.black87,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        item["name"],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          item["status"],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: item["statusColor"],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item["type"],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Tambahkan Divider jika ini BUKAN item terakhir di grup tersebut
                                if (itemIndex != items.length - 1)
                                  const Divider(
                                    height: 32,
                                    thickness: 1,
                                    color: Color(0xFFEEEEEE),
                                  ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
