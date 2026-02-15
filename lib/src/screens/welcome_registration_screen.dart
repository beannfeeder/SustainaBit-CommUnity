import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WelcomeRegistrationScreen extends StatefulWidget {
  const WelcomeRegistrationScreen({super.key});

  @override
  State<WelcomeRegistrationScreen> createState() => _WelcomeRegistrationScreenState();
}

class _WelcomeRegistrationScreenState extends State<WelcomeRegistrationScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController(text: "");
  Set<Marker> _markers = {};

  final String _googleApiKey = "AIzaSyANJht0xA4ES_dETC14bC3L9yJuYjiHkuE"; 

  Future<void> _searchAndMoveMap() async {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return;

    LatLng targetLatLng;
    if (query.contains("nidoz")) {
      targetLatLng = const LatLng(3.0886, 101.7042); 
    } else if (query.contains("warf")) {
      targetLatLng = const LatLng(3.0583, 101.6881);
    } else {
      targetLatLng = const LatLng(3.1578, 101.7118); 
    }

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(targetLatLng, 16.0));

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: targetLatLng,
          infoWindow: InfoWindow(title: _searchController.text), 
        )
      };
    });
    
    debugPrint("【测试模式】定位到: ${targetLatLng.latitude}, ${targetLatLng.longitude}");
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "CommUnity",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nice to meet you, Joe!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select your community to receive posts and announcements around your area",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(3.0583, 101.6881),
                      zoom: 12.0,
                    ),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Selected Community:", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Enter a location (e.g. Nidoz Residences)",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.black87),
                    onPressed: _searchAndMoveMap,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: 150,
                height: 45,
                child: OutlinedButton(
                  onPressed: () {
                    final location = _searchController.text;
                    if (location.isNotEmpty) {
                      // 把地点进行编码并放到 URL 里带走
                      context.go('/home?user_location=${Uri.encodeComponent(location)}');
                      debugPrint("位置已发送至 URL: $location");
                    } else {
                      context.go('/home');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Continue", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}