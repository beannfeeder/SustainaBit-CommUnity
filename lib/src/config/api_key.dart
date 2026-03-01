// This file holds the Google Maps API Key.
// API keys are loaded from the .env file for security.
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Load Google Maps API key from environment variables
String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
