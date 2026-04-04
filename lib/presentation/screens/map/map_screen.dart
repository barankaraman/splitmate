import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// Full-screen Google Map that lets the user pin a location.
/// Returns a Map with keys 'location' (LatLng) and 'label' (String).
class MapScreen extends StatefulWidget {
  /// Optional initial position (e.g. when editing an existing expense).
  final LatLng? initialLocation;

  const MapScreen({super.key, this.initialLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Default camera position — İstanbul, Türkiye.
  static const _defaultPosition = CameraPosition(
    target: LatLng(41.0082, 28.9784),
    zoom: 13,
  );

  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _setMarker(widget.initialLocation!);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  void _setMarker(LatLng position) {
    setState(() {
      _pickedLocation = position;
      _markers
        ..clear()
        ..add(Marker(
          markerId: const MarkerId('picked'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Expense Location',
            snippet:
                '${position.latitude.toStringAsFixed(5)}, '
                '${position.longitude.toStringAsFixed(5)}',
          ),
        ));
    });
  }

  void _onMapTap(LatLng position) => _setMarker(position);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (widget.initialLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(widget.initialLocation!, 14),
      );
    }
  }

  void _confirmLocation() {
    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(AppStrings.tapToSelectLocation),
            backgroundColor: AppColors.warning),
      );
      return;
    }

    // Build a simple label from lat/lng (real apps would use reverse geocoding).
    final label =
        '${_pickedLocation!.latitude.toStringAsFixed(4)}, '
        '${_pickedLocation!.longitude.toStringAsFixed(4)}';

    Navigator.pop(context, {
      'location': _pickedLocation,
      'label': label,
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text(AppStrings.pickLocation),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map fills the screen.
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: widget.initialLocation != null
                ? CameraPosition(
                    target: widget.initialLocation!, zoom: 14)
                : _defaultPosition,
            onTap: _onMapTap,
            markers: _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),

          // Top instruction banner
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_outlined,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.tapToSelectLocation,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Coordinates chip when a location is picked
          if (_pickedLocation != null)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_pickedLocation!.latitude.toStringAsFixed(5)}, '
                        '${_pickedLocation!.longitude.toStringAsFixed(5)}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Confirm button
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _confirmLocation,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                AppStrings.confirmLocation,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _pickedLocation != null
                    ? AppColors.primary
                    : AppColors.textHint,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
