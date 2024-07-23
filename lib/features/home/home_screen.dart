import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/features/home/service/home_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather"),
      ),
      body: ChangeNotifierProvider(
        create: (context) => HomeService(),
        child: Consumer<HomeService>(
          builder: (context, service, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Temp in C:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: service.isWeatherLoading
                            ? "Loading..."
                            : "${service.weatherModel?.current?.tempC.toString()}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!service.isWeatherLoading)
                  Image.network(
                    'https://cdn.weatherapi.com/weather/64x64/night/113.png',
                    errorBuilder: (context, error, stackTrace) {
                      return const Text("Failed to load image");
                    },
                  ),
                Text(
                  service.isWeatherLoading ? "" : service.location.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: TextFormField(
                    onChanged: (value) => Provider.of<HomeService>(
                      context,
                      listen: false,
                    ).updateButtonText(value),
                    controller: service.locationController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Location Name',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (service.locationController.text.isNotEmpty) {
                      service.getWeather(
                        city: service.locationController.text,
                      );
                    } else {
                      await service.getWeatherByCurrentLocation();
                    }
                  },
                  child: Text(service.buttonText),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await service.getWeatherByCurrentLocation();
                  },
                  child: const Text("Get current location"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
