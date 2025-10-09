import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/walk_data.dart'; // WalkData model imported

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final user = FirebaseAuth.instance.currentUser!;
  GoogleMapController? mapController;
  final Box<WalkData> walkBox = Hive.box<WalkData>('walks'); // Hive Box instance

  LatLng? _currentLocation;
  bool _locationServiceEnabled = false;
  bool _permissionGranted = false;
  bool _isLoadingMap = true;
  final Set<Marker> _markers = {};

  // --- Tracking State Variables ---
  bool _isTracking = false;
  List<LatLng> _currentPath = [];
  double _totalDistance = 0.0; // Distance in kilometers
  late DateTime _startTime;
  Timer? _timer;
  Duration _elapsedDuration = Duration.zero;
  StreamSubscription<Position>? _positionStreamSubscription;

  final Set<Polyline> _polylines = {};
  static const PolylineId trackingPolylineId = PolylineId('trackingPath');

  WalkData? _selectedWalk; // Currently displayed historical walk data

  @override
  void initState() {
    super.initState();
    _checkLocationAndPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  // --- Location and Permission Handling ---

  Future<void> _checkLocationAndPermission() async {
    _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_locationServiceEnabled) {
      if(mounted) setState(() { _isLoadingMap = false; });
      _showLocationServiceDialog();
      return;
    }

    var permissionStatus = await Permission.locationWhenInUse.status;

    if (permissionStatus.isDenied) {
      permissionStatus = await Permission.locationWhenInUse.request();
    }

    if (permissionStatus.isGranted) {
      if(mounted) setState(() { _permissionGranted = true; });
      await _startLocationUpdates();
    } else {
      if(mounted) setState(() { _isLoadingMap = false; });
      _showPermissionDeniedDialog();
    }
  }

  // Start live location updates
  Future<void> _startLocationUpdates() async {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);

      if (_currentLocation == null) {
        _setInitialLocation(newLocation);
      } else if (_isTracking) {
        _updateTracking(newLocation);
      }

      setState(() {
        _currentLocation = newLocation;
        _updateCurrentLocationMarker(newLocation);
      });

      if (_isTracking && mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(newLocation));
      }

    }, onError: (error) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location stream error: $error')));
    });

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _setInitialLocation(LatLng(initialPosition.latitude, initialPosition.longitude));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not get initial location: $e')));
    }

    if(mounted) setState(() { _isLoadingMap = false; });
  }

  void _setInitialLocation(LatLng location) {
    if (_currentLocation != null) return;

    setState(() {
      _currentLocation = location;
      _updateCurrentLocationMarker(location);
    });

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 17),
      ),
    );
  }

  void _updateCurrentLocationMarker(LatLng location) {
    _markers.removeWhere((m) => m.markerId.value == 'currentLocation');
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: location,
        infoWindow: const InfoWindow(title: 'Your Current Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
  }

  // --- Tracking Functions ---

  void _startWalk() {
    if (_currentLocation == null) return;

    setState(() {
      _isTracking = true;
      _startTime = DateTime.now();
      _totalDistance = 0.0;
      _elapsedDuration = Duration.zero;
      _currentPath = [_currentLocation!]; // Start path with current location
      _polylines.clear();
      _selectedWalk = null; // Ensure history view is closed

      // Start timer for tracking time
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _elapsedDuration = DateTime.now().difference(_startTime);
          });
        }
      });
    });

    _updatePolyline();
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Walk started! Drawing path on map.')));
  }

// MapPage-এর _updateTracking ফাংশন সংশোধন:

  void _updateTracking(LatLng newLocation) {
    if (!_isTracking || _currentPath.isEmpty) return;

    final lastLocation = _currentPath.last;

    // দূরত্ব মিটারে গণনা
    double distanceInMeters = Geolocator.distanceBetween(
      lastLocation.latitude,
      lastLocation.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );

    // ১ মিটারের কম দূরত্ব উপেক্ষা করুন (ঐচ্ছিক: শুধুমাত্র স্থির থাকা অবস্থায় GPS নয়েজ এড়াতে)
    if (distanceInMeters < 1.0) { // ১ মিটার থ্রেশহোল্ড (৩ মিটারের বদলে)
      // যদি আমরা যথেষ্ট না হেঁটে থাকি, তবে শুধু পাথ আপডেট করব না, কিন্তু লাইভ লোকেশন আপডেট করব।
      // যেহেতু লোকেশন আপডেট ইতিমধ্যেই উপরে setState এ হয়ে যাচ্ছে, তাই এখানে শুধু return করব।
      return;
    }

    // দূরত্ব যোগ করা হলো
    _totalDistance += distanceInMeters / 1000.0; // km

    // UI আপডেট করার জন্য setState কল করা হলো
    setState(() {
      _currentPath.add(newLocation);
      _updatePolyline();
    });

    // এখন _totalDistance আপডেট হয়েছে, এবং setState এর মাধ্যমে FAB লেবেলটি আপডেট হবে।
  }
  void _updatePolyline() {
    _polylines.removeWhere((p) => p.polylineId == trackingPolylineId);
    _polylines.add(
      Polyline(
        polylineId: trackingPolylineId,
        points: _currentPath,
        color: Colors.teal.shade700,
        width: 5,
        geodesic: true,
      ),
    );
  }

  Future<void> _stopWalk() async {
    // print('Stop Walk called. Current path length: ${_currentPath.length}'); // <--- এই লাইনটি সরানো হলো
    _timer?.cancel();

    // ডেটা সেভ করার জন্য চূড়ান্ত সময়, দূরত্ব, শুরু সময় এবং পাথ কপি করে লোকাল ভ্যারিয়েবলে সংরক্ষণ করা হলো।
    final double finalDistance = _totalDistance;
    final Duration finalDuration = _elapsedDuration;
    final DateTime finalStartTime = _startTime;
    final List<LatLng> finalPath = List.from(_currentPath); // Path কপি করা হলো

    // 1. Immediately reset the tracking state and update the UI (setState).
    final bool wasTracking = _isTracking;
    setState(() {
      _isTracking = false;
      _polylines.clear();
      _totalDistance = 0.0;
      _elapsedDuration = Duration.zero;
      _currentPath.clear();
      _timer = null;
    });

    if (!wasTracking || finalPath.length < 2) {
      if(mounted && finalPath.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough distance walked to save data.')));
      }
      return;
    }

    // 3. Save the walk data using the final stored values.
    final walkData = WalkData(
      distanceKm: finalDistance, // ট্রাঙ্কেশন (truncation) ছাড়া সম্পূর্ণ দূরত্ব সেভ হবে
      durationMicroseconds: finalDuration.inMicroseconds,
      startTime: finalStartTime,
      pathPoints: finalPath.map((p) => LatLngAdapter.fromLatLng(p)).toList(),
      userId: user.uid,
    );

    await walkBox.add(walkData);

    if(mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Walk finished! ${walkData.distanceKm.toStringAsFixed(2)} km data saved.'), // এখানে ডিসপ্লে করার সময় ট্রাঙ্কেট করা হয়েছে
        backgroundColor: Colors.green,
      ),
    );

    // print('Walk successfully stopped and saved.'); // <--- এই লাইনটি সরানো হলো
  }
  // --- Map Display Dialogs and Utility ---

  void _showLocationServiceDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Location Service Required'),
          content: const Text(
            'The app requires your device\'s location service (GPS) to be enabled for functionality. Please enable it in settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  setState(() {
                    _isLoadingMap = false;
                  });
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Map will not function without location service enabled.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Geolocator.openLocationSettings();

                await Future.delayed(const Duration(seconds: 1));
                _checkLocationAndPermission();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text(
            'Location permission is required for the app to function. Please grant permission in app settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  setState(() {
                    _isLoadingMap = false;
                  });
                }
              },
            ),
            TextButton(
              child: const Text('Open App Settings'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  // Formats Duration into HH:MM:SS
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:${twoDigitMinutes}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  // --- History Functions ---

  void _loadHistoricalWalk(WalkData walk) {
    if (_isTracking) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tracking is active. Please stop before viewing history.')));
      return;
    }

    setState(() {
      _selectedWalk = walk;
      _polylines.clear();
      _markers.clear();

      final historicalPath = walk.pathPoints.map((p) => p.toLatLng()).toList();

      _polylines.add(
        Polyline(
          polylineId: const PolylineId('historicalPath'),
          points: historicalPath,
          color: Colors.blue.shade700,
          width: 6,
          geodesic: true,
        ),
      );

      if (historicalPath.isNotEmpty) {
        final startPoint = historicalPath.first;
        final endPoint = historicalPath.last;

        _markers.add(Marker(
          markerId: const MarkerId('startMarker'),
          position: startPoint,
          infoWindow: InfoWindow(title: 'Start: ${walk.formattedDate}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
        _markers.add(Marker(
          markerId: const MarkerId('endMarker'),
          position: endPoint,
          infoWindow: InfoWindow(title: 'End: ${walk.formattedDate}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(startPoint, 15),
        );
      }
    });

    Navigator.of(context).pop(); // Close drawer
  }

  void _deleteWalk(WalkData walk) async {
    // Delete data from Hive
    await walk.delete();

    // If the currently displayed walk is deleted, reset the map
    if (_selectedWalk == walk) {
      _resetMapToCurrentLocation(closeDrawer: false);
    }
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Walk data successfully deleted.')));
  }

  void _resetMapToCurrentLocation({bool closeDrawer = true}) {
    setState(() {
      _selectedWalk = null;
      _polylines.clear();
      _markers.clear();
      if (_currentLocation != null) {
        _updateCurrentLocationMarker(_currentLocation!);
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 17),
        );
      }
    });
    if (closeDrawer) {
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.email ?? 'User'}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _isTracking ? "Time: ${_formatDuration(_elapsedDuration)}" : "",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      // ** Walk History Drawer **
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.email ?? 'Walk Tracker User'),
              accountEmail: Text('Total walks: ${walkBox.values.where((walk) => walk.userId == user.uid).length}'),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.teal, size: 40),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.map, color: Colors.teal),
              title: const Text('Return to Live Map'),
              onTap: () => _resetMapToCurrentLocation(closeDrawer: true),
            ),
            const Divider(),

            // Hive History List
            Expanded(
              child: ValueListenableBuilder<Box<WalkData>>(
                // FIX: Changed valueNotifier to valueListenable
                valueListenable: walkBox.listenable(),
                builder: (context, box, _) {
                  final userWalks = box.values
                      .where((walk) => walk.userId == user.uid)
                      .toList()
                      .reversed.toList();

                  if (userWalks.isEmpty) {
                    return const Center(child: Text('No walk data saved yet.'));
                  }

                  return ListView.builder(
                    itemCount: userWalks.length,
                    itemBuilder: (context, index) {
                      final walk = userWalks[index];
                      return ListTile(
                        leading: const Icon(Icons.run_circle_outlined, color: Colors.grey),
                        title: Text('Distance: ${walk.distanceKm} km'),
                        subtitle: Text('Duration: ${walk.formattedDuration} | Date: ${walk.formattedDate}'),
                        onTap: () => _loadHistoricalWalk(walk),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteWalk(walk),
                        ),
                        selected: walk == _selectedWalk,
                        selectedColor: Colors.teal,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Map View
      body: _isLoadingMap || (_currentLocation == null && _selectedWalk == null)
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _currentLocation != null
            ? CameraPosition(target: _currentLocation!, zoom: 17)
            : const CameraPosition(target: LatLng(23.8103, 90.4125), zoom: 15),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          if (_currentLocation != null && _selectedWalk == null) {
            controller.animateCamera(
              CameraUpdate.newLatLng(_currentLocation!),
            );
          }
        },
        myLocationEnabled: _selectedWalk == null,
        markers: _markers,
        polylines: _polylines,
      ),

      // Floating Action Button logic
      floatingActionButton: _selectedWalk != null
          ? null // Hide FAB when viewing history
          : FloatingActionButton.extended(
        onPressed: _currentLocation == null
            ? null
            : _isTracking ? _stopWalk : _startWalk,

        label: Text(_isTracking ?
        'STOP (${_totalDistance.toStringAsFixed(2)} km)' :
        'START WALK'),

        icon: Icon(_isTracking ? Icons.stop : Icons.directions_walk),

        backgroundColor: _isTracking ? Colors.red.shade700 : Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}