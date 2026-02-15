import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/cloud_function_service.dart';

class AdminAssignZoneScreen extends StatefulWidget {
  const AdminAssignZoneScreen({super.key});

  @override
  State<AdminAssignZoneScreen> createState() => _AdminAssignZoneScreenState();
}

class _AdminAssignZoneScreenState extends State<AdminAssignZoneScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  
  List<LatLng> _polygonPoints = [];
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};

  DateTime _lastInteractionTime = DateTime.fromMillisecondsSinceEpoch(0);

  // 1. 地图点击事件：记录坐标并画线
  void _onMapTap(LatLng point) {
    // 🛑 核心修复 2：如果距离上次摸按钮不到 500 毫秒，说明是穿透的假点击，直接拦截并无视！
    if (DateTime.now().difference(_lastInteractionTime).inMilliseconds < 500) {
      debugPrint("🛡️ 成功拦截了一次地图穿透点击！");
      return; 
    }

    setState(() {
      _polygonPoints.add(point);
      
      _polygons = {
        Polygon(
          polygonId: const PolygonId('admin_zone'),
          points: _polygonPoints,
          strokeWidth: 2,
          strokeColor: Colors.black87,
          fillColor: Colors.transparent,
        )
      };

      _markers.add(
        Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        )
      );
    });
  }

  // 2. 清除画线
  void _clearPolygon() {
    setState(() {
      _polygonPoints.clear();
      _polygons.clear();
      _markers.clear();
    });
  }

  // 3. 搜索定位功能
  Future<void> _searchLocation() async {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return;

    LatLng targetLatLng = const LatLng(3.0583, 101.6881); 
    if (query.contains("nidoz")) targetLatLng = const LatLng(3.0886, 101.7042);
    if (query.contains("klcc")) targetLatLng = const LatLng(3.1578, 101.7118);

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(targetLatLng, 15.0));
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
      backgroundColor: const Color(0xFFF4F7F6),
      
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5BB2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => context.push('/settings'),
        ),
        title: Row(
          children: [
            const Icon(Icons.maps_home_work, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              "CommUnity",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => context.push('/search'),
          ),
          IconButton(icon: const Icon(Icons.notifications, color: Colors.white), onPressed: () {}),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          )
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Assign Zone",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ]
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search location",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _searchLocation(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(3.0583, 101.6881),
                    zoom: 14.0,
                  ),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _markers,
                  polygons: _polygons,
                  onTap: _onMapTap, 
                  onMapCreated: (controller) => _mapController = controller,
                ),

                Positioned(
                  bottom: 20,
                  right: 20,
                  // 🛑 核心修复 3：用 Listener 监听鼠标“按下”的瞬间，重置秒表时间
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (_) {
                      _lastInteractionTime = DateTime.now(); // 只要鼠标碰到这片区域，立刻刷新保护时间
                    },
                    child: Row(
                      children: [
                        if (_polygonPoints.isNotEmpty)
                          FloatingActionButton(
                            heroTag: "clear_btn",
                            mini: true,
                            backgroundColor: Colors.redAccent,
                            onPressed: _clearPolygon,
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (_polygonPoints.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please draw a zone on the map first!'))
                              );
                              return;
                            }
                            final points = _polygonPoints.map((p) => {
                              'latitude': p.latitude,
                              'longitude': p.longitude,
                            }).toList();
                            try {
                              await CloudFunctionService().updateZone(points);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Zone Updated Successfully!'), backgroundColor: Colors.green)
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update zone: $e'), backgroundColor: Colors.red)
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            elevation: 4,
                          ),
                          child: const Text("Update Area", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E5BB2),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/mgmt-dashboard');
              break;
            case 1:
              context.go('/home');
              break;
            case 3:
              context.go('/issues');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.dynamic_feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 36, color: Color(0xFF1E5BB2)), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Issues'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}