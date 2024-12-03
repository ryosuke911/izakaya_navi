import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location.dart';

class StoreMap extends StatefulWidget {
  final Location location;
  final String storeName;

  const StoreMap({
    super.key,
    required this.location,
    required this.storeName,
  });

  @override
  State<StoreMap> createState() => _StoreMapState();
}

class _StoreMapState extends State<StoreMap> {
  late GoogleMapController _controller;
  late final Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = {
      Marker(
        markerId: const MarkerId('store'),
        position: LatLng(widget.location.lat, widget.location.lng),
        infoWindow: InfoWindow(title: widget.storeName),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.location.lat, widget.location.lng),
          zoom: 15,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        myLocationEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 