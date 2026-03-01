import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
// 🌟 1. 顶部新增：导入 Firebase Auth 和 Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;

class WelcomeRegistrationScreen extends StatefulWidget {
  const WelcomeRegistrationScreen({super.key});

  @override
  State<WelcomeRegistrationScreen> createState() => _WelcomeRegistrationScreenState();
}

class _WelcomeRegistrationScreenState extends State<WelcomeRegistrationScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};

  final String _googleApiKey = "AIzaSyANJht0xA4ES_dETC14bC3L9yJuYjiHkuE"; // 你的 Key

  List<dynamic> _placeList = [];
  bool _isLoading = false;
  
  // 🌟 新增：用于判断是否正在检查旧用户
  bool _isCheckingUser = true; 

  @override
  void initState() {
    super.initState();
    // 🌟 页面加载时，先检查是不是老用户
    _checkExistingLocation(); 
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // 🌟 新增：检查数据库中是否已有默认地址
  Future<void> _checkExistingLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('defaultLocation')) {
          final loc = doc.data()!['defaultLocation'];
          if (loc != null && loc.toString().isNotEmpty) {
            // 如果是老用户（已经有地址），直接跳转到 home，不显示这个地图页面
            if (mounted) {
              final isManagement = context.read<app_auth.AuthProvider>().userRole == 'management';
              final dest = isManagement ? '/mgmt-dashboard' : '/home?user_location=${Uri.encodeComponent(loc.toString())}';
              context.go(dest);
            }
            return; // 结束执行
          }
        }
      }
    } catch (e) {
      debugPrint("检查老用户状态失败: $e");
    }

    // 如果是新用户（或者获取失败），才显示这个页面并开始定位
    if (mounted) {
      setState(() {
        _isCheckingUser = false; // 隐藏全屏 Loading
      });
      _getCurrentLocation(); // 开始自动获取 GPS
    }
  }

  // 1. 自动定位 (使用 Geocoding API，目前已测试成功)
  Future<void> _getCurrentLocation() async {
    setState(() { _isLoading = true; });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _isLoading = false; });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _isLoading = false; });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() { _isLoading = false; });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_googleApiKey";
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          String fullAddress = result['results'][0]['formatted_address'];
          
          setState(() {
            _searchController.text = fullAddress; 
            
            LatLng currentLatLng = LatLng(position.latitude, position.longitude);
            _markers = {
              Marker(
                markerId: const MarkerId('current_location'),
                position: currentLatLng,
                infoWindow: InfoWindow(title: "Your Location", snippet: fullAddress),
              )
            };
            
            _mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 16.0));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  // 🌟 2. 获取地点建议 (完全重写为 Places API (New) 版本)
  void _getSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() { _placeList = []; });
      return;
    }

    // 新版 API 的 URL
    String url = "https://places.googleapis.com/v1/places:autocomplete";

    try {
      // 新版要求使用 POST 请求，并且要把参数放在 body 和 headers 里
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleApiKey,
        },
        body: jsonEncode({
          "input": input,
          "includedRegionCodes": ["MY"] // 限制只搜索马来西亚
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // 新版返回的数据在 'suggestions' 列表里
        if (result['suggestions'] != null) {
          setState(() { _placeList = result['suggestions']; });
        } else {
          setState(() { _placeList = []; });
        }
      } else {
        debugPrint("⚠️ 新版 Autocomplete 错误: ${response.body}");
        setState(() { _placeList = []; });
      }
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
    }
  }

  // 🌟 3. 获取具体经纬度 (完全重写为 Places API (New) 版本)
  void _getPlaceDetails(String placeId, String fullDescription) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _placeList = [];
      _searchController.text = fullDescription; 
    });

    // 新版 Details API 的 URL
    String url = "https://places.googleapis.com/v1/places/$placeId";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Goog-Api-Key': _googleApiKey,
          // 新版 API 强制要求声明你要获取什么字段 (FieldMask)
          'X-Goog-FieldMask': 'location,formattedAddress,displayName',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['location'] != null) {
          final lat = result['location']['latitude'];
          final lng = result['location']['longitude'];
          LatLng targetLatLng = LatLng(lat, lng);

          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(targetLatLng, 16.0));

          setState(() {
            _markers = {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: targetLatLng,
                infoWindow: InfoWindow(title: fullDescription),
              )
            };
            _isLoading = false;
          });
        }
      } else {
        debugPrint("⚠️ 新版 Details API 错误: ${response.body}");
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  // 4. 点击放大镜直接搜索经纬度 (使用 Geocoding API，目前已测试成功)
  Future<void> _searchAddress() async {
    final query = _searchController.text;
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
          
          LatLng targetLatLng = LatLng(location['lat'], location['lng']);

          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(targetLatLng, 16.0));

          setState(() {
            _searchController.text = fullAddress; 
            _markers = {
              Marker(
                markerId: const MarkerId('searched_location'),
                position: targetLatLng,
                infoWindow: InfoWindow(title: fullAddress),
              )
            };
            _isLoading = false;
          });
        } else {
          setState(() { _isLoading = false; });
        }
      }
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 新增：如果是老用户（正在检查状态），显示全屏加载动画，避免地图闪烁
    if (_isCheckingUser) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7FBF7),
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

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

              // 地图区域
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(3.1390, 101.6869),
                          zoom: 12.0,
                        ),
                        myLocationEnabled: true, 
                        myLocationButtonEnabled: false, 
                        zoomControlsEnabled: true,
                        markers: _markers,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      ),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Selected Community:", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),

              // 搜索框区域
              TextField(
                controller: _searchController,
                onChanged: _getSuggestions, 
                onSubmitted: (value) => _searchAddress(),
                decoration: InputDecoration(
                  hintText: "Enter a location (e.g. Nidoz Residences)",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.blue),
                    onPressed: _getCurrentLocation, 
                    tooltip: "Get Current Location",
                  ),
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
                    onPressed: _searchAddress, 
                  ),
                ),
              ),
              
              // 🌟 5. 更新 UI 列表数据提取方式 (匹配新版 API 的 JSON 结构)
              if (_placeList.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _placeList.length,
                    itemBuilder: (context, index) {
                      // 新版 API 的返回层级较深
                      final prediction = _placeList[index]['placePrediction'];
                      final description = prediction['text']['text'];
                      final placeId = prediction['placeId'];

                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: Colors.blue),
                        title: Text(description), 
                        onTap: () {
                          _getPlaceDetails(placeId, description);
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: 150,
                height: 45,
                child: OutlinedButton(
                  // 🌟 2. 底部修改：变成 async 函数，保存数据到 Firebase
                  onPressed: () async {
                    final location = _searchController.text;
                    final isManagement = context.read<app_auth.AuthProvider>().userRole == 'management';
                    if (location.isNotEmpty) {

                      // -- 新增 Firebase 保存逻辑开始 --
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                                'defaultLocation': location,
                              }, SetOptions(merge: true)); // merge: true 不会覆盖原有的用户信息
                          debugPrint("地址已成功保存到用户数据库！");
                        }
                      } catch (e) {
                        debugPrint("保存地址失败: $e");
                      }
                      // -- 新增 Firebase 保存逻辑结束 --

                      if (!context.mounted) return;
                      final dest = isManagement ? '/mgmt-dashboard' : '/home?user_location=${Uri.encodeComponent(location)}';
                      context.go(dest);
                    } else {
                      context.go(isManagement ? '/mgmt-dashboard' : '/home');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Continue", style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}