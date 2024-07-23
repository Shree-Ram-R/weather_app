import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:weather_app/additional_info.dart';
import 'package:weather_app/hourly.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "Chennai";
      final res = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey"),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != "200") {
        throw data['message'];
      }
      return data;
      // data['list'][0]['main']['temp'];
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data;
          final currentTemp = data?['list'][0]['main']['temp'];
          final currentPressure = data?['list'][0]['main']['pressure'];
          final humidity = data?['list'][0]['main']['humidity'];
          final windSpeed = data?['list'][0]['wind']['speed'];
          final currentSky = data?['list'][4]['weather'][0]['main'];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                currentSky == "Clouds"
                                    ? Icons.cloud
                                    : currentSky == "Rain"
                                        ? Icons.cloudy_snowing
                                        : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                "$currentSky",
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 1; i < 6; i++)
                //         Hourly(
                //           text: "${data?['list'][i]['dt_txt']}",
                //           value: "${data?['list'][i]['main']['temp']}",
                //           icon: data?['list'][i]['weather'][0]['main'] ==
                //                   "Clouds"
                //               ? Icons.cloud
                //               : data?['list'][i]['weather'][0]['main'] == "Rain"
                //                   ? Icons.cloudy_snowing
                //                   : Icons.sunny,
                //         ),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final time =
                          DateTime.parse(data?['list'][index + 1]['dt_txt']);
                      return Hourly(
                          text: "${DateFormat.j().format(time)}",
                          value: "${data?['list'][index + 1]['main']['temp']}",
                          icon: data?['list'][index + 1]['weather'][0]
                                      ['main'] ==
                                  'Clouds'
                              ? Icons.cloud
                              : data?['list'][index + 1]['weather'][0]
                                          ['main'] ==
                                      "Rain"
                                  ? Icons.cloudy_snowing
                                  : Icons.sunny);
                    },
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfo(
                          icon: Icons.water_drop,
                          text: "Humidity",
                          value: "$humidity"),
                      AdditionalInfo(
                          icon: Icons.air,
                          text: "Wind Speed",
                          value: "$windSpeed"),
                      AdditionalInfo(
                          icon: Icons.beach_access,
                          text: "Pressure",
                          value: currentPressure.toString()),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
