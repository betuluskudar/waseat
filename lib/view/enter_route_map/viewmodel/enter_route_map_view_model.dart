import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:waseat/core/base/viewmodel/base_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:waseat/view/_product/enum/vehicle_enum.dart';
import 'package:waseat/view/find_footprint/view/subview/find_footprint_list_view.dart';
import 'package:waseat/view/find_footprint/view/subview/find_footprint_map_view.dart';

part 'enter_route_map_view_model.g.dart';

class EnterRouteMapViewModel = _EnterRouteMapViewModelBase
    with _$EnterRouteMapViewModel;

abstract class _EnterRouteMapViewModelBase with Store, BaseViewModel {
  late GoogleMapController controller;
  late Map<MarkerId, Marker> markers;
  late Map<PolylineId, Polyline> polylines;
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyBnYhemLkubciMG_ehstxBtdW7sf8Lzic0";

  TextEditingController? searchController;

  @observable
  LatLng currentPosioton = const LatLng(0, 0);

  double _originLatitude = 26.48424, _originLongitude = 50.04551;
  double _destLatitude = 26.46423, _destLongitude = 50.06358;

  @observable
  ObservableList<LatLng> polylineCoordinates = ObservableList.of([]);

  @override
  void setContext(BuildContext context) => this.context = context;

  @override
  void init() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      currentPosioton = await getCurrentLatLng();
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentPosioton, zoom: 15),
        ),
      );
    });
    markers = {};
    polylines = {};
    searchController = TextEditingController();
  }

  @observable
  bool isLoading = false;

  @action
  void isLoadingChange() {
    isLoading = !isLoading;
  }

  void setCurrentLocation() async {
    currentPosioton = await getCurrentLatLng();

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentPosioton, zoom: 15),
      ),
    );
  }

  Future<LatLng> getCurrentLatLng() async {
    final location = await determinePosition();
    return LatLng(location.latitude, location.longitude);
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  List<VehicleEnum> vehicles = [
    VehicleEnum.BIKE,
    VehicleEnum.CAR,
    VehicleEnum.TRANSPORTATION,
    VehicleEnum.BICYCLE,
    VehicleEnum.SCOOTER,
  ];

  void addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
  }

  void getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(_originLatitude, _originLongitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    addPolyLine();
  }
}