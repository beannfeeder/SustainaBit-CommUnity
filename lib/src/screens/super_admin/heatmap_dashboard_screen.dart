import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 1. 定义数据模型
class ManagementZone {
  final String id;
  final String name;
  final List<LatLng> boundary;
  final List<IssueItem> issues;

  ManagementZone({
    required this.id,
    required this.name,
    required this.boundary,
    required this.issues,
  });

  int get issueCount => issues.length;
}

class IssueItem {
  final LatLng position;
  final String category;
  final int ageDays;
  final bool isHighPriority;

  IssueItem({
    required this.position, 
    required this.category, 
    required this.ageDays, 
    required this.isHighPriority
  });
}

class HeatmapDashboardScreen extends StatefulWidget {
  const HeatmapDashboardScreen({super.key});

  @override
  State<HeatmapDashboardScreen> createState() => _HeatmapDashboardScreenState();
}

class _HeatmapDashboardScreenState extends State<HeatmapDashboardScreen> {
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  // ignore: unused_field
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // 延迟一帧执行，确保 context 准备就绪
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadZoneData();
    });
  }

  // 2. 加载区域数据并生成视觉效果
  Future<void> _loadZoneData() async {
    // 模拟数据
    List<ManagementZone> zones = [
      ManagementZone(
        id: "zone_1",
        name: "Bukit Jalil",
        boundary: [
          const LatLng(3.065, 101.685), const LatLng(3.065, 101.700),
          const LatLng(3.050, 101.700), const LatLng(3.050, 101.685),
        ],
        issues: List.generate(25, (i) => IssueItem(position: const LatLng(3.058, 101.690), category: 'Pothole', ageDays: 4, isHighPriority: true)),
      ),
      ManagementZone(
        id: "zone_2",
        name: "Puchong Central",
        boundary: [
          const LatLng(3.045, 101.615), const LatLng(3.045, 101.630),
          const LatLng(3.030, 101.630), const LatLng(3.030, 101.615),
        ],
        issues: List.generate(8, (i) => IssueItem(position: const LatLng(3.038, 101.622), category: 'Streetlight', ageDays: 2, isHighPriority: false)),
      ),
    ];

    Set<Polygon> tempPolygons = {};
    Set<Marker> tempMarkers = {};

    for (var zone in zones) {
      // 颜色逻辑：>20红，6-20橙，<6绿
      Color zoneColor = zone.issueCount > 20 
          ? Colors.red 
          : (zone.issueCount >= 6 ? Colors.orange : Colors.green);

      // 添加区域范围
      tempPolygons.add(Polygon(
        polygonId: PolygonId(zone.id),
        points: zone.boundary,
        fillColor: zoneColor.withOpacity(0.25),
        strokeColor: zoneColor,
        strokeWidth: 2,
        consumeTapEvents: true, // 允许点击多边形触发事件
        onTap: () => _showZoneDetails(zone),
      ));

      // 计算中心点并生成自定义 Marker
      LatLng center = _calculateCenter(zone.boundary);
      final markerIcon = await _getCustomMarkerIcon(zone.issueCount.toString(), zoneColor);
      
      tempMarkers.add(Marker(
        markerId: MarkerId("${zone.id}_label"),
        position: center,
        icon: markerIcon,
        anchor: const Offset(0.5, 0.5), // 确保圆心对准坐标点
        onTap: () => _showZoneDetails(zone),
      ));
    }

    if (!mounted) return;
    setState(() {
      _polygons = tempPolygons;
      _markers = tempMarkers;
    });
  }

  // 3. 绘制带数字的自定义 Marker
  Future<BitmapDescriptor> _getCustomMarkerIcon(String text, Color color) async {
    const double size = 120.0; // 稍微加大尺寸提高清晰度
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    
    // 绘制外圈阴影/边框
    final Paint shadowPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(const Offset(size/2, size/2), size/2.2, shadowPaint);

    // 绘制主体圆形
    final Paint paint = Paint()..color = color;
    canvas.drawCircle(const Offset(size/2, size/2), size/2.6, paint);

    // 绘制文字
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text, 
      style: const TextStyle(
        fontSize: 40, 
        color: Colors.white, 
        fontWeight: FontWeight.bold
      )
    );
    painter.layout();
    painter.paint(canvas, Offset(size/2 - painter.width/2, size/2 - painter.height/2));

    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  LatLng _calculateCenter(List<LatLng> points) {
    double lat = 0, lng = 0;
    for (var p in points) { lat += p.latitude; lng += p.longitude; }
    return LatLng(lat / points.length, lng / points.length);
  }

  void _showZoneDetails(ManagementZone zone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(zone.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
                  child: Text('${zone.issueCount} Issues', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.warning_amber_rounded)),
              title: const Text('Priority Status'),
              subtitle: Text(zone.issueCount > 20 ? 'Action Required: Immediate' : 'Stable'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A80F0)),
                child: const Text('View Detailed List', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A80F0),
        elevation: 0,
        title: const Text('Global Heatmap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.layers, color: Colors.white)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list, color: Colors.white)),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(3.058, 101.687), zoom: 12),
        polygons: _polygons,
        markers: _markers,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (controller) => _mapController = controller,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4A80F0),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.map), onPressed: () {}),
            IconButton(icon: const Icon(Icons.list_alt), onPressed: () {}),
            const SizedBox(width: 40), // 为 FAB 留空
            IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
            IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}