import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../constants/strings.dart';
import '../constants/app_colors.dart';
import '../data/local_data.dart';
import '../models/poi_model.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../services/geofence_service.dart';
import '../services/audio_service.dart';
import 'poi_detail_screen.dart';
import 'video_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  Position? _currentPosition;
  POIModel? _selectedPOI;
  StreamSubscription<Position>? _locationSubscription;
  bool _isTracking = false;
  Set<String> _visitedPOIs = {};

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = position;
      });
      _mapController.move(
        LocationService.positionToLatLng(position),
        15.0,
      );
    }
  }

  void _loadMarkers() {
    for (var poi in LocalData.poiList) {
      _markers.add(
        Marker(
          point: LatLng(poi.latitude, poi.longitude),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _onPOITapped(poi),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  poi.title[0],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bgColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _onPOITapped(POIModel poi) {
    setState(() {
      _selectedPOI = poi;
    });
    _showPOIActions(poi);
  }

  void _showPOIActions(POIModel poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              poi.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _buildRouteToPOI(poi);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.bgColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Маршрут құру'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => POIDetailScreen(poi: poi),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBg,
                  foregroundColor: AppColors.textColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Толығырақ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buildRouteToPOI(POIModel poi) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS қолжетімсіз')),
      );
      return;
    }

    final start = LocationService.positionToLatLng(_currentPosition!);
    final end = LatLng(poi.latitude, poi.longitude);

    final route = await RouteService.getRoute(start, end);
    if (route != null) {
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            points: route,
            strokeWidth: 4.0,
            color: AppColors.primaryOrange,
          ),
        );
        _isTracking = true;
      });

      _startLocationTracking(poi);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints([start, end]),
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  void _startLocationTracking(POIModel poi) {
    _locationSubscription?.cancel();
    _locationSubscription = LocationService.getLocationStream().listen(
      (position) {
        setState(() {
          _currentPosition = position;
        });

        if (GeofenceService.isNearPOI(position, poi) &&
            !_visitedPOIs.contains(poi.id)) {
          _visitedPOIs.add(poi.id);
          _onArrivedAtPOI(poi);
        }
      },
    );
  }

  void _onArrivedAtPOI(POIModel poi) {
    _locationSubscription?.cancel();
    setState(() {
      _isTracking = false;
    });

    // Голосовое повествование
    if (poi.audioText != null) {
      AudioService.speak(poi.audioText!);
    }

    // Показать диалог с видео и текстом
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _POIArrivalDialog(poi: poi),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(44.8528, 65.5092),
                    initialZoom: 8.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.tiri_tarih',
                      maxZoom: 19,
                    ),
                    if (_polylines.isNotEmpty)
                      PolylineLayer(
                        polylines: _polylines,
                      ),
                    MarkerLayer(
                      markers: [
                        ..._markers,
                        if (_currentPosition != null)
                          Marker(
                            point: LocationService.positionToLatLng(
                              _currentPosition!,
                            ),
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _getCurrentLocation,
                    backgroundColor: AppColors.primaryOrange,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.nearbyTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...LocalData.poiList.map((poi) => _buildPOICard(poi)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOICard(POIModel poi) {
    return GestureDetector(
      onTap: () => _onPOITapped(poi),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  poi.title[0],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bgColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Тарих • 120 км',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _POIArrivalDialog extends StatelessWidget {
  final POIModel poi;

  const _POIArrivalDialog({required this.poi});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgColor,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Сіз ${poi.title} орынына жеттіңіз!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (poi.videoUrl != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoScreen(
                        poi: poi,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.bgColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Бейне көру'),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBg,
                foregroundColor: AppColors.textColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Жабу'),
            ),
          ],
        ),
      ),
    );
  }
}
