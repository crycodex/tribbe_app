import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Servicio para manejar la geolocalización del usuario
class LocationService {
  /// Verificar y solicitar permisos de ubicación
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obtener la posición actual del usuario
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtener dirección desde coordenadas
  Future<Map<String, String>?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return null;

      final placemark = placemarks.first;

      return {
        'pais': placemark.country ?? '',
        'provincia': placemark.administrativeArea ?? '',
        'ciudad': placemark.locality ?? placemark.subAdministrativeArea ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  /// Obtener ubicación completa (coordenadas + dirección)
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return {
        'latitud': position.latitude,
        'longitud': position.longitude,
        'pais': address?['pais'] ?? '',
        'provincia': address?['provincia'] ?? '',
        'ciudad': address?['ciudad'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }
}
