// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class Kiosk {
//   final String id;
//   final String kioskNumber;
//   final String location;
//   final String status;

//   Kiosk({
//     required this.id,
//     required this.kioskNumber,
//     required this.location,
//     required this.status,
//   });

//   factory Kiosk.fromJson(Map<String, dynamic> json) {
//     return Kiosk(
//       id: json['_id'] ?? '',
//       kioskNumber: json['kioskNumber'] ?? '',
//       location: json['location'] ?? '',
//       status: json['status'] ?? 'Unknown',
//     );
//   }
// }

// class Rewards extends StatefulWidget {
//   const Rewards({super.key});

//   @override
//   State<Rewards> createState() => _RewardsState();
// }

// class _RewardsState extends State<Rewards> {
//   List<Kiosk> kiosks = [];
//   Kiosk? selectedKiosk;
//   bool isLoading = true;
//   bool showKioskList = false;
//   late WebViewController webViewController;

//   // Predefined coordinates for locations (same as your web app)
//   final Map<String, List<double>> kioskCoordinates = {
//     "Makati City": [14.5547, 121.0244],
//     "Pasig City": [14.5608, 121.0776],
//     "Taguig City": [14.5306, 121.0575],
//   };

//   @override
//   void initState() {
//     super.initState();
//     initializeWebView();
//     fetchKiosks();
//   }

//   void initializeWebView() {
//     webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (String url) {
//             // Map is ready, update with kiosks data
//             if (kiosks.isNotEmpty) {
//               updateMapWithKiosks();
//             }
//           },
//         ),
//       );
//   }

//   Future<void> fetchKiosks() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://ecollect-server.onrender.com/api/admin/kiosks'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         List<dynamic> kioskData = data['data'];
        
//         setState(() {
//           kiosks = kioskData.map((data) => Kiosk.fromJson(data)).toList();
//           if (kiosks.isNotEmpty) {
//             selectedKiosk = kiosks.first;
//           }
//           isLoading = false;
//         });

//         // Load the map HTML
//         loadMapHtml();
        
//       } else {
//         throw Exception('Failed to load kiosks: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching kiosks: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void loadMapHtml() {
//     String mapHtml = generateMapHtml();
//     webViewController.loadHtmlString(mapHtml);
//   }

//   String generateMapHtml() {
//     String markersJson = kiosks.map((kiosk) {
//       List<double> coords = kioskCoordinates[kiosk.location] ?? [14.5995, 120.9842];
//       return '''
//         {
//           "id": "${kiosk.id}",
//           "kioskNumber": "${kiosk.kioskNumber}",
//           "location": "${kiosk.location}",
//           "status": "${kiosk.status}",
//           "coords": [${coords[0]}, ${coords[1]}]
//         }
//       ''';
//     }).join(',');

//     List<double> initialCoords = selectedKiosk != null 
//         ? (kioskCoordinates[selectedKiosk!.location] ?? [14.5995, 120.9842])
//         : [14.5995, 120.9842];

//     return '''
// <!DOCTYPE html>
// <html>
// <head>
//     <meta name="viewport" content="width=device-width, initial-scale=1.0">
//     <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
//     <style>
//         body { margin: 0; padding: 0; }
//         #map { height: 100vh; width: 100vw; }
//         .custom-marker {
//             width: 30px;
//             height: 30px;
//             border-radius: 50%;
//             border: 2px solid white;
//             display: flex;
//             align-items: center;
//             justify-content: center;
//             font-size: 14px;
//             color: white;
//             font-weight: bold;
//         }
//         .marker-active { background-color: #4CAF50; }
//         .marker-maintenance { background-color: #FF9800; }
//         .marker-offline { background-color: #f44336; }
//         .marker-unknown { background-color: #9E9E9E; }
//     </style>
// </head>
// <body>
//     <div id="map"></div>
    
//     <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
//     <script>
//         const kiosks = [$markersJson];
        
//         const map = L.map('map').setView([${initialCoords[0]}, ${initialCoords[1]}], 13);
        
//         L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
//             attribution: '© OpenStreetMap contributors'
//         }).addTo(map);

//         const markers = {};
        
//         kiosks.forEach(kiosk => {
//             const statusClass = 'marker-' + kiosk.status.toLowerCase();
            
//             const customIcon = L.divIcon({
//                 html: '<div class="custom-marker ' + statusClass + '"></div>',
//                 className: 'custom-div-icon',
//                 iconSize: [30, 30],
//                 iconAnchor: [15, 15]
//             });
            
//             const marker = L.marker(kiosk.coords, { icon: customIcon }).addTo(map);
            
//             marker.bindPopup(
//                 '<strong>Kiosk #' + kiosk.kioskNumber + '</strong><br>' +
//                 kiosk.location + '<br>' +
//                 'Status: <span style="color: ' + getStatusColor(kiosk.status) + '">' + kiosk.status + '</span>'
//             );
            
//             marker.on('click', function() {
//                 window.flutter_inappwebview.callHandler('onKioskSelected', kiosk.id);
//             });
            
//             markers[kiosk.id] = marker;
//         });
        
//         function getStatusColor(status) {
//             switch(status.toLowerCase()) {
//                 case 'active': return '#4CAF50';
//                 case 'maintenance': return '#FF9800';
//                 case 'offline': return '#f44336';
//                 default: return '#9E9E9E';
//             }
//         }
        
//         function focusKiosk(kioskId) {
//             const kiosk = kiosks.find(k => k.id === kioskId);
//             if (kiosk && markers[kioskId]) {
//                 map.setView(kiosk.coords, 15);
//                 markers[kioskId].openPopup();
//             }
//         }
        
//         // Expose function to Flutter
//         window.focusKiosk = focusKiosk;
//     </script>
// </body>
// </html>
//     ''';
//   }

//   void updateMapWithKiosks() {
//     if (selectedKiosk != null) {
//       webViewController.runJavaScript('focusKiosk("${selectedKiosk!.id}")');
//     }
//   }

//   void selectKiosk(Kiosk kiosk) {
//     setState(() {
//       selectedKiosk = kiosk;
//       showKioskList = false;
//     });
//     webViewController.runJavaScript('focusKiosk("${kiosk.id}")');
//   }

//   Color getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Colors.green;
//       case 'maintenance':
//         return Colors.orange;
//       case 'offline':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget buildKioskList() {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.4,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'All Kiosks',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     setState(() {
//                       showKioskList = false;
//                     });
//                   },
//                   icon: Icon(Icons.close),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: kiosks.length,
//               itemBuilder: (context, index) {
//                 final kiosk = kiosks[index];
//                 final isSelected = selectedKiosk?.id == kiosk.id;
                
//                 return Container(
//                   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: isSelected ? Color(0xff92d400).withOpacity(0.1) : Colors.transparent,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: ListTile(
//                     onTap: () => selectKiosk(kiosk),
//                     leading: Container(
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: getStatusColor(kiosk.status),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     title: Text(
//                       'Kiosk #${kiosk.kioskNumber}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                     subtitle: Text(
//                       kiosk.location,
//                       style: TextStyle(fontFamily: 'Poppins'),
//                     ),
//                     trailing: Text(
//                       kiosk.status,
//                       style: TextStyle(
//                         color: getStatusColor(kiosk.status),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildKioskInfo() {
//     if (selectedKiosk == null) return SizedBox.shrink();
    
//     return Positioned(
//       top: 120,
//       left: 16,
//       right: 16,
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 12,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: getStatusColor(selectedKiosk!.status),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   'Kiosk #${selectedKiosk!.kioskNumber}',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 4),
//             Text(
//               selectedKiosk!.location,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Status: ${selectedKiosk!.status}',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: getStatusColor(selectedKiosk!.status),
//                 fontWeight: FontWeight.w500,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           SizedBox(height: 20),
//           AppBar(
//             automaticallyImplyLeading: false,
//             backgroundColor: Colors.white,
//             title: Center(
//               child: Text(
//                 'Kiosk Finder',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 40,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//             ),
//             actions: [
//               IconButton(
//                 onPressed: () {
//                   setState(() {
//                     showKioskList = !showKioskList;
//                   });
//                 },
//                 icon: Icon(Icons.list, size: 28),
//               ),
//             ],
//           ),
//           Expanded(
//             child: isLoading
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(
//                           color: Color(0xff92d400),
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'Loading kiosks...',
//                           style: TextStyle(
//                             fontFamily: 'Poppins',
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Stack(
//                     children: [
//                       WebViewWidget(controller: webViewController),
//                       buildKioskInfo(),
//                       if (showKioskList)
//                         Positioned(
//                           bottom: 0,
//                           left: 0,
//                           right: 0,
//                           child: buildKioskList(),
//                         ),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Kiosk {
  final String id;
  final String kioskNumber;
  final String location;
  final String status;
  final String? description;
  final Coordinates coordinates;
  final Capacity? capacity;
  final OperatingHours? operatingHours;
  final DateTime? createdAt;

  Kiosk({
    required this.id,
    required this.kioskNumber,
    required this.location,
    required this.status,
    this.description,
    required this.coordinates,
    this.capacity,
    this.operatingHours,
    this.createdAt,
  });

  factory Kiosk.fromJson(Map<String, dynamic> json) {
    return Kiosk(
      id: json['_id'] ?? '',
      kioskNumber: json['kioskNumber'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      description: json['description'],
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
      capacity: json['capacity'] != null ? Capacity.fromJson(json['capacity']) : null,
      operatingHours: json['operatingHours'] != null 
          ? OperatingHours.fromJson(json['operatingHours']) 
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  // Get capacity percentage
  int get capacityPercentage {
    if (capacity == null || capacity!.max == 0) return 0;
    return ((capacity!.current / capacity!.max) * 100).round();
  }

  // Check if kiosk is open now
  bool get isOpenNow {
    if (operatingHours == null) return true;
    final now = TimeOfDay.now();
    final open = _parseTime(operatingHours!.open);
    final close = _parseTime(operatingHours!.close);
    
    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;
    
    return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}

class Capacity {
  final int current;
  final int max;

  Capacity({required this.current, required this.max});

  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(
      current: json['current'] ?? 0,
      max: json['max'] ?? 100,
    );
  }
}

class OperatingHours {
  final String open;
  final String close;

  OperatingHours({required this.open, required this.close});

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      open: json['open'] ?? '06:00',
      close: json['close'] ?? '22:00',
    );
  }
}

class KioskApiService {
  static const String baseUrl = 'https://ecollect-server.onrender.com/api/admin';
  
  static Future<List<Kiosk>> getAllKiosks({
    int page = 1,
    int limit = 50,
    String search = '',
    String status = 'all',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': search,
        'status': status,
      };
      
      final uri = Uri.parse('$baseUrl/kiosks').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> kioskData = data['data'];
          return kioskData.map((data) => Kiosk.fromJson(data)).toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load kiosks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching kiosks: $e');
      rethrow;
    }
  }

  static Future<List<Kiosk>> getNearbyKiosks({
    required double lat,
    required double lng,
    double radius = 10,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/kiosks/nearby').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> kioskData = data['data'];
          return kioskData.map((data) => Kiosk.fromJson(data)).toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load nearby kiosks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nearby kiosks: $e');
      rethrow;
    }
  }
}

class Rewards extends StatefulWidget {
  const Rewards({super.key});

  @override
  State<Rewards> createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> with TickerProviderStateMixin {
  List<Kiosk> kiosks = [];
  List<Kiosk> filteredKiosks = [];
  Kiosk? selectedKiosk;
  bool isLoading = true;
  bool showKioskList = false;
  bool showSearch = false;
  String searchQuery = '';
  String statusFilter = 'all';
  String? error;
  late WebViewController webViewController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);
    
    initializeWebView();
    fetchKiosks();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterKiosk',
        onMessageReceived: (JavaScriptMessage message) {
          final kioskId = message.message;
          final kiosk = kiosks.firstWhere(
            (k) => k.id == kioskId,
            orElse: () => kiosks.first,
          );
          selectKiosk(kiosk);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _fadeController.forward();
            if (kiosks.isNotEmpty) {
              updateMapWithKiosks();
            }
          },
        ),
      );
  }

  Future<void> fetchKiosks() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final fetchedKiosks = await KioskApiService.getAllKiosks(
        limit: 100, // Get more kiosks for better coverage
      );
      
      setState(() {
        kiosks = fetchedKiosks;
        filteredKiosks = fetchedKiosks;
        if (kiosks.isNotEmpty) {
          selectedKiosk = kiosks.first;
        }
        isLoading = false;
      });

      if (kiosks.isNotEmpty) {
        loadMapHtml();
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void filterKiosks() {
    setState(() {
      filteredKiosks = kiosks.where((kiosk) {
        final matchesSearch = searchQuery.isEmpty ||
            kiosk.kioskNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
            kiosk.location.toLowerCase().contains(searchQuery.toLowerCase());
        
        final matchesStatus = statusFilter == 'all' || 
            kiosk.status.toLowerCase() == statusFilter.toLowerCase();
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void loadMapHtml() {
    String mapHtml = generateMapHtml();
    webViewController.loadHtmlString(mapHtml);
  }

  String generateMapHtml() {
    String markersJson = kiosks.map((kiosk) {
      return '''
        {
          "id": "${kiosk.id}",
          "kioskNumber": "${kiosk.kioskNumber}",
          "location": "${kiosk.location}",
          "status": "${kiosk.status}",
          "coords": [${kiosk.coordinates.latitude}, ${kiosk.coordinates.longitude}],
          "capacity": ${kiosk.capacity != null ? kiosk.capacityPercentage : 0},
          "isOpen": ${kiosk.isOpenNow},
          "description": "${kiosk.description ?? ''}"
        }
      ''';
    }).join(',');

    List<double> initialCoords = selectedKiosk != null 
        ? [selectedKiosk!.coordinates.latitude, selectedKiosk!.coordinates.longitude]
        : [14.5995, 120.9842]; // Default to Manila

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        body { margin: 0; padding: 0; font-family: 'Roboto', sans-serif; }
        #map { height: 100vh; width: 100vw; }
        .custom-marker {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            border: 3px solid white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            color: white;
            font-weight: bold;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            position: relative;
        }
        .marker-active { background: linear-gradient(135deg, #4CAF50, #45a049); }
        .marker-inactive { background: linear-gradient(135deg, #9E9E9E, #757575); }
        .marker-maintenance { background: linear-gradient(135deg, #FF9800, #f57c00); }
        .marker-full {
            background: linear-gradient(135deg, #f44336, #d32f2f);
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }
        
        .capacity-ring {
            position: absolute;
            top: -2px;
            left: -2px;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            border: 2px solid transparent;
        }
        
        .capacity-high { border-color: #f44336; }
        .capacity-medium { border-color: #FF9800; }
        .capacity-low { border-color: #4CAF50; }
        
        .leaflet-popup-content-wrapper {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        
        .leaflet-popup-content {
            margin: 16px;
            font-size: 14px;
            line-height: 1.4;
        }
        
        .popup-header {
            font-weight: bold;
            font-size: 16px;
            margin-bottom: 8px;
            color: #333;
        }
        
        .popup-status {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .status-active { background: #e8f5e8; color: #2e7d32; }
        .status-inactive { background: #f5f5f5; color: #616161; }
        .status-maintenance { background: #fff3e0; color: #ef6c00; }
        
        .capacity-bar {
            width: 100%;
            height: 6px;
            background: #e0e0e0;
            border-radius: 3px;
            overflow: hidden;
            margin: 8px 0;
        }
        
        .capacity-fill {
            height: 100%;
            border-radius: 3px;
            transition: width 0.3s ease;
        }
    </style>
</head>
<body>
    <div id="map"></div>
    
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        const kiosks = [$markersJson];
        
        const map = L.map('map').setView([${initialCoords[0]}, ${initialCoords[1]}], 13);
        
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors',
            maxZoom: 19
        }).addTo(map);

        const markers = {};
        
        kiosks.forEach(kiosk => {
            const capacity = kiosk.capacity || 0;
            let statusClass = 'marker-' + kiosk.status.toLowerCase();
            let capacityClass = '';
            
            if (capacity > 80) {
                statusClass = 'marker-full';
                capacityClass = 'capacity-high';
            } else if (capacity > 50) {
                capacityClass = 'capacity-medium';
            } else {
                capacityClass = 'capacity-low';
            }
            
            const customIcon = L.divIcon({
                html: '<div class="custom-marker ' + statusClass + '"><div class="capacity-ring ' + capacityClass + '"></div>' + 
                      kiosk.kioskNumber.replace('KIOSK', '') + '</div>',
                className: 'custom-div-icon',
                iconSize: [36, 36],
                iconAnchor: [18, 18]
            });
            
            const marker = L.marker(kiosk.coords, { icon: customIcon }).addTo(map);
            
            const capacityFillColor = capacity > 80 ? '#f44336' : capacity > 50 ? '#FF9800' : '#4CAF50';
            
            marker.bindPopup(
                '<div class="popup-header">Kiosk #' + kiosk.kioskNumber + '</div>' +
                '<div style="color: #666; margin-bottom: 8px;">' + kiosk.location + '</div>' +
                '<div style="margin-bottom: 8px;">' +
                '<span class="popup-status status-' + kiosk.status.toLowerCase() + '">' + kiosk.status + '</span>' +
                '</div>' +
                '<div>Capacity: ' + capacity + '%</div>' +
                '<div class="capacity-bar">' +
                '<div class="capacity-fill" style="width: ' + capacity + '%; background: ' + capacityFillColor + ';"></div>' +
                '</div>' +
                '<div style="color: #666; font-size: 12px; margin-top: 4px;">' +
                (kiosk.isOpen ? '🟢 Open Now' : '🔴 Closed') +
                '</div>' +
                (kiosk.description ? '<div style="margin-top: 8px; font-size: 12px; color: #888;">' + kiosk.description + '</div>' : '')
            );
            
            marker.on('click', function() {
                FlutterKiosk.postMessage(kiosk.id);
            });
            
            markers[kiosk.id] = marker;
        });
        
        function focusKiosk(kioskId) {
            const kiosk = kiosks.find(k => k.id === kioskId);
            if (kiosk && markers[kioskId]) {
                map.setView(kiosk.coords, 16);
                setTimeout(() => {
                    markers[kioskId].openPopup();
                }, 300);
            }
        }
        
        window.focusKiosk = focusKiosk;
    </script>
</body>
</html>
    ''';
  }

  void updateMapWithKiosks() {
    if (selectedKiosk != null) {
      webViewController.runJavaScript('focusKiosk("${selectedKiosk!.id}")');
    }
  }

  void selectKiosk(Kiosk kiosk) {
    setState(() {
      selectedKiosk = kiosk;
      showKioskList = false;
    });
    _slideController.reverse();
    webViewController.runJavaScript('focusKiosk("${kiosk.id}")');
  }

  void toggleKioskList() {
    setState(() {
      showKioskList = !showKioskList;
    });
    if (showKioskList) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'maintenance':
        return const Color(0xFFFF9800);
      case 'inactive':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'maintenance':
        return Icons.build_circle;
      case 'inactive':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              filterKiosks();
            },
            decoration: InputDecoration(
              hintText: 'Search kiosks...',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[600],
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                        filterKiosks();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: statusFilter == 'all',
                  onSelected: (selected) {
                    setState(() {
                      statusFilter = 'all';
                    });
                    filterKiosks();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Active'),
                  selected: statusFilter == 'active',
                  onSelected: (selected) {
                    setState(() {
                      statusFilter = selected ? 'active' : 'all';
                    });
                    filterKiosks();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Maintenance'),
                  selected: statusFilter == 'maintenance',
                  onSelected: (selected) {
                    setState(() {
                      statusFilter = selected ? 'maintenance' : 'all';
                    });
                    filterKiosks();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Inactive'),
                  selected: statusFilter == 'inactive',
                  onSelected: (selected) {
                    setState(() {
                      statusFilter = selected ? 'inactive' : 'all';
                    });
                    filterKiosks();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildKioskList() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kiosks (${filteredKiosks.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showSearch = !showSearch;
                          });
                        },
                        icon: Icon(showSearch ? Icons.search_off : Icons.search),
                      ),
                      IconButton(
                        onPressed: toggleKioskList,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showSearch) buildSearchBar(),
            Expanded(
              child: ListView.builder(
                itemCount: filteredKiosks.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final kiosk = filteredKiosks[index];
                  final isSelected = selectedKiosk?.id == kiosk.id;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xff92d400).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: const Color(0xff92d400), width: 2)
                          : Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: ListTile(
                      onTap: () => selectKiosk(kiosk),
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: getStatusColor(kiosk.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          getStatusIcon(kiosk.status),
                          color: getStatusColor(kiosk.status),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        'Kiosk #${kiosk.kioskNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            kiosk.location,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(kiosk.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  kiosk.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (kiosk.capacity != null)
                                Text(
                                  '${kiosk.capacityPercentage}% Full',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              const Spacer(),
                              Icon(
                                kiosk.isOpenNow ? Icons.schedule : Icons.schedule_outlined,
                                color: kiosk.isOpenNow ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                kiosk.isOpenNow ? 'Open' : 'Closed',
                                style: TextStyle(
                                  color: kiosk.isOpenNow ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildKioskInfo() {
    if (selectedKiosk == null) return const SizedBox.shrink();
    
    return Positioned(
      top: 120,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getStatusColor(selectedKiosk!.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getStatusIcon(selectedKiosk!.status),
                      color: getStatusColor(selectedKiosk!.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kiosk #${selectedKiosk!.kioskNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          selectedKiosk!.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(selectedKiosk!.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      selectedKiosk!.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (selectedKiosk!.capacity != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.storage,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Capacity: ${selectedKiosk!.capacityPercentage}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: selectedKiosk!.capacityPercentage / 100,
                        backgroundColor: Colors.grey[300],
                        color: selectedKiosk!.capacityPercentage > 80
                            ? Colors.red
                            : selectedKiosk!.capacityPercentage > 50
                                ? Colors.orange
                                : Colors.green,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ],
              if (selectedKiosk!.operatingHours != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      selectedKiosk!.isOpenNow ? Icons.access_time : Icons.access_time_outlined,
                      color: selectedKiosk!.isOpenNow ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedKiosk!.operatingHours!.open} - ${selectedKiosk!.operatingHours!.close}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: selectedKiosk!.isOpenNow
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedKiosk!.isOpenNow ? 'OPEN' : 'CLOSED',
                        style: TextStyle(
                          color: selectedKiosk!.isOpenNow ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (selectedKiosk!.description != null && selectedKiosk!.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  selectedKiosk!.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load kiosks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Unknown error occurred',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: fetchKiosks,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff92d400),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xff92d400),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading kiosks...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Center(
              child: Text(
                'Kiosk Finder',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
            ),
            actions: [
              if (!isLoading && kiosks.isNotEmpty) ...[
                IconButton(
                  onPressed: fetchKiosks,
                  icon: const Icon(
                    Icons.refresh,
                    size: 28,
                    color: Colors.grey,
                  ),
                  tooltip: 'Refresh',
                ),
                IconButton(
                  onPressed: toggleKioskList,
                  icon: Icon(
                    showKioskList ? Icons.map : Icons.list,
                    size: 28,
                    color: Colors.grey,
                  ),
                  tooltip: showKioskList ? 'Show Map' : 'Show List',
                ),
              ],
            ],
          ),
          Expanded(
            child: isLoading
                ? buildLoadingState()
                : error != null
                    ? buildErrorState()
                    : kiosks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No kiosks found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check your internet connection and try again',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    fontFamily: 'Poppins',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: WebViewWidget(controller: webViewController),
                              ),
                              buildKioskInfo(),
                              if (showKioskList)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: buildKioskList(),
                                ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}