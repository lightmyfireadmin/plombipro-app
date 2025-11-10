# Free APIs Integration Guide for PlombiPro

## 📋 Overview

This document provides comprehensive integration instructions for free and freemium APIs that can enhance PlombiPro's functionality without significant costs.

## ✅ Priority APIs to Integrate

### 1. Weather API - OpenWeatherMap

**Purpose**: Job site planning, emergency alerts, seasonal pricing

**Free Tier**: 1,000 calls/day

**Integration**:
```dart
// pubspec.yaml
dependencies:
  weather: ^3.1.1

// lib/services/weather_service.dart
import 'package:weather/weather.dart';

class WeatherService {
  static const String API_KEY = 'YOUR_API_KEY';
  late Weather wf;

  WeatherService() {
    wf = Weather(API_KEY);
  }

  Future<Weather> getWeatherForJobSite(double lat, double lng) async {
    return await wf.currentWeatherByLocation(lat, lng);
  }

  Future<List<Weather>> getForecast(String city) async {
    return await wf.fiveDayForecastByCityName(city);
  }
}
```

**Use Cases**:
- Display weather on job site detail pages
- Send alerts for rain before outdoor work
- Suggest rescheduling for bad weather
- Emergency call-outs for frozen pipes

**Sign up**: https://openweathermap.org/api

---

### 2. Google Maps Platform

**Purpose**: Client addresses, route optimization, job site mapping

**Free Tier**: $200/month credit (~28,000 map loads)

**Integration**:
```dart
// pubspec.yaml
dependencies:
  google_maps_flutter: ^2.6.1
  geocoding: ^3.0.0

// lib/widgets/job_site_map.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class JobSiteMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  Future<String> getAddressFromCoordinates() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    return placemarks[0].street ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: MarkerId('job_site'),
          position: LatLng(latitude, longitude),
        ),
      },
    );
  }
}
```

**Use Cases**:
- Visualize job sites on map
- Calculate travel time/distance
- Route optimization for multiple jobs
- Geocode client addresses

**Setup**: https://developers.google.com/maps/documentation/

---

### 3. EmailJS - Free Email Service

**Purpose**: Send quotes, invoices, reminders via email

**Free Tier**: 200 emails/month

**Integration**:
```dart
// pubspec.yaml
dependencies:
  emailjs: ^3.0.0

// lib/services/email_service_free.dart
import 'package:emailjs/emailjs.dart';

class EmailServiceFree {
  static const String serviceId = 'YOUR_SERVICE_ID';
  static const String templateId = 'YOUR_TEMPLATE_ID';
  static const String publicKey = 'YOUR_PUBLIC_KEY';

  Future<void> sendQuoteEmail({
    required String toEmail,
    required String clientName,
    required String quoteNumber,
    required String pdfUrl,
  }) async {
    try {
      await EmailJS.send(
        serviceId,
        templateId,
        {
          'to_email': toEmail,
          'client_name': clientName,
          'quote_number': quoteNumber,
          'pdf_url': pdfUrl,
          'from_name': 'PlombiPro',
        },
        Options(
          publicKey: publicKey,
        ),
      );
    } catch (error) {
      print('Failed to send email: $error');
      rethrow;
    }
  }
}
```

**Email Templates**:
```html
<!-- Create on EmailJS dashboard -->
<h2>Nouveau devis - {{quote_number}}</h2>
<p>Bonjour {{client_name}},</p>
<p>Veuillez trouver ci-joint votre devis.</p>
<a href="{{pdf_url}}">Télécharger le devis</a>
```

**Use Cases**:
- Send quotes to clients
- Invoice reminders
- Payment confirmations
- Job site updates

**Sign up**: https://www.emailjs.com/

---

### 4. Stripe Payments

**Purpose**: Accept online payments for invoices

**Free Setup**: 1.4% + €0.25 per transaction (EU)

**Integration**:
```dart
// Already implemented in PlombiPro!
// See: lib/services/stripe_service.dart

// Usage example:
final stripeService = StripeService();
await stripeService.createPaymentIntent(
  amount: 17100, // 171.00 EUR in cents
  currency: 'eur',
  description: 'Facture FAC-2025-001',
);
```

**Features to Add**:
- Payment links in invoices
- Subscription management
- Refund processing
- Payment analytics

**Already configured**: ✅

---

### 5. IPGeolocation API

**Purpose**: Automatic timezone detection, weather, currency

**Free Tier**: 1,000 requests/day

**Integration**:
```dart
// lib/services/ipgeolocation_service.dart
import 'package:dio/dio.dart';

class IPGeolocationService {
  static const String API_KEY = 'YOUR_API_KEY';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      final response = await _dio.get(
        'https://api.ipgeolocation.io/ipgeo',
        queryParameters: {
          'apiKey': API_KEY,
        },
      );
      return response.data;
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await _dio.get(
      'https://api.ipgeolocation.io/astronomy',
      queryParameters: {
        'apiKey': API_KEY,
        'location': city,
      },
    );
    return response.data;
  }
}
```

**Use Cases**:
- Auto-detect user timezone
- Show local weather
- Currency conversion (for exports)

**Sign up**: https://ipgeolocation.io/

---

### 6. ExchangeRatesAPI

**Purpose**: Multi-currency support for international clients

**Free Tier**: 1,500 requests/month

**Integration**:
```dart
// lib/services/currency_service.dart
import 'package:dio/dio.dart';

class CurrencyService {
  static const String API_KEY = 'YOUR_API_KEY';
  final Dio _dio = Dio();

  Future<double> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    try {
      final response = await _dio.get(
        'https://v6.exchangerate-api.com/v6/$API_KEY/pair/$from/$to/$amount',
      );
      return response.data['conversion_result'];
    } catch (e) {
      print('Error converting currency: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> getLatestRates(String baseCurrency) async {
    final response = await _dio.get(
      'https://v6.exchangerate-api.com/v6/$API_KEY/latest/$baseCurrency',
    );
    return Map<String, double>.from(response.data['conversion_rates']);
  }
}
```

**Use Cases**:
- Invoice in multiple currencies
- Price catalog conversions
- International client support

**Sign up**: https://www.exchangerate-api.com/

---

### 7. Twilio SendGrid (Alternative Email)

**Purpose**: More robust email service than EmailJS

**Free Tier**: 100 emails/day forever

**Integration**:
```dart
// lib/services/sendgrid_service.dart
import 'package:dio/dio.dart';

class SendGridService {
  static const String API_KEY = 'YOUR_SENDGRID_API_KEY';
  final Dio _dio = Dio();

  Future<void> sendEmail({
    required String toEmail,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      await _dio.post(
        'https://api.sendgrid.com/v3/mail/send',
        options: Options(
          headers: {
            'Authorization': 'Bearer $API_KEY',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'personalizations': [
            {
              'to': [
                {'email': toEmail}
              ],
            }
          ],
          'from': {'email': 'noreply@plombipro.fr'},
          'subject': subject,
          'content': [
            {
              'type': 'text/html',
              'value': htmlContent,
            }
          ],
        },
      );
    } catch (e) {
      print('SendGrid error: $e');
      rethrow;
    }
  }
}
```

**Use Cases**:
- Professional email sending
- Email tracking/analytics
- Higher deliverability

**Sign up**: https://sendgrid.com/

---

### 8. Cloudinary (Free Image Hosting)

**Purpose**: Job site photo storage and optimization

**Free Tier**: 25GB storage, 25GB bandwidth/month

**Integration**:
```dart
// lib/services/cloudinary_service.dart
import 'package:dio/dio.dart';
import 'dart:io';

class CloudinaryService {
  static const String CLOUD_NAME = 'YOUR_CLOUD_NAME';
  static const String UPLOAD_PRESET = 'YOUR_PRESET';
  final Dio _dio = Dio();

  Future<String> uploadJobSitePhoto(File imageFile) async {
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
      'upload_preset': UPLOAD_PRESET,
    });

    final response = await _dio.post(
      'https://api.cloudinary.com/v1_1/$CLOUD_NAME/image/upload',
      data: formData,
    );

    return response.data['secure_url'];
  }

  String getOptimizedUrl(String imageUrl, {int width = 800}) {
    return imageUrl.replaceFirst(
      '/upload/',
      '/upload/w_$width,q_auto,f_auto/',
    );
  }
}
```

**Use Cases**:
- Store job site photos
- Automatic image optimization
- CDN delivery (fast loading)
- Image transformations

**Sign up**: https://cloudinary.com/

---

## 🔧 Integration Best Practices

### 1. API Key Management

Store API keys securely using flutter_dotenv:

```dart
// .env file (add to .gitignore!)
OPENWEATHER_API_KEY=your_key_here
GOOGLE_MAPS_API_KEY=your_key_here
EMAILJS_PUBLIC_KEY=your_key_here
```

```dart
// lib/config/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get openWeatherKey => dotenv.env['OPENWEATHER_API_KEY']!;
  static String get googleMapsKey => dotenv.env['GOOGLE_MAPS_API_KEY']!;
  static String get emailJsKey => dotenv.env['EMAILJS_PUBLIC_KEY']!;
}
```

### 2. Error Handling

Always implement proper error handling:

```dart
try {
  final result = await apiService.fetchData();
  return result;
} on DioException catch (e) {
  if (e.response?.statusCode == 429) {
    throw Exception('API rate limit exceeded. Please try again later.');
  }
  throw Exception('API error: ${e.message}');
} catch (e) {
  throw Exception('Unexpected error: $e');
}
```

### 3. Caching

Reduce API calls with caching:

```dart
// lib/services/cached_weather_service.dart
import 'package:shared_preferences.dart';

class CachedWeatherService {
  Future<Weather?> getCachedWeather(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('weather_$city');
    final cacheTime = prefs.getInt('weather_time_$city') ?? 0;

    // Cache for 30 minutes
    if (cachedData != null && DateTime.now().millisecondsSinceEpoch - cacheTime < 1800000) {
      return Weather.fromJson(jsonDecode(cachedData));
    }
    return null;
  }
}
```

### 4. Rate Limiting

Track API usage to avoid hitting limits:

```dart
class ApiRateLimiter {
  int _callsToday = 0;
  DateTime _lastReset = DateTime.now();

  bool canMakeCall(int dailyLimit) {
    if (!_isSameDay(_lastReset, DateTime.now())) {
      _callsToday = 0;
      _lastReset = DateTime.now();
    }

    if (_callsToday >= dailyLimit) {
      return false;
    }

    _callsToday++;
    return true;
  }
}
```

## 📊 Cost Tracking

### Monthly API Costs (Assuming Average Usage)

| Service | Free Tier | Expected Usage | Overage Cost |
|---------|-----------|----------------|--------------|
| OpenWeatherMap | 1,000/day | ~200/day | €0.00 |
| Google Maps | $200 credit | ~5,000 loads | €0.00 |
| EmailJS | 200/month | ~150/month | €0.00 |
| Stripe | 1.4% + €0.25 | Per transaction | Variable |
| IPGeolocation | 1,000/day | ~50/day | €0.00 |
| ExchangeRates | 1,500/month | ~100/month | €0.00 |
| **TOTAL** | **FREE** | **Under limits** | **€0.00** |

## 🚀 Implementation Roadmap

### Phase 1: Essential (Week 1)
- [x] Stripe payments (already done)
- [ ] EmailJS for quotes/invoices
- [ ] OpenWeatherMap for job sites

### Phase 2: Enhancement (Week 2)
- [ ] Google Maps integration
- [ ] Cloudinary for photo storage
- [ ] IPGeolocation for timezone

### Phase 3: Advanced (Week 3)
- [ ] Currency conversion
- [ ] SendGrid upgrade
- [ ] Advanced weather alerts

## 📱 Example: Complete Weather Integration

```dart
// lib/widgets/job_site_weather_card.dart
import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../widgets/glassmorphic/glass_card.dart';

class JobSiteWeatherCard extends StatefulWidget {
  final double latitude;
  final double longitude;

  @override
  _JobSiteWeatherCardState createState() => _JobSiteWeatherCardState();
}

class _JobSiteWeatherCardState extends State<JobSiteWeatherCard> {
  Weather? _weather;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weatherService = WeatherService();
      final weather = await weatherService.getWeatherForJobSite(
        widget.latitude,
        widget.longitude,
      );
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return GlassCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_weather == null) {
      return GlassCard(
        child: Text('Météo non disponible'),
      );
    }

    return GlassCard(
      color: _getWeatherColor(),
      child: Row(
        children: [
          Icon(_getWeatherIcon(), size: 48, color: Colors.white),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_weather!.temperature?.celsius?.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _weather!.weatherDescription ?? '',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon() {
    final condition = _weather!.weatherMain?.toLowerCase() ?? '';
    if (condition.contains('rain')) return Icons.umbrella;
    if (condition.contains('cloud')) return Icons.cloud;
    if (condition.contains('clear')) return Icons.wb_sunny;
    return Icons.wb_cloudy;
  }

  Color _getWeatherColor() {
    final condition = _weather!.weatherMain?.toLowerCase() ?? '';
    if (condition.contains('rain')) return Color(0xFF5C6BC0);
    if (condition.contains('cloud')) return Color(0xFF78909C);
    return Color(0xFFFFB74D);
  }
}
```

## 🎯 Success Metrics

Track these metrics after integration:

- **Email delivery rate**: Target >95%
- **API error rate**: Target <1%
- **Average response time**: Target <500ms
- **Cost per user**: Target €0/month
- **User satisfaction**: Measure through feedback

## 📞 Support Resources

- OpenWeatherMap: https://openweathermap.org/faq
- Google Maps: https://developers.google.com/maps/support
- EmailJS: https://www.emailjs.com/docs/
- Stripe: https://stripe.com/docs
- Cloudinary: https://cloudinary.com/documentation

---

**Last Updated**: January 2025
**Maintained by**: PlombiPro Development Team
