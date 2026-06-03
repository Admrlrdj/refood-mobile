import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({Key? key}) : super(key: key);

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final MapController _mapController = MapController();
  
  // Lokasi default (Misal: Monas, Jakarta)
  LatLng _currentPosition = const LatLng(-6.1753924, 106.8271528);
  String _currentAddress = "Ketuk pada peta untuk memilih lokasi";
  bool _isLoading = true;
  bool _isFetchingAddress = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Mengambil lokasi GPS user saat ini
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      
      // Pindahkan kamera ke lokasi user
      _mapController.move(_currentPosition, 16.0);
      _getAddressFromLatLng(_currentPosition);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Mengubah Koordinat menjadi Nama Alamat
  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isFetchingAddress = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // Format alamat sesuai ketersediaan data
          _currentAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
            place.postalCode
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Alamat detail tidak ditemukan, Anda tetap bisa menggunakan titik ini.";
      });
    } finally {
      setState(() => _isFetchingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: const Color(0xFF56AB2F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF56AB2F)))
          : Stack(
              children: [
                // 1. Peta OpenStreetMap
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition,
                    initialZoom: 16.0,
                    // Event ketika user mengetuk peta
                    onTap: (tapPosition, point) {
                      setState(() {
                        _currentPosition = point;
                      });
                      _getAddressFromLatLng(point);
                    },
                  ),
                  children: [
                    // Layer Peta (Menggunakan OpenStreetMap Gratis)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.refood.app', // Ganti dengan package name Anda
                    ),
                    // Layer Marker (Pin Merah)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition,
                          width: 50,
                          height: 50,
                          alignment: Alignment.topCenter, // Agar ujung bawah pin pas di kordinat
                          child: const Icon(
                            Icons.location_on,
                            size: 50,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 2. Tombol Cari Lokasi Saya
                Positioned(
                  bottom: 180,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Color(0xFF56AB2F)),
                    onPressed: _determinePosition,
                  ),
                ),

                // 3. Panel Informasi Alamat di Bawah
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lokasi Terpilih:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        
                        // Menampilkan Loading Text atau Alamat
                        Row(
                          children: [
                            const Icon(Icons.map_outlined, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _isFetchingAddress
                                  ? const Text("Mencari alamat...", style: TextStyle(color: Colors.grey))
                                  : Text(
                                      _currentAddress,
                                      style: TextStyle(color: Colors.grey[800], fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Tombol Konfirmasi
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF56AB2F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isFetchingAddress 
                                ? null // Disable jika sedang memuat alamat
                                : () {
                                    // Mengirim alamat dan koordinat kembali ke halaman form Register
                                    Navigator.pop(context, {
                                      'address': _currentAddress,
                                      'latitude': _currentPosition.latitude,
                                      'longitude': _currentPosition.longitude,
                                    });
                                  },
                            child: const Text(
                              "Gunakan Lokasi Ini",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}