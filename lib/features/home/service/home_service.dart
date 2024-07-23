import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/api/api_service.dart';
import 'package:weather_app/features/home/model/weather_model.dart';

class HomeService extends ChangeNotifier {
  String buttonText = "Save";
  final ApiService _api = ApiService();
  WeatherModel? weatherModel;
  String location = "";
  bool isWeatherLoading = false;
  final locationController = TextEditingController();
  String locationMessage = 'Current location';

  HomeService() {
    _loadSavedLocation();
  }

  void updateButtonText(String value) {
    buttonText = value.isEmpty ? "Save" : "Update";
    notifyListeners();
  }

  void _loadSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    locationController.text = prefs.getString('location') ?? '';
    if (locationController.text.isNotEmpty) {
      getWeather(city: locationController.text);
    } else {
      await getWeatherByCurrentLocation();
    }
  }

  void _saveLocation(String location) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('location', location);
  }

  void getWeather({String? city}) async {
    isWeatherLoading = true;
    notifyListeners();
    weatherModel = await _api.fetchWeather(cityName: city);
    if (weatherModel != null) {
      var address = weatherModel?.location;
      getAddress("Location: ${address?.name} ${address?.tzId}");
      if (city != null) {
        _saveLocation(city);
      }
    }
    isWeatherLoading = false;
    notifyListeners();
  }

  Future<void> getWeatherByCurrentLocation() async {
    isWeatherLoading = true;
    notifyListeners();
    try {
      Position position = await getCurrentLocation();
      double latitude = position.latitude;
      double longitude = position.longitude;
      weatherModel = await _api.fetchWeather(lat: latitude, lon: longitude);
      if (weatherModel != null) {
        var address = weatherModel?.location;
        getAddress("Location: ${address?.name} ${address?.tzId}");
      }
    } catch (error) {
      // error 
    }
    isWeatherLoading = false;
    notifyListeners();
  }

  void getAddress(String value) {
    location = value;
    notifyListeners();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location service are disabled");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permission are denied forever ,we cant request");
    }
    return await Geolocator.getCurrentPosition();
  }
}
