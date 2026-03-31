import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

enum AppPage { home, services, serviceDetails, register, login, manageListings, requestService, admin }

class ServiceDefinition {
  final String title;
  final String shortDescription;
  final String details;
  final List<String> features;
  final String imageUrl;

  ServiceDefinition({
    required this.title,
    required this.shortDescription,
    required this.details,
    required this.features,
    required this.imageUrl,
  });
}

class User {
  final String? uid;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final bool isAdmin;
  final bool active;

  User({
    this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    this.isAdmin = false,
    this.active = true,
  });

  User copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    bool? isAdmin,
    bool? active,
  }) {
    return User(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      isAdmin: isAdmin ?? this.isAdmin,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'isAdmin': isAdmin,
      'active': active,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      active: map['active'] ?? true,
    );
  }
}

class CarListing {
  final String? id;
  final String title;
  final String status;
  final String approvalStatus;
  final String packageType;
  final bool isFeatured;
  final int listingDurationDays;
  final String make;
  final String model;
  final String year;
  final String price;
  final String pricePerDay;
  final String mileage;
  final String condition;
  final String transmission;
  final String fuelType;
  final String location;
  final String availability;
  final String features;
  final String pickupLocation;
  final String deliveryOption;
  final String description;
  final List<String> imageUrls;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final String? ownerUid;

  CarListing({
    this.id,
    required this.title,
    required this.status,
    required this.approvalStatus,
    required this.packageType,
    required this.isFeatured,
    required this.listingDurationDays,
    required this.make,
    required this.model,
    required this.year,
    required this.price,
    required this.pricePerDay,
    required this.mileage,
    required this.condition,
    required this.transmission,
    required this.fuelType,
    required this.location,
    required this.availability,
    required this.features,
    required this.pickupLocation,
    required this.deliveryOption,
    required this.description,
    required this.imageUrls,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    this.ownerUid,
  });

  CarListing copyWith({
    String? id,
    String? title,
    String? status,
    String? approvalStatus,
    String? packageType,
    bool? isFeatured,
    int? listingDurationDays,
    String? make,
    String? model,
    String? year,
    String? price,
    String? pricePerDay,
    String? mileage,
    String? condition,
    String? transmission,
    String? fuelType,
    String? location,
    String? availability,
    String? features,
    String? pickupLocation,
    String? deliveryOption,
    String? description,
    List<String>? imageUrls,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? ownerUid,
  }) {
    return CarListing(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      packageType: packageType ?? this.packageType,
      isFeatured: isFeatured ?? this.isFeatured,
      listingDurationDays: listingDurationDays ?? this.listingDurationDays,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      price: price ?? this.price,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      mileage: mileage ?? this.mileage,
      condition: condition ?? this.condition,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      features: features ?? this.features,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'approvalStatus': approvalStatus,
      'packageType': packageType,
      'isFeatured': isFeatured,
      'listingDurationDays': listingDurationDays,
      'make': make,
      'model': model,
      'year': year,
      'price': price,
      'pricePerDay': pricePerDay,
      'mileage': mileage,
      'condition': condition,
      'transmission': transmission,
      'fuelType': fuelType,
      'location': location,
      'availability': availability,
      'features': features,
      'pickupLocation': pickupLocation,
      'deliveryOption': deliveryOption,
      'description': description,
      'imageUrls': imageUrls,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerEmail': ownerEmail,
      'ownerUid': ownerUid,
    };
  }

  factory CarListing.fromMap(Map<String, dynamic> map, String id) {
    return CarListing(
      id: id,
      title: map['title'] ?? '',
      status: map['status'] ?? '',
      approvalStatus: map['approvalStatus'] ?? '',
      packageType: map['packageType'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      listingDurationDays: map['listingDurationDays'] ?? 0,
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? '',
      price: map['price'] ?? '',
      pricePerDay: map['pricePerDay'] ?? '',
      mileage: map['mileage'] ?? '',
      condition: map['condition'] ?? '',
      transmission: map['transmission'] ?? '',
      fuelType: map['fuelType'] ?? '',
      location: map['location'] ?? '',
      availability: map['availability'] ?? '',
      features: map['features'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      deliveryOption: map['deliveryOption'] ?? '',
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      ownerName: map['ownerName'] ?? '',
      ownerPhone: map['ownerPhone'] ?? '',
      ownerEmail: map['ownerEmail'] ?? '',
      ownerUid: map['ownerUid'],
    );
  }
}

class PaymentRecord {
  final String userEmail;
  final String packageName;
  final String amount;
  final String date;
  final String status;

  PaymentRecord({
    required this.userEmail,
    required this.packageName,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class ListingPackage {
  final String name;
  final String description;
  final String price;
  final int maxListings;
  final bool isFeatured;
  final int durationDays;

  ListingPackage({
    required this.name,
    required this.description,
    required this.price,
    required this.maxListings,
    required this.isFeatured,
    required this.durationDays,
  });
}

class ServiceRequest {
  final String? id;
  final String type;
  final String description;
  final String location;
  final String requesterName;
  final String requesterPhone;
  final String requesterEmail;
  final String? requesterUid;
  final String carDetails;
  final String preferredDateTime;
  final String assignedTo;
  final String status;

  ServiceRequest({
    this.id,
    required this.type,
    required this.description,
    required this.location,
    required this.requesterName,
    required this.requesterPhone,
    required this.requesterEmail,
    this.requesterUid,
    required this.carDetails,
    required this.preferredDateTime,
    required this.assignedTo,
    required this.status,
  });

  ServiceRequest copyWith({
    String? id,
    String? type,
    String? description,
    String? location,
    String? requesterName,
    String? requesterPhone,
    String? requesterEmail,
    String? requesterUid,
    String? carDetails,
    String? preferredDateTime,
    String? assignedTo,
    String? status,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      requesterEmail: requesterEmail ?? this.requesterEmail,
      requesterUid: requesterUid ?? this.requesterUid,
      carDetails: carDetails ?? this.carDetails,
      preferredDateTime: preferredDateTime ?? this.preferredDateTime,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'location': location,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'requesterEmail': requesterEmail,
      'requesterUid': requesterUid,
      'carDetails': carDetails,
      'preferredDateTime': preferredDateTime,
      'assignedTo': assignedTo,
      'status': status,
    };
  }

  factory ServiceRequest.fromMap(Map<String, dynamic> map, String id) {
    return ServiceRequest(
      id: id,
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterPhone: map['requesterPhone'] ?? '',
      requesterEmail: map['requesterEmail'] ?? '',
      requesterUid: map['requesterUid'],
      carDetails: map['carDetails'] ?? '',
      preferredDateTime: map['preferredDateTime'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      status: map['status'] ?? '',
    );
  }
}

bool _isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('main: Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Explicitly configure Firestore settings to be more robust
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    _isFirebaseInitialized = true;
    debugPrint('main: Firebase initialized successfully.');
  } catch (e) {
    debugPrint('main: Firebase initialization error: $e');
  }
  runApp(const GroundedCarsApp());
}

class GroundedCarsApp extends StatelessWidget {
  const GroundedCarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grounded Cars Ke | Discover and List Grounded Cars in Kenya Effortlessly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0081C9)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const GroundedCarsHomePage(),
    );
  }
}

class GroundedCarsHomePage extends StatefulWidget {
  const GroundedCarsHomePage({super.key});

  @override
  State<GroundedCarsHomePage> createState() => _GroundedCarsHomePageState();
}

class _GroundedCarsHomePageState extends State<GroundedCarsHomePage> {
  AppPage _selectedPage = AppPage.home;
  AppPage? _redirectPage;
  User? _currentUser;
  ServiceDefinition? _selectedService;
  String? _selectedServiceType;
  final List<CarListing> _listings = [];
  final List<ServiceRequest> _serviceRequests = [];
  final List<ServiceDefinition> _serviceDefinitions = [
    ServiceDefinition(
      title: 'Car Diagnostics',
      shortDescription: 'Comprehensive mobile vehicle system checks.',
      details: 'Our technicians come to your home or office to diagnose electrical, engine, and system issues using professional tools.',
      features: ['Home/office service', 'Battery check', 'Engine diagnostics', 'Electrical system review'],
      imageUrl: 'public/img/car-diagnosis.png',
    ),
    ServiceDefinition(
      title: 'Car AC Refilling & Repair',
      shortDescription: 'AC refill and leak repair at your location.',
      details: 'Fast mobile air conditioning service for cooling refill, leak detection, and compressor checks wherever you are.',
      features: ['Gas refill', 'Leak repair', 'Compressor test', 'Mobile coverage'],
      imageUrl: 'public/img/car-ac-repair-and-refeilling.png',
    ),
    ServiceDefinition(
      title: 'Car Alarm & Tracker Installation',
      shortDescription: 'Security upgrades installed on-site.',
      details: 'Install alarms and GPS trackers at home or office, with expert setup for improved vehicle protection.',
      features: ['Alarm installation', 'GPS tracker setup', 'System testing', 'On-demand service'],
      imageUrl: 'public/img/car-alarm-and-tracker-installation.jpg',
    ),
    ServiceDefinition(
      title: 'Paint Work',
      shortDescription: 'Mobile paint touch-ups and detailing.',
      details: 'Our mobile paint technicians provide scratch repair, color matching, and protective finish work at your location.',
      features: ['Scratch repair', 'Color matching', 'Mobile detailing', 'Protective coating'],
      imageUrl: 'public/img/car-paint-work.PNG',
    ),
  ];

  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _listingFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _serviceFormKey = GlobalKey<FormState>();

  final TextEditingController _regFullNameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPhoneController = TextEditingController();
  final TextEditingController _regLocationController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  final TextEditingController _listingTitleController = TextEditingController();
  final TextEditingController _listingMakeController = TextEditingController();
  final TextEditingController _listingModelController = TextEditingController();
  final TextEditingController _listingYearController = TextEditingController();
  final TextEditingController _listingPriceController = TextEditingController();
  final TextEditingController _listingPricePerDayController = TextEditingController();
  final TextEditingController _listingMileageController = TextEditingController();
  final TextEditingController _listingConditionController = TextEditingController();
  final TextEditingController _listingTransmissionController = TextEditingController();
  final TextEditingController _listingFuelController = TextEditingController();
  final TextEditingController _listingLocationController = TextEditingController();
  final TextEditingController _listingAvailabilityController = TextEditingController();
  final TextEditingController _listingFeaturesController = TextEditingController();
  final TextEditingController _listingPickupLocationController = TextEditingController();
  final TextEditingController _listingDeliveryOptionController = TextEditingController();
  final TextEditingController _listingStatusController = TextEditingController();
  final TextEditingController _listingDescriptionController = TextEditingController();
  final TextEditingController _listingImageUrlController = TextEditingController();
  final List<String> _listingImageUrls = [];
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedYear;
  String? _selectedCondition;
  final List<ListingPackage> _listingPackages = [
    ListingPackage(
      name: 'Free Package',
      description: '1–3 listings with basic visibility.',
      price: 'KES 0',
      maxListings: 3,
      isFeatured: false,
      durationDays: 15,
    ),
    ListingPackage(
      name: 'Premium Package',
      description: 'Priority visibility and longer listing duration.',
      price: 'KES 2,000',
      maxListings: 10,
      isFeatured: true,
      durationDays: 60,
    ),
  ];
  String _selectedListingPackage = 'Free Package';
  bool _isLoading = false;

  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _serviceLocationController = TextEditingController();
  final TextEditingController _serviceDescriptionController = TextEditingController();
  final TextEditingController _serviceRequesterNameController = TextEditingController();
  final TextEditingController _serviceRequesterPhoneController = TextEditingController();
  final TextEditingController _serviceCarDetailsController = TextEditingController();
  final TextEditingController _servicePreferredDateTimeController = TextEditingController();
  final List<User> _users = [];
  final List<PaymentRecord> _paymentRecords = [];

  bool get _isAdminUser => _currentUser?.isAdmin == true;

  @override
  void initState() {
    super.initState();
    debugPrint('App initState: Checking Firebase...');
    _checkCurrentUser();
    _fetchListings();
    _fetchServiceRequests();
    _fetchUsers();
    
    // Add mock admin user for convenience
    final adminUser = User(
      fullName: 'System Admin',
      email: 'admin@groundedcars.co.ke',
      phone: '+254700000000',
      location: 'Nairobi',
      isAdmin: true,
    );
    _users.add(adminUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildWhatsAppButton(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavigationBar(),
            _buildPageContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppButton() {
    return FloatingActionButton(
      onPressed: () async {
        final Uri url = Uri.parse('https://wa.me/254719838935');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $url');
        }
      },
      backgroundColor: const Color(0xFF25D366),
      elevation: 6,
      child: SvgPicture.string(
        '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path fill="white" d="M380.9 97.1C339 55.1 283.2 32 223.9 32c-122.4 0-222 99.6-222 222 0 39.1 10.2 77.3 29.6 111L0 480l117.7-30.9c32.4 17.7 68.9 27 106.1 27h.1c122.3 0 224.1-99.6 224.1-222 0-59.3-25.2-115-67.1-157zm-157 341.6c-33.1 0-65.6-8.9-94-25.7l-6.7-4-69.8 18.3L72 359.2l-4.4-7c-18.5-29.4-28.2-63.3-28.2-98.2 0-101.7 82.8-184.5 184.6-184.5 49.3 0 95.6 19.2 130.4 54.1 34.8 34.9 56.2 81.2 56.1 130.5 0 101.8-84.9 184.6-186.6 184.6zm101.2-138.2c-5.5-2.8-32.8-16.2-37.9-18-5.1-1.9-8.8-2.8-12.5 2.8-3.7 5.6-14.3 18-17.6 21.8-3.2 3.7-6.5 4.2-12 1.4-5.5-2.8-23.2-8.5-44.2-27.1-16.4-14.6-27.4-32.6-30.6-37.9-3.2-5.5-.3-8.5 2.4-11.2 2.5-2.6 5.5-6.5 8.3-9.8 2.8-3.2 3.7-5.5 5.5-9.3 1.9-3.7.9-6.9-.5-9.8-1.4-2.8-12.5-30.1-17.1-41.2-4.5-10.8-9.1-9.3-12.5-9.5-3.2-.2-6.9-.2-10.6-.2-3.7 0-9.7 1.4-14.8 6.9-5.1 5.6-19.4 19-19.4 46.3 0 27.3 19.9 53.7 22.6 57.4 2.8 3.7 39.1 59.7 94.8 83.8 13.2 5.8 23.5 9.2 31.5 11.8 13.3 4.2 25.4 3.6 35 2.2 10.7-1.6 32.8-13.4 37.4-26.4 4.6-13 4.6-24.1 3.2-26.4-1.3-2.5-5-3.9-10.5-6.6z"/></svg>''',
        height: 32,
        width: 32,
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          color: Colors.white,
          child: Row(
            children: [
              SvgPicture.asset(
                'public/img/logo/logo.svg',
                height: 40,
                placeholderBuilder: (context) => const SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              const SizedBox(width: 40),
              _buildNavButton('Home', AppPage.home),
              _buildNavButton('Services', AppPage.services),
              _buildNavButton('My Listings', AppPage.manageListings),
              _buildNavButton('Request Service', AppPage.requestService),
              if (_isAdminUser) _buildNavButton('Admin', AppPage.admin),
              const Spacer(),
              if (_currentUser != null)
                Row(
                  children: [
                    Text('Hello, ${_currentUser!.fullName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 20),
                    ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      setState(() {
                        _currentUser = null;
                        _selectedPage = AppPage.home;
                      });
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _selectedPage = AppPage.login),
                      child: const Text('Sign In'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => setState(() => _selectedPage = AppPage.register),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E88E5),
                        side: const BorderSide(color: Color(0xFF1E88E5)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          color: const Color(0xFFEEF7F1),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWhatsAppGroupButton(
                label: 'Join Group A',
                url: 'https://chat.whatsapp.com/INBzE6XzEkxHLbukiutVnH',
              ),
              const SizedBox(width: 16),
              _buildWhatsAppGroupButton(
                label: 'Join Group B',
                url: 'https://chat.whatsapp.com/Ep1RHz89pxU3kQNuEO8gyO',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(String label, AppPage page) {
    final bool active = _selectedPage == page;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: () => setState(() => _selectedPage = page),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? const Color(0xFF1E88E5) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppGroupButton({required String label, required String url}) {
    return ElevatedButton.icon(
      onPressed: () async {
        final Uri uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $url');
        }
      },
      icon: const Icon(Icons.chat, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  Future<void> _checkCurrentUser() async {
    debugPrint('_checkCurrentUser: Fetching current user...');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint('_checkCurrentUser: Found user: ${user.email}. Fetching profile...');
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 15));
        if (doc.exists) {
          debugPrint('_checkCurrentUser: Profile found.');
          setState(() {
            _currentUser = User.fromMap(doc.data()!);
          });
        } else {
          debugPrint('_checkCurrentUser: Profile NOT found in Firestore.');
          await FirebaseAuth.instance.signOut();
        }
      } on FirebaseException catch (e) {
        debugPrint('_checkCurrentUser: Firebase error: ${e.code} - ${e.message}');
      } on TimeoutException catch (e) {
        debugPrint('_checkCurrentUser: Timeout: $e');
      } catch (e) {
        debugPrint('_checkCurrentUser: Error: $e');
      }
    } else {
      debugPrint('_checkCurrentUser: No user currently signed in.');
    }
  }

  Widget _buildPageContent() {
    switch (_selectedPage) {
      case AppPage.home:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(),
            _buildFilterSection(),
            _buildCarListingsSection(),
            _buildServicesSection(),
            _buildSellRentSection(),
            _buildWhyChooseSection(),
            _buildFooter(),
          ],
        );
      case AppPage.services:
        return _buildServicesPage();
      case AppPage.serviceDetails:
        return _buildServiceDetailsSection();
      case AppPage.register:
        return _buildRegisterSection();
      case AppPage.login:
        return _buildLoginSection();
      case AppPage.manageListings:
        return _buildManageListingsSection();
      case AppPage.requestService:
        return _buildServiceRequestSection();
      case AppPage.admin:
        if (!_isAdminUser) {
          return Center(child: Text('Unauthorized: Admin access only.'));
        }
        return _buildAdminSection();
    }
  }

  Widget _buildRegisterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.person_add_alt_1, color: Color(0xFF1E88E5), size: 32),
                      SizedBox(width: 14),
                      Text('Sign Up', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Join GroundedCars and start listing, buying, and requesting services with ease.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 30),
                  Form(
                    key: _registerFormKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _regFullNameController, label: 'Full name', prefixIcon: Icons.person, validator: _requiredValidator)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(controller: _regEmailController, label: 'Email address', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email, validator: _requiredValidator)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _regPhoneController, label: 'Phone number', keyboardType: TextInputType.phone, prefixIcon: Icons.phone_android, validator: _requiredValidator)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(controller: _regLocationController, label: 'Location', prefixIcon: Icons.location_on, validator: _requiredValidator)),
                          ],
                        ),
                        _buildTextField(controller: _regPasswordController, label: 'Create password', obscureText: true, prefixIcon: Icons.lock, validator: _requiredValidator),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _selectedPage = AppPage.login),
                            child: const Text('Already have an account? Sign in', style: TextStyle(color: Color(0xFF1E88E5))),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitRegisterForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: _isLoading 
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                              : const Text('Sign Up', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.login, color: Color(0xFF1E88E5), size: 32),
                      SizedBox(width: 14),
                      Text('Sign In', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Access your GroundedCars account to manage listings and request services.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 30),
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        _buildTextField(controller: _loginEmailController, label: 'Email address', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email, validator: _requiredValidator),
                        _buildTextField(controller: _loginPasswordController, label: 'Password', obscureText: true, prefixIcon: Icons.lock, validator: _requiredValidator),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _selectedPage = AppPage.register),
                            child: const Text('Need an account? Sign up', style: TextStyle(color: Color(0xFF1E88E5))),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitLoginForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: _isLoading 
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                              : const Text('Sign In', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageListingsSection() {
    if (_currentUser == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Listings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Please login or register before creating or managing listings.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {
                _selectedPage = AppPage.login;
                _redirectPage = AppPage.manageListings;
              }),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create / Manage Listings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Listing Packages',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: _listingPackages.map((pkg) => Expanded(
              child: Card(
                color: pkg.isFeatured ? const Color(0xFFE3F2FD) : Colors.grey.shade100,
                margin: const EdgeInsets.only(right: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(pkg.price, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(pkg.description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 8),
                      Text('Max Listings: ${pkg.maxListings}', style: const TextStyle(fontSize: 12)),
                      Text('Duration: ${pkg.durationDays} days', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          Form(
            key: _listingFormKey,
            child: Column(
              children: [
                _buildTextField(controller: _listingTitleController, label: 'Listing Title', validator: _requiredValidator),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _listingMakeController, label: 'Make', validator: _requiredValidator)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _listingModelController, label: 'Model', validator: _requiredValidator)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _listingYearController, label: 'Year', keyboardType: TextInputType.number, validator: _requiredValidator)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _listingMileageController, label: 'Mileage', keyboardType: TextInputType.number, validator: _requiredValidator)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _listingConditionController, label: 'Condition', validator: _requiredValidator)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _listingTransmissionController, label: 'Transmission', validator: _requiredValidator)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _listingFuelController, label: 'Fuel Type', validator: _requiredValidator)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _listingLocationController, label: 'Location', validator: _requiredValidator)),
                  ],
                ),
                _buildTextField(controller: _listingPriceController, label: 'Price', validator: _requiredValidator),
                DropdownButtonFormField<String>(
                  value: _listingStatusController.text.isEmpty ? null : _listingStatusController.text,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: ['For Sale', 'For Hire', 'Grounded Car']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _listingStatusController.text = value);
                    }
                  },
                  validator: _requiredValidator,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedListingPackage,
                  decoration: InputDecoration(
                    labelText: 'Listing Package',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _listingPackages
                      .map((pkg) => DropdownMenuItem(value: pkg.name, child: Text('${pkg.name} • ${pkg.price}')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedListingPackage = value);
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Text(
                    _listingPackages.firstWhere((pkg) => pkg.name == _selectedListingPackage).description,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
                _buildTextField(controller: _listingDescriptionController, label: 'Description', validator: _requiredValidator),
                const SizedBox(height: 16),
                _buildImageUrlEntry(),
                if (_listingImageUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _listingImageUrls.map((url) => Chip(
                        label: Text(url, overflow: TextOverflow.ellipsis),
                        onDeleted: () => setState(() => _listingImageUrls.remove(url)),
                      )).toList(),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitListingForm,
                  child: const Text('Save Listing'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'My Listings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._listings.map((listing) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (listing.imageUrls.isNotEmpty)
                        Image.network(
                          listing.imageUrls.first,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(height: 180, child: Center(child: Text('Image unavailable'))),
                        ),
                      const SizedBox(height: 16),
                      Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('${listing.year} ${listing.make} ${listing.model}'),
                      Text('Status: ${listing.status}'),
                      Text('Package: ${listing.packageType}'),
                      if (listing.isFeatured) Text('Featured listing', style: const TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.w600)),
                      Text('Duration: ${listing.listingDurationDays} days'),
                      Text('Price: ${listing.price}'),
                      Text('Mileage: ${listing.mileage}'),
                      Text('Condition: ${listing.condition}'),
                      Text('Transmission: ${listing.transmission}'),
                      Text('Fuel: ${listing.fuelType}'),
                      Text('Location: ${listing.location}'),
                      if (listing.pricePerDay.isNotEmpty) Text('Price/Day: ${listing.pricePerDay}'),
                      if (listing.availability.isNotEmpty) Text('Availability: ${listing.availability}'),
                      if (listing.features.isNotEmpty) Text('Features: ${listing.features}'),
                      if (listing.pickupLocation.isNotEmpty) Text('Pickup: ${listing.pickupLocation}'),
                      if (listing.deliveryOption.isNotEmpty) Text('Delivery: ${listing.deliveryOption}'),
                      const SizedBox(height: 8),
                      Text(listing.description),
                      const SizedBox(height: 8),
                      Text('Contact: ${listing.ownerPhone}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildAdminSection() {
    if (!_isAdminUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Panel', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Access denied. Please login as an administrator to manage listings and service requests.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _selectedPage = AppPage.home),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Admin Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 16,
                  children: [
                    _buildAdminSummaryCard('Users', _users.length.toString(), 'Manage accounts'),
                    _buildAdminSummaryCard('Listings', _listings.length.toString(), 'Approve / feature'),
                    _buildAdminSummaryCard('Payments', _paymentRecords.length.toString(), 'Track invoices'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Listings Management'),
                Tab(text: 'User Management'),
                Tab(text: 'Service Requests'),
                Tab(text: 'Package Management'),
                Tab(text: 'Payment Tracking'),
              ],
              labelColor: Color(0xFF1E88E5),
              unselectedLabelColor: Colors.black54,
              indicatorColor: Color(0xFF1E88E5),
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 800,
              child: TabBarView(
                children: [
                  _buildAdminListingsTab(),
                  _buildAdminUsersTab(),
                  _buildAdminServiceRequestsTab(),
                  _buildAdminPackagesTab(),
                  _buildAdminPaymentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminListingsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage Car Listings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_listings.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No listings found'))))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _listings.length,
              itemBuilder: (context, index) {
                final listing = _listings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(listing.imageUrls.isNotEmpty ? listing.imageUrls[0] : 'https://images.unsplash.com/photo-1542362567-b058c02b56f2?q=80&w=2070&auto=format&fit=crop'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(width: 12),
                                  _buildStatusChip(listing.approvalStatus),
                                  if (listing.isFeatured)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Chip(
                                        label: const Text('FEATURED', style: TextStyle(fontSize: 10, color: Colors.white)),
                                        backgroundColor: Colors.amber.shade700,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Owner: ${listing.ownerName} (${listing.ownerEmail})'),
                              Text('Package: ${listing.packageType} • Channel: ${listing.status}'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                children: [
                                  if (listing.approvalStatus == 'Pending')
                                    ElevatedButton(
                                      onPressed: () => _updateListing(listing.copyWith(approvalStatus: 'Approved')),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                      child: const Text('Approve'),
                                    ),
                                  if (listing.approvalStatus == 'Pending')
                                    OutlinedButton(
                                      onPressed: () => _updateListing(listing.copyWith(approvalStatus: 'Rejected')),
                                      child: const Text('Reject'),
                                    ),
                                  if (listing.approvalStatus == 'Approved')
                                    ElevatedButton.icon(
                                      onPressed: () => _updateListing(listing.copyWith(isFeatured: !listing.isFeatured)),
                                      icon: Icon(listing.isFeatured ? Icons.star : Icons.star_border),
                                      label: Text(listing.isFeatured ? 'Unfeature' : 'Promote / Feature'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: listing.isFeatured ? Colors.grey : Colors.amber.shade700,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteListing(listing),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Approved') color = Colors.green;
    if (status == 'Rejected') color = Colors.red;
    if (status == 'Pending') color = Colors.orange;

    return Chip(
      label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildAdminUsersTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage Registered Users', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._users.map((user) {
            final index = _users.indexOf(user);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF1E88E5),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(user.email, style: const TextStyle(color: Colors.black54)),
                          Text(user.phone, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          Row(
                            children: [
                              Chip(
                                label: Text(user.isAdmin ? 'ADMIN' : 'USER', style: const TextStyle(fontSize: 10)),
                                backgroundColor: user.isAdmin ? Colors.blue.shade100 : Colors.grey.shade100,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(user.active ? 'ACTIVE' : 'INACTIVE', style: const TextStyle(fontSize: 10)),
                                backgroundColor: user.active ? Colors.green.shade100 : Colors.red.shade100,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => _updateUser(user.copyWith(active: !user.active)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: user.active ? Colors.red.shade50 : Colors.green.shade50,
                            foregroundColor: user.active ? Colors.red : Colors.green,
                            elevation: 0,
                          ),
                          child: Text(user.active ? 'Deactivate' : 'Activate'),
                        ),
                        if (user.email != 'admin@groundedcars.co.ke')
                          OutlinedButton(
                            onPressed: () => _updateUser(user.copyWith(isAdmin: !user.isAdmin)),
                            child: Text(user.isAdmin ? 'Demote' : 'Promote'),
                          ),
                        if (user.email != 'admin@groundedcars.co.ke')
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAdminServiceRequestsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage Service Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_serviceRequests.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No service requests found'))))
          else
            ..._serviceRequests.map((request) {
              final index = _serviceRequests.indexOf(request);
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${request.type} request', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          _buildRequestStatusChip(request.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(Icons.person, 'Requester: ${request.requesterName}'),
                                _buildDetailRow(Icons.phone, 'Contact: ${request.requesterPhone}'),
                                _buildDetailRow(Icons.email, 'Email: ${request.requesterEmail}'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(Icons.directions_car, 'Car: ${request.carDetails}'),
                                _buildDetailRow(Icons.location_on, 'Location: ${request.location}'),
                                _buildDetailRow(Icons.calendar_today, 'Preferred: ${request.preferredDateTime}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text('Description: ${request.description}', style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        children: [
                          if (request.status == 'Assigned')
                            ElevatedButton(
                              onPressed: () => _updateServiceRequest(request.copyWith(status: 'In Progress')),
                              child: const Text('Start Work'),
                            ),
                          if (request.status == 'In Progress')
                            ElevatedButton(
                              onPressed: () => _updateServiceRequest(request.copyWith(status: 'Completed')),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              child: const Text('Mark Completed'),
                            ),
                          if (request.status != 'Completed' && request.status != 'Rejected')
                            OutlinedButton(
                              onPressed: () => _updateServiceRequest(request.copyWith(status: 'Rejected')),
                              child: const Text('Reject'),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteServiceRequest(request),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildRequestStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Completed') color = Colors.green;
    if (status == 'In Progress') color = Colors.blue;
    if (status == 'Rejected') color = Colors.red;
    if (status == 'Assigned') color = Colors.orange;

    return Chip(
      label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildAdminPackagesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Listing Packages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  // Show dialog to add package
                  _showPackageDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Package'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _listingPackages.length,
            itemBuilder: (context, index) {
              final pkg = _listingPackages[index];
              return Card(
                color: pkg.isFeatured ? const Color(0xFFE3F2FD) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: pkg.isFeatured ? const Color(0xFF1E88E5) : Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          if (pkg.isFeatured) const Icon(Icons.star, color: Colors.amber, size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(pkg.price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                      const SizedBox(height: 4),
                      Text(pkg.description, style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _showPackageDialog(package: pkg, index: index),
                            child: const Text('Edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => setState(() {
                              _listingPackages.removeAt(index);
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPackageDialog({ListingPackage? package, int? index}) {
    final nameController = TextEditingController(text: package?.name ?? '');
    final descController = TextEditingController(text: package?.description ?? '');
    final priceController = TextEditingController(text: package?.price ?? '');
    final maxListingsController = TextEditingController(text: package?.maxListings.toString() ?? '1');
    final durationController = TextEditingController(text: package?.durationDays.toString() ?? '30');
    bool isFeatured = package?.isFeatured ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(package == null ? 'Add Package' : 'Edit Package'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Package Name')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (e.g. KES 1,000)')),
                TextField(controller: maxListingsController, decoration: const InputDecoration(labelText: 'Max Listings'), keyboardType: TextInputType.number),
                TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Duration (Days)'), keyboardType: TextInputType.number),
                CheckboxListTile(
                  title: const Text('Featured Package'),
                  value: isFeatured,
                  onChanged: (val) => setDialogState(() => isFeatured = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newPkg = ListingPackage(
                  name: nameController.text,
                  description: descController.text,
                  price: priceController.text,
                  maxListings: int.tryParse(maxListingsController.text) ?? 1,
                  isFeatured: isFeatured,
                  durationDays: int.tryParse(durationController.text) ?? 30,
                );
                setState(() {
                  if (index != null) {
                    _listingPackages[index] = newPkg;
                  } else {
                    _listingPackages.add(newPkg);
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPaymentsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Tracking', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_paymentRecords.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No payment records found'))))
          else
            Card(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('User Email')),
                    DataColumn(label: Text('Package')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: _paymentRecords.map((payment) {
                    return DataRow(cells: [
                      DataCell(Text(payment.userEmail)),
                      DataCell(Text(payment.packageName)),
                      DataCell(Text(payment.amount)),
                      DataCell(Text(payment.date)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: payment.status == 'Completed' ? Colors.green.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(payment.status, style: TextStyle(color: payment.status == 'Completed' ? Colors.green.shade900 : Colors.orange.shade900, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceRequestSection() {
    if (_currentUser == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request a Service',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('To request a service, please browse and select a service from our Marketplace.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _selectedPage = AppPage.services),
              child: const Text('Go to Services Marketplace'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Automotive Services',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Form(
            key: _serviceFormKey,
            child: Column(
              children: [
                _buildTextField(controller: _serviceRequesterNameController, label: 'Your Name', validator: _requiredValidator),
                _buildTextField(controller: _serviceRequesterPhoneController, label: 'Phone Number', keyboardType: TextInputType.phone, validator: _requiredValidator),
                _buildTextField(controller: _serviceLocationController, label: 'Location', validator: _requiredValidator),
                _buildTextField(controller: _serviceCarDetailsController, label: 'Car Details (make/model/year)', validator: _requiredValidator),
                _buildTextField(controller: _servicePreferredDateTimeController, label: 'Preferred Date / Time', validator: _requiredValidator),
                _buildTextField(controller: _serviceTypeController, label: 'Service Type', validator: _requiredValidator),
                _buildTextField(controller: _serviceDescriptionController, label: 'Service Description', validator: _requiredValidator),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitServiceForm,
                  child: const Text('Submit Request'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'My Requests',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._serviceRequests.map((request) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(request.description),
                      Text('Location: ${request.location}'),
                      const SizedBox(height: 8),
                      Text('Car: ${request.carDetails}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Preferred: ${request.preferredDateTime}', style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 8),
                      Text('Assigned to: ${request.assignedTo}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Status: ${request.status}', style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 8),
                      Text('Contact: ${request.requesterName} • ${request.requesterPhone}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildServicesPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Services Marketplace',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _selectedPage = AppPage.home),
                child: const Text('Back to Home'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Book on-demand mobile automotive services to your home or office.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
            children: _serviceDefinitions.map((service) => _buildServiceCard(service)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsSection() {
    final service = _selectedService;
    if (service == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service not selected', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _selectedPage = AppPage.services),
              child: const Text('Back to Services'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(service.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _selectedPage = AppPage.services),
                child: const Text('Back to Services'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Image.asset(
            service.imageUrl,
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(height: 260, child: Center(child: Text('Image unavailable'))),
          ),
          const SizedBox(height: 24),
          Text(service.details, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
          const SizedBox(height: 24),
          const Text('Service features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: service.features.map((feature) => Chip(label: Text(feature))).toList(),
          ),
          const SizedBox(height: 32),
          const Text('On-demand mobile service for home or office', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text('Technicians travel to your location and complete the job on-site, whether at home or at the office.', style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _navigateToServiceRequest(service.title),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Request This Service'),
          ),
        ],
      ),
    );
  }

  void _navigateToServiceRequest(String serviceType) {
    setState(() {
      _selectedServiceType = serviceType;
      _serviceTypeController.text = serviceType;
      _serviceRequesterNameController.text = _currentUser?.fullName ?? '';
      _serviceRequesterPhoneController.text = _currentUser?.phone ?? '';
    });
    _showServiceRequestDialog(serviceType);
  }

  void _showServiceRequestDialog(String serviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Service Request', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('thank you for requesting then $serviceName for quick services chat us', style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _selectedPage = _currentUser == null ? AppPage.services : AppPage.requestService);
              },
              child: const Text('view more', style: TextStyle(color: Color(0xFF1E88E5))),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final Uri url = Uri.parse('https://wa.me/254719838935');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF1E88E5)) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() => _isLoading = true);
        
        for (var file in result.files) {
          final fileName = 'listing_images/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          final storageRef = FirebaseStorage.instance.ref().child(fileName);
          
          UploadTask uploadTask;
          if (kIsWeb) {
            uploadTask = storageRef.putData(file.bytes!);
          } else {
            uploadTask = storageRef.putFile(File(file.path!));
          }

          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          setState(() {
            _listingImageUrls.add(downloadUrl);
          });
        }
        
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Images uploaded successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Widget _buildImageUrlEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add images for the listing', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickAndUploadImage,
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.photo_library),
                label: Text(_isLoading ? 'Uploading...' : 'Upload Images from Computer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  Future<void> _submitRegisterForm() async {
    if (!_registerFormKey.currentState!.validate()) return;
    
    if (!_isFirebaseInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase not initialized. Please refresh the page.')),
      );
      return;
    }

    debugPrint('Starting registration process...');
    setState(() => _isLoading = true);
    try {
      final email = _regEmailController.text.trim();
      final password = _regPasswordController.text.trim();
      final fullName = _regFullNameController.text.trim();
      final phone = _regPhoneController.text.trim();
      final location = _regLocationController.text.trim();
      final isAdmin = email.toLowerCase() == 'admin@groundedcars.co.ke';

      debugPrint('Attempting to create user with email: $email');
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        debugPrint('User created successfully, saving to Firestore...');
        final newUser = User(
          uid: credential.user!.uid,
          fullName: fullName,
          email: email,
          phone: phone,
          location: location,
          isAdmin: isAdmin,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set(newUser.toMap())
            .timeout(const Duration(seconds: 15));

        debugPrint('Firestore document saved.');
        setState(() {
          _currentUser = newUser;
          _selectedPage = _redirectPage ?? (newUser.isAdmin ? AppPage.admin : AppPage.home);
          _redirectPage = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during registration: ${e.code}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.code}: ${e.message ?? 'Registration failed.'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException during registration: ${e.code} - ${e.message}');
      if (mounted) {
        String userFriendlyMessage = 'Firestore error during registration: ${e.message ?? 'An error occurred.'}';
        if (e.code == 'unavailable') {
          userFriendlyMessage = 'Database service unavailable. Your account was created, but your profile couldn\'t be saved yet. Please try logging in shortly.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout during registration: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operation timed out. Please check your connection.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during registration: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      debugPrint('Registration process completed.');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitLoginForm() async {
    if (!_loginFormKey.currentState!.validate()) return;
    
    if (!_isFirebaseInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase not initialized. Please refresh the page.')),
      );
      return;
    }

    debugPrint('Starting login process...');
    setState(() => _isLoading = true);
    try {
      final email = _loginEmailController.text.trim();
      final password = _loginPasswordController.text.trim();
      
      // Admin bypass for testing
      if (email.toLowerCase() == 'admin@groundedcars.co.ke' && password == 'adminpassword') {
        debugPrint('Admin bypass triggered.');
        final adminUser = User(
          uid: 'admin-bypass-uid',
          fullName: 'System Administrator',
          email: email,
          phone: '+254700000000',
          location: 'Nairobi',
          isAdmin: true,
        );
        setState(() {
          _currentUser = adminUser;
          _selectedPage = AppPage.admin;
          _redirectPage = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin Bypass Login successful.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      debugPrint('Attempting to sign in with email: $email');
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        debugPrint('Signed in successfully, fetching user profile from Firestore...');
        
        // Try fetching with a timeout and specific error handling
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get()
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw TimeoutException('Firestore request timed out. Please check your network.'),
            );

        final isAdminEmail = email.toLowerCase() == 'admin@groundedcars.co.ke';
        if (doc.exists) {
          debugPrint('User profile found.');
          var userData = User.fromMap(doc.data()!);
          if (isAdminEmail && !userData.isAdmin) {
            userData = userData.copyWith(isAdmin: true);
          }
          setState(() {
            _currentUser = userData;
            _selectedPage = _redirectPage ?? (userData.isAdmin ? AppPage.admin : AppPage.home);
            _redirectPage = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (isAdminEmail) {
          debugPrint('Admin user profile NOT found in Firestore, allowing login.');
          final adminUser = User(
            uid: credential.user!.uid,
            fullName: 'Administrator',
            email: email,
            phone: '',
            location: '',
            isAdmin: true,
          );
          setState(() {
            _currentUser = adminUser;
            _selectedPage = AppPage.admin;
            _redirectPage = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Admin Login successful.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          debugPrint('User profile NOT found in Firestore.');
          // Sign out if no user doc found in Firestore
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User profile not found. Please register again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during login: ${e.code}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.code}: ${e.message ?? 'Login failed.'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException during login: ${e.code} - ${e.message}');
      if (mounted) {
        String userFriendlyMessage = 'Firestore error: ${e.message ?? 'An error occurred.'}';
        if (e.code == 'unavailable') {
          userFriendlyMessage = 'Database service unavailable. Please check your internet connection or try again later.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout during login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operation timed out. Please check your connection.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      debugPrint('Login process completed.');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _submitListingForm() {
    if (!_listingFormKey.currentState!.validate() || _currentUser == null) return;
    
    final selectedPackage = _listingPackages.firstWhere((pkg) => pkg.name == _selectedListingPackage);
    final currentFreeListings = _listings.where((listing) => listing.ownerEmail == _currentUser!.email && listing.packageType == 'Free Package').length;
    
    if (selectedPackage.name == 'Free Package' && currentFreeListings >= selectedPackage.maxListings) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Free package limit reached. Choose Premium to add more listings.')));
      return;
    }

    final newListing = CarListing(
      title: _listingTitleController.text.trim(),
      status: _listingStatusController.text.trim(),
      approvalStatus: 'Pending',
      packageType: selectedPackage.name,
      isFeatured: selectedPackage.isFeatured,
      listingDurationDays: selectedPackage.durationDays,
      make: _listingMakeController.text.trim(),
      model: _listingModelController.text.trim(),
      year: _listingYearController.text.trim(),
      price: _listingPriceController.text.trim(),
      pricePerDay: _listingPricePerDayController.text.trim(),
      mileage: _listingMileageController.text.trim(),
      condition: _listingConditionController.text.trim(),
      transmission: _listingTransmissionController.text.trim(),
      fuelType: _listingFuelController.text.trim(),
      location: _listingLocationController.text.trim(),
      availability: _listingAvailabilityController.text.trim(),
      features: _listingFeaturesController.text.trim(),
      pickupLocation: _listingPickupLocationController.text.trim(),
      deliveryOption: _listingDeliveryOptionController.text.trim(),
      description: _listingDescriptionController.text.trim(),
      imageUrls: List<String>.from(_listingImageUrls),
      ownerName: _currentUser!.fullName,
      ownerPhone: _currentUser!.phone,
      ownerEmail: _currentUser!.email,
      ownerUid: _currentUser!.uid,
    );

    FirebaseFirestore.instance.collection('listings').add(newListing.toMap()).then((_) {
      _fetchListings();
      if (mounted) {
        setState(() {
          _listingTitleController.clear();
          _listingMakeController.clear();
          _listingModelController.clear();
          _listingYearController.clear();
          _listingPriceController.clear();
          _listingPricePerDayController.clear();
          _listingMileageController.clear();
          _listingConditionController.clear();
          _listingTransmissionController.clear();
          _listingFuelController.clear();
          _listingLocationController.clear();
          _listingAvailabilityController.clear();
          _listingFeaturesController.clear();
          _listingPickupLocationController.clear();
          _listingDeliveryOptionController.clear();
          _listingStatusController.clear();
          _listingDescriptionController.clear();
          _listingImageUrlController.clear();
          _listingImageUrls.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing saved and pending approval.')));
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving listing: $e')));
      }
    });
  }

  void _submitServiceForm() {
    if (!_serviceFormKey.currentState!.validate() || _currentUser == null) return;
    
    final newRequest = ServiceRequest(
      type: _serviceTypeController.text.trim(),
      description: _serviceDescriptionController.text.trim(),
      location: _serviceLocationController.text.trim(),
      requesterName: _serviceRequesterNameController.text.trim(),
      requesterPhone: _serviceRequesterPhoneController.text.trim(),
      requesterEmail: _currentUser!.email,
      requesterUid: _currentUser!.uid,
      carDetails: _serviceCarDetailsController.text.trim(),
      preferredDateTime: _servicePreferredDateTimeController.text.trim(),
      assignedTo: 'GroundedCars Service Team',
      status: 'Assigned',
    );

    FirebaseFirestore.instance.collection('service_requests').add(newRequest.toMap()).then((_) {
      _fetchServiceRequests();
      if (mounted) {
        setState(() {
          _serviceRequesterNameController.clear();
          _serviceRequesterPhoneController.clear();
          _serviceLocationController.clear();
          _serviceCarDetailsController.clear();
          _servicePreferredDateTimeController.clear();
          _serviceTypeController.clear();
          _serviceDescriptionController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service request submitted.')));
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    });
  }

  Future<void> _fetchListings() async {
    if (!_isFirebaseInitialized) return;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('listings').get();
      if (mounted) {
        setState(() {
          _listings.clear();
          for (var doc in snapshot.docs) {
            _listings.add(CarListing.fromMap(doc.data(), doc.id));
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching listings: $e');
    }
  }

  Future<void> _fetchServiceRequests() async {
    if (!_isFirebaseInitialized) return;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('service_requests').get();
      if (mounted) {
        setState(() {
          _serviceRequests.clear();
          for (var doc in snapshot.docs) {
            _serviceRequests.add(ServiceRequest.fromMap(doc.data(), doc.id));
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching service requests: $e');
    }
  }

  Future<void> _updateListing(CarListing listing) async {
    if (listing.id == null) return;
    try {
      await FirebaseFirestore.instance.collection('listings').doc(listing.id).update(listing.toMap());
      await _fetchListings();
    } catch (e) {
      debugPrint('Error updating listing: $e');
    }
  }

  Future<void> _deleteListing(CarListing listing) async {
    if (listing.id == null) return;
    try {
      await FirebaseFirestore.instance.collection('listings').doc(listing.id).delete();
      await _fetchListings();
    } catch (e) {
      debugPrint('Error deleting listing: $e');
    }
  }

  Future<void> _updateServiceRequest(ServiceRequest request) async {
    if (request.id == null) return;
    try {
      await FirebaseFirestore.instance.collection('service_requests').doc(request.id).update(request.toMap());
      await _fetchServiceRequests();
    } catch (e) {
      debugPrint('Error updating service request: $e');
    }
  }

  Future<void> _deleteServiceRequest(ServiceRequest request) async {
    if (request.id == null) return;
    try {
      await FirebaseFirestore.instance.collection('service_requests').doc(request.id).delete();
      await _fetchServiceRequests();
    } catch (e) {
      debugPrint('Error deleting service request: $e');
    }
  }

  Future<void> _fetchUsers() async {
    if (!_isFirebaseInitialized) return;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      if (mounted) {
        setState(() {
          _users.clear();
          for (var doc in snapshot.docs) {
            _users.add(User.fromMap(doc.data()));
          }
          // Ensure admin bypass user is always there for testing if needed
          if (!_users.any((u) => u.email == 'admin@groundedcars.co.ke')) {
            _users.add(User(
              fullName: 'System Admin',
              email: 'admin@groundedcars.co.ke',
              phone: '+254700000000',
              location: 'Nairobi',
              isAdmin: true,
            ));
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  Future<void> _updateUser(User user) async {
    if (user.uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(user.toMap());
      await _fetchUsers();
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  Future<void> _deleteUser(User user) async {
    if (user.uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await _fetchUsers();
    } catch (e) {
      debugPrint('Error deleting user: $e');
    }
  }

  @override
  void dispose() {
    _regFullNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regLocationController.dispose();
    _regPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _listingTitleController.dispose();
    _listingMakeController.dispose();
    _listingModelController.dispose();
    _listingYearController.dispose();
    _listingPriceController.dispose();
    _listingPricePerDayController.dispose();
    _listingMileageController.dispose();
    _listingConditionController.dispose();
    _listingTransmissionController.dispose();
    _listingFuelController.dispose();
    _listingLocationController.dispose();
    _listingAvailabilityController.dispose();
    _listingFeaturesController.dispose();
    _listingPickupLocationController.dispose();
    _listingDeliveryOptionController.dispose();
    _listingStatusController.dispose();
    _listingDescriptionController.dispose();
    _listingImageUrlController.dispose();
    _serviceTypeController.dispose();
    _serviceLocationController.dispose();
    _serviceDescriptionController.dispose();
    _serviceRequesterNameController.dispose();
    _serviceRequesterPhoneController.dispose();
    _serviceCarDetailsController.dispose();
    _servicePreferredDateTimeController.dispose();
    super.dispose();
  }

  Widget _buildNavLink(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? const Color(0xFF1E88E5) : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to\nGroundedCars Kenya',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A237E),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Kenya's Largest Used, Salvage & Rental Car Marketplace\n& On-Demand Automotive Services",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildLargeButton('List Your Car', const Color(0xFF1E88E5), AppPage.manageListings),
                    _buildLargeButton('Hire a Car', const Color(0xFFFFA000), AppPage.home),
                    _buildLargeButton('Request Service', const Color(0xFF43A047), AppPage.services),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                color: Colors.transparent,
                child: Image.asset(
                  'public/img/hero-image.png',
                  fit: BoxFit.contain,
                  height: 420,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeButton(String label, Color color, AppPage page) {
    return ElevatedButton(
      onPressed: () => setState(() => _selectedPage = page),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAdminSummaryCard(String title, String value, String subtitle) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      transform: Matrix4.translationValues(0, -40, 0),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Explore Car Listings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  _buildTab('All', true),
                  _buildTab('For Hire', false),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Text('View All'),
                        Icon(Icons.chevron_right, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildDropdown('Make', _selectedMake, ['All Makes', 'Toyota', 'Nissan', 'Mazda', 'Mitsubishi', 'BMW', 'Mercedes-Benz', 'Subaru', 'Honda', 'Volkswagen', 'Hyundai', 'Ford', 'Land Rover', 'Isuzu'], (value) {
                    setState(() => _selectedMake = value);
                  }),
                  _buildDropdown('Model', _selectedModel, ['Model', 'Camry', 'Corolla', 'Demio', 'Bluebird', 'Lancer', 'X5', 'C-Class', 'Forester', 'Civic', 'Golf', 'Tucson', 'Ranger', 'Range Rover', 'D-Max'], (value) {
                    setState(() => _selectedModel = value);
                  }),
                  _buildDropdown('Year', _selectedYear, ['Year', '2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017', '2016', '2015', '2014', '2013', '2012', '2011', '2010', 'Earlier'], (value) {
                    setState(() => _selectedYear = value);
                  }),
                  _buildDropdown('Condition', _selectedCondition, ['Condition', 'Used Cars'], (value) {
                    setState(() => _selectedCondition = value);
                  }),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? const Color(0xFF1E88E5) : Colors.grey,
            ),
          ),
          if (active)
            Container(
              height: 2,
              width: 20,
              color: const Color(0xFF1E88E5),
              margin: const EdgeInsets.only(top: 4),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue, List<String>? items, ValueChanged<String?> onChanged) {
    final dropdownItems = (items ?? <String>[]).map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(label, style: const TextStyle(color: Colors.grey)),
          isExpanded: true,
          items: dropdownItems,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCarListingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Explore Car Listings',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E88E5),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                child: const Row(
                  children: [
                    Text('View All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBrandFilter('All Makes', Icons.car_rental, true),
                _buildBrandFilter('Toyota', Icons.directions_car, false),
                _buildBrandFilter('Nissan', Icons.directions_car, false),
                _buildBrandFilter('Mazda', Icons.directions_car, false),
                _buildBrandFilter('BMW', Icons.directions_car, false),
                _buildBrandFilter('Mercedes-Benz', Icons.directions_car, false),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Builder(
            builder: (context) {
              final approvedListings = _listings.where((listing) => listing.approvalStatus == 'Approved').toList();
              if (approvedListings.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Text(
                      _listings.isEmpty
                          ? 'Loading listings...'
                          : 'No approved car listings are available right now.',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                );
              }

              return GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 32,
                crossAxisSpacing: 32,
                childAspectRatio: 0.7,
                children: approvedListings.map((listing) {
                  return _buildCarCard(
                    listing.title,
                    listing.status,
                    listing.price.isNotEmpty ? listing.price : 'Contact for price',
                    listing.imageUrls.isNotEmpty
                        ? listing.imageUrls.first
                        : 'https://images.unsplash.com/photo-1542362567-b058c02b56f2?q=80&w=2070&auto=format&fit=crop',
                    year: listing.year.isNotEmpty ? listing.year : null,
                    mileage: listing.mileage.isNotEmpty ? listing.mileage : null,
                    isFeatured: listing.isFeatured,
                    location: listing.location.isNotEmpty ? listing.location : 'Nairobi, Kenya',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBrandFilter(String name, IconData icon, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1E88E5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? const Color(0xFF1E88E5) : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarCard(String title, String tag, String price, String imageUrl, {String? year, String? mileage, bool isFeatured = false, String location = 'Nairobi, Kenya'}) {
    final hasValidImage = imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (hasValidImage)
                  Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                    ),
                  )
                else
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: tag == 'For Sale' ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                if (isFeatured)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (year != null) ...[
                        _buildSpecIcon(Icons.calendar_today_outlined, year),
                        const SizedBox(width: 16),
                      ],
                      if (mileage != null)
                        _buildSpecIcon(Icons.speed_outlined, mileage),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF1E88E5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Details',
                            style: TextStyle(
                              color: Color(0xFF1E88E5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'On-Demand Car Services',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _selectedPage = AppPage.services),
                child: const Text('View All Services >'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.85,
            children: _serviceDefinitions.map((service) => _buildServiceCard(service)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceDefinition service) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            service.imageUrl,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  service.shortDescription,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _selectedService = service;
                          _selectedPage = AppPage.serviceDetails;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _navigateToServiceRequest(service.title),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E88E5),
                          side: const BorderSide(color: Color(0xFF1E88E5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('Request'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellRentSection() {
    return Container(
      color: Colors.blue.shade50.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                      TextSpan(text: 'Sell '),
                      TextSpan(text: 'or ', style: TextStyle(fontWeight: FontWeight.normal)),
                      TextSpan(text: 'Rent Out ', style: TextStyle(color: Color(0xFF1E88E5))),
                      TextSpan(text: 'Your Car Today!'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Get started by creating a listing for sale or hire. Track how many views,\nfavorites, and inquiries your listing receives, and respond to interested renters.',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Row(
            children: [
              _buildSmallLargeButton('List Your Car', const Color(0xFF1E88E5), Icons.send),
              const SizedBox(width: 20),
              _buildSmallLargeButton('Hire Your Car', const Color(0xFF7CB342), Icons.car_rental),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLargeButton(String label, Color color, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildWhyChooseSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Choose GroundedCars?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureItem(
                Icons.list_alt,
                'Free & Premium Listings',
                'Free for everyone. Change and EDIT to extend your ads\nappropriate, marketing to reach more and offer\nsatisfaction through visibility, reach, and rating.',
                const Color(0xFF1E88E5),
              ),
              const SizedBox(width: 40),
              _buildFeatureItem(
                Icons.settings_suggest,
                'On-Demand Car Services',
                'Professional watch payments listings car services send\nextensive services, is hiring your sitting for,\ntrade and updates, local ads, building more.',
                const Color(0xFF1E88E5),
              ),
              const SizedBox(width: 40),
              _buildFeatureItem(
                Icons.security,
                'Secure, Easy Payments',
                'Fast and secure booking, family payments,\npossible, keeping services, better experience for\nusers, easy maintenance, and more.',
                const Color(0xFF00BFA5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color iconColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF1A237E),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: const Center(
        child: Text(
          '© 2026 GroundedCars. All Rights Reserved.',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

}
