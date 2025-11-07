import 'package:geolocator/geolocator.dart';
import '../models/poi_model.dart';

class GeofenceService {
  static bool isNearPOI(Position position, POIModel poi) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      poi.latitude,
      poi.longitude,
    );
    return distance <= poi.geofenceRadius;
  }

  static double getDistanceToPOI(Position position, POIModel poi) {
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      poi.latitude,
      poi.longitude,
    );
  }
}

