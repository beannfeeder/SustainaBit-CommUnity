import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart'; // 🌟 新增导入路由包

class AdminAssignZoneScreen extends StatefulWidget {
  const AdminAssignZoneScreen({super.key});

  @override
  State<AdminAssignZoneScreen> createState() => _AdminAssignZoneScreenState();
}

class _AdminAssignZoneScreenState extends State<AdminAssignZoneScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  
  final List<LatLng> _polygonPoints = [];
  Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};

  final String _googleApiKey = "AIzaSyANJht0xA4ES_dETC14bC3L9yJuYjiHkuE";

  // 状态控制
  List<dynamic> _placeList = [];
  bool _isLoading = false;
  bool _isSaving = false; 

  // 防穿透护盾
  DateTime _lastInteractionTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _loadExistingZone();
  }

  // 从数据库读取现有区域
  Future<void> _loadExistingZone() async {
    setState(() { _isLoading = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (doc.exists && doc.data()!.containsKey('assignedZone')) {
          final List<dynamic> zoneData = doc.data()!['assignedZone'];
          
          if (zoneData.isNotEmpty) {
            List<LatLng> loadedPoints = [];
            for (var point in zoneData) {
              loadedPoints.add(LatLng(point['lat'], point['lng']));
            }

            setState(() {
              _polygonPoints.addAll(loadedPoints);
              
              _polygons = {
                Polygon(
                  polygonId: const PolygonId('admin_zone'),
                  points: _polygonPoints,
                  strokeWidth: 2,
                  strokeColor: Colors.black87,
                  fillColor: Colors.blueAccent.withValues(alpha: 0.2),
                )
              };

              for (var point in loadedPoints) {
                _markers.add(
                  Marker(
                    markerId: MarkerId(point.toString()),
                    position: point,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  )
                );
              }
            });

            if (_mapController != null) {
              _mapController!.animateCamera(CameraUpdate.newLatLngZoom(loadedPoints.first, 14.0));
            }
          }
        }
      }
    } catch (e) {
      debugPrint("读取区域失败: $e");
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  // 获取下拉建议
  void _getSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() { _placeList = []; });
      return;
    }
    String url = "https://places.googleapis.com/v1/places:autocomplete";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleApiKey,
        },
        body: jsonEncode({"input": input, "includedRegionCodes": ["MY"]}),
      );
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['suggestions'] != null) {
          setState(() { _placeList = result['suggestions']; });
        } else {
          setState(() { _placeList = []; });
        }
      }
    } catch (e) {
      debugPrint("获取下拉建议失败: $e");
    }
  }

  // 点击下拉建议，获取经纬度
  void _getPlaceDetails(String placeId, String fullDescription) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _placeList = [];
      _searchController.text = fullDescription; 
    });

    String url = "https://places.googleapis.com/v1/places/$placeId";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Goog-Api-Key': _googleApiKey,
          'X-Goog-FieldMask': 'location,formattedAddress,displayName',
        },
      );
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['location'] != null) {
          final lat = result['location']['latitude'];
          final lng = result['location']['longitude'];
          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16.0));
        }
      }
    } catch (e) {
      debugPrint("获取具体位置失败: $e");
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // 搜索经纬度
  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus(); 
    setState(() {
      _isLoading = true;
      _placeList = []; 
    });

    String url = "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&components=country:my&key=$_googleApiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          final location = result['results'][0]['geometry']['location'];
          String fullAddress = result['results'][0]['formatted_address'];
          
          setState(() { _searchController.text = fullAddress; });
          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(location['lat'], location['lng']), 16.0));
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not found')));
          }
        }
      }
    } catch (e) {
      debugPrint("搜索失败: $e");
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // 地图点击
  void _onMapTap(LatLng point) {
    if (DateTime.now().difference(_lastInteractionTime).inMilliseconds < 500) return; 

    setState(() {
      _polygonPoints.add(point);
      
      _polygons = {
        Polygon(
          polygonId: const PolygonId('admin_zone'),
          points: _polygonPoints,
          strokeWidth: 2,
          strokeColor: Colors.black87,
          fillColor: Colors.blueAccent.withValues(alpha: 0.2), 
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

  // 清空画线
  void _clearPolygon() {
    setState(() {
      _polygonPoints.clear();
      _polygons.clear();
      _markers.clear();
    });
  }

  // 保存到数据库
  Future<void> _saveZoneToDatabase() async {
    setState(() { _isSaving = true; });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (_polygonPoints.isEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'assignedZone': FieldValue.delete(),
            'zoneUpdatedAt': FieldValue.serverTimestamp(), 
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zone Removed Successfully!'), backgroundColor: Colors.orange)
            );
          }
        } else {
          List<Map<String, double>> zoneData = _polygonPoints.map((p) => {
            'lat': p.latitude,
            'lng': p.longitude,
          }).toList();

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'assignedZone': zoneData,
            'zoneUpdatedAt': FieldValue.serverTimestamp(), 
          }, SetOptions(merge: true));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zone Updated Successfully!'), backgroundColor: Colors.green)
            );
          }
        }
      }
    } catch (e) {
      debugPrint("保存区域失败: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update zone: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌟 核心修改：加入了带返回箭头的头部 Row
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 16.0, bottom: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    // 安全退出逻辑
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/mgmt-profile'); // 兜底：如果没法 pop 就强制跳回 Profile
                    }
                  },
                ),
                const Text(
                  "Assign Zone",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _getSuggestions, 
                onSubmitted: (_) => _searchAddress(), 
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: "Search location",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: _searchAddress,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(3.0583, 101.6881), // 默认地图中心点
                    zoom: 14.0,
                  ),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _markers,
                  polygons: _polygons,
                  onTap: _onMapTap, 
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (_polygonPoints.isNotEmpty) {
                      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_polygonPoints.first, 14.0));
                    }
                  },
                ),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),

                if (_placeList.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 16,
                    right: 16,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))]
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _placeList.length,
                        itemBuilder: (context, index) {
                          final prediction = _placeList[index]['placePrediction'];
                          final description = prediction['text']['text'];
                          final placeId = prediction['placeId'];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.blue),
                            title: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () => _getPlaceDetails(placeId, description),
                          );
                        },
                      ),
                    ),
                  ),

                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (_) {
                      _lastInteractionTime = DateTime.now(); 
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
                          onPressed: _isSaving ? null : _saveZoneToDatabase, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            elevation: 4,
                          ),
                          child: _isSaving 
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text("Update Area", style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}