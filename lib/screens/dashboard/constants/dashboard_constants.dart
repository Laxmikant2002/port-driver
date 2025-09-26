/// Modern dashboard constants optimized for Uber-style design
class DashboardConstants {
  // 🗺️ Map Configuration (Optimized for Indian cities)
  static const double defaultZoom = 15.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 10.0;
  static const double cityZoom = 12.0;
  
  // 📍 Nanded, Maharashtra Coordinates (Primary delivery area)
  static const double nandedLat = 19.1536;
  static const double nandedLng = 77.3105;
  static const double mumbaiLat = 19.0760;
  static const double mumbaiLng = 72.8777;
  static const double delhiLat = 28.7041;
  static const double delhiLng = 77.1025;
  static const double bangaloreLat = 12.9716;
  static const double bangaloreLng = 77.5946;
  
  // Legacy support for old constant names
  static const double mumbaiBoundaryLat = nandedLat;
  static const double mumbaiBoundaryLng = nandedLng;
  
  // 🎨 Modern UI Layout (Uber-inspired proportions)
  static const double mapHeightRatio = 0.75; // 75% of screen (more map-centric)
  static const double headerHeightRatio = 0.08; // 8% of screen (compact header)
  static const double bottomBarHeightRatio = 0.30; // 30% of screen (more info)
  
  // ⚡ Animation Durations (Smooth & Fast)
  static const Duration pulseAnimationDuration = Duration(seconds: 2);
  static const Duration slideAnimationDuration = Duration(milliseconds: 600);
  static const Duration statusTransitionDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);
  
  // 📏 Modern Spacing & Sizing
  static const double defaultPadding = 16.0;
  static const double compactPadding = 12.0;
  static const double borderRadius = 16.0; // More rounded (modern)
  static const double cardBorderRadius = 20.0; // Even more rounded
  static const double avatarSize = 48.0; // Larger avatar
  static const double pulseIndicatorSize = 80.0; // Larger pulse effect
  
  // 🔥 Nanded Area Hotspots (High-demand delivery zones)
  static const List<Map<String, dynamic>> hotspots = [
    {
      'name': 'Nanded City Center',
      'nameHindi': 'नांदेड सिटी सेंटर',
      'distance': '5 min',
      'earning': '₹450/hr',
      'demand': 'high',
      'type': 'business',
      'surge': '1.3x',
      'color': 0xFFF59E0B, // Amber for high demand
      'icon': 'business',
      'evCharging': true,
    },
    {
      'name': 'Mahur Road',
      'nameHindi': 'महूर रोड',
      'distance': '8 min', 
      'earning': '₹400/hr',
      'demand': 'high',
      'type': 'residential',
      'surge': '1.2x',
      'color': 0xFF10B981, // Green for medium-high demand
      'icon': 'home',
      'evCharging': true,
    },
    {
      'name': 'Airport Road',
      'nameHindi': 'एयरपोर्ट रोड',
      'distance': '12 min',
      'earning': '₹500/hr', 
      'demand': 'high',
      'type': 'business',
      'surge': '1.4x',
      'color': 0xFFF59E0B, // Amber for high demand
      'icon': 'business',
      'evCharging': false,
    },
    {
      'name': 'Vishnupuri',
      'nameHindi': 'विष्णुपुरी',
      'distance': '6 min',
      'earning': '₹380/hr',
      'demand': 'medium',
      'type': 'residential',
      'surge': '1.1x',
      'color': 0xFF3B82F6, // Blue for tech areas
      'icon': 'home',
      'evCharging': true,
    },
    {
      'name': 'Shivaji Nagar',
      'nameHindi': 'शिवाजी नगर',
      'distance': '4 min',
      'earning': '₹420/hr',
      'demand': 'medium',
      'type': 'residential',
      'surge': '1.0x',
      'color': 0xFF10B981, // Green for medium demand
      'icon': 'home',
      'evCharging': false,
    },
    {
      'name': 'Gandhi Chowk',
      'nameHindi': 'गांधी चौक',
      'distance': '3 min',
      'earning': '₹350/hr',
      'demand': 'medium',
      'type': 'residential',
      'surge': '1.0x',
      'color': 0xFF10B981, // Green for medium demand
      'icon': 'home',
      'evCharging': true,
    },
  ];
  
  // Status messages (English)
  static const String onlineStatusText = 'You\'re Online';
  static const String offlineStatusText = 'You\'re Offline';
  static const String goOnlinePrompt = 'Ready to earn? Go online to start receiving delivery requests';
  static const String busyAreasTitle = 'Busy Areas Nearby';
  static const String highDemandAreaTitle = 'High Demand Area';
  
  // Status messages (Hindi)
  static const String onlineStatusTextHindi = 'आप ऑनलाइन हैं';
  static const String offlineStatusTextHindi = 'आप ऑफलाइन हैं';
  static const String goOnlinePromptHindi = 'कमाई के लिए तैयार? डिलीवरी रिक्वेस्ट पाने के लिए ऑनलाइन जाएं';
  static const String busyAreasTitleHindi = 'पास में व्यस्त क्षेत्र';
  static const String highDemandAreaTitleHindi = 'उच्च मांग वाला क्षेत्र';
  
  // Button texts (English)
  static const String goOnlineButtonText = 'Go Online';
  static const String goOfflineButtonText = 'Go Offline';
  
  // Button texts (Hindi)
  static const String goOnlineButtonTextHindi = 'ऑनलाइन जाएं';
  static const String goOfflineButtonTextHindi = 'ऑफलाइन जाएं';
  
  // Earnings (English)
  static const String todaysEarningsTitle = 'Today\'s Earnings';
  static const String tripsCompletedTitle = 'Trips Completed';
  static const String weeklyEarningsTitle = 'Weekly Earnings';
  static const String ratingTitle = 'Rating';
  
  // Earnings (Hindi)
  static const String todaysEarningsTitleHindi = 'आज की कमाई';
  static const String tripsCompletedTitleHindi = 'ट्रिप्स पूरी';
  static const String weeklyEarningsTitleHindi = 'साप्ताहिक कमाई';
  static const String ratingTitleHindi = 'रेटिंग';
  
  // App branding
  static const String appTitle = 'Electric Loading Gadi';
  static const String appTitleHindi = 'इलेक्ट्रिक लोडिंग गाड़ी';
  static const String dashboardSubtitle = 'Nanded Delivery Dashboard';
  static const String dashboardSubtitleHindi = 'नांदेड डिलीवरी डैशबोर्ड';
  
  // Indian-specific features
  static const List<String> indianCities = [
    'Nanded', 'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Kolkata', 'Pune', 'Ahmedabad'
  ];
  
  static const Map<String, String> cityCoordinates = {
    'Nanded': '19.1536,77.3105',
    'Mumbai': '19.0760,72.8777',
    'Delhi': '28.7041,77.1025',
    'Bangalore': '12.9716,77.5946',
    'Hyderabad': '17.3850,78.4867',
    'Chennai': '13.0827,80.2707',
    'Kolkata': '22.5726,88.3639',
    'Pune': '18.5204,73.8567',
    'Ahmedabad': '23.0225,72.5714'
  };
  
  // Festival and surge multipliers
  static const Map<String, double> festivalMultipliers = {
    'Diwali': 1.5,
    'Holi': 1.3,
    'Dussehra': 1.2,
    'Eid': 1.2,
    'Christmas': 1.1,
    'New Year': 1.4
  };
  
  // Peak hours for different cities
  static const Map<String, List<String>> peakHours = {
    'Nanded': ['7:30-10:30', '17:30-20:30'],
    'Mumbai': ['7:00-10:00', '17:00-20:00'],
    'Delhi': ['8:00-11:00', '18:00-21:00'],
    'Bangalore': ['8:30-11:30', '18:30-21:30'],
    'Hyderabad': ['8:00-11:00', '18:00-21:00'],
    'Chennai': ['8:00-11:00', '18:00-21:00'],
    'Kolkata': ['8:00-11:00', '18:00-21:00'],
    'Pune': ['8:00-11:00', '18:00-21:00'],
    'Ahmedabad': ['8:00-11:00', '18:00-21:00']
  };
  
  // ⚡ EV Charging Stations (Nanded Area)
  static const List<Map<String, dynamic>> chargingStations = [
    {
      'name': 'Nanded Railway Station',
      'nameHindi': 'नांदेड रेलवे स्टेशन',
      'type': 'Fast Charging',
      'availability': 'Available',
      'distance': '2.1 km',
      'rating': 4.6,
      'price': '₹12/kWh',
      'connectors': ['CCS', 'CHAdeMO'],
      'power': '50kW',
      'color': 0xFF10B981, // Green for available
    },
    {
      'name': 'City Center Mall',
      'nameHindi': 'सिटी सेंटर मॉल',
      'type': 'Standard Charging',
      'availability': 'Available',
      'distance': '1.5 km',
      'rating': 4.3,
      'price': '₹10/kWh',
      'connectors': ['Type 2'],
      'power': '22kW',
      'color': 0xFF10B981, // Green for available
    },
    {
      'name': 'Airport Road Hub',
      'nameHindi': 'एयरपोर्ट रोड हब',
      'type': 'Fast Charging',
      'availability': 'Busy',
      'distance': '3.8 km',
      'rating': 4.5,
      'price': '₹15/kWh',
      'connectors': ['CCS', 'Type 2'],
      'power': '60kW',
      'color': 0xFFF59E0B, // Amber for busy
    },
    {
      'name': 'Vishnupuri EV Center',
      'nameHindi': 'विष्णुपुरी ईवी सेंटर',
      'type': 'Ultra Fast',
      'availability': 'Available',
      'distance': '2.8 km',
      'rating': 4.8,
      'price': '₹18/kWh',
      'connectors': ['CCS', 'CHAdeMO', 'Type 2'],
      'power': '150kW',
      'color': 0xFF10B981, // Green for available
    },
  ];
  
  // 🌙 Modern Dark Map Style (Optimized for night driving & EV theme)
  static const String darkMapStyle = '''[
    {
      "featureType": "all",
      "elementType": "geometry",
      "stylers": [{"color": "#1a1a1a"}]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#1a1a1a"}]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#06b6d4"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#3b82f6"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [{"color": "#2d2d2d"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#06b6d4"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#2d2d2d"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#1a1a1a"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#3b82f6"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#1e40af"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [{"color": "#2d2d2d"}]
    },
    {
      "featureType": "transit.station",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#06b6d4"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#1a1a1a"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#3b82f6"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#1a1a1a"}]
    }
  ]''';

  // 🌅 Light Map Style (For daytime use)
  static const String lightMapStyle = '''[
    {
      "featureType": "all",
      "elementType": "geometry",
      "stylers": [{"color": "#f8fafc"}]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#0f172a"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#3b82f6"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#e6f2ff"}]
    }
  ]''';
}