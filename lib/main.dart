import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'firebase_options.dart';
import 'file_utils_stub.dart' if (dart.library.io) 'file_utils_io.dart';

const Color kAppPrimaryColor = Color(0xFF4A6D8C);
const Color kAppSecondaryColor = Color(0xFF7A8A98);
const Color kAppSuccessColor = Color(0xFF3D7A65);
const Color kAppWarningColor = Color(0xFF967E5F);
const Color kAppErrorColor = Color(0xFF8D3434);
const Color kAppBackgroundColor = Color(0xFFE0E2E5);
const Color kAppCardColor = Color(0xFFEDEFF2);
const Color kAppHeaderTextColor = Color(0xFF1F2937);
const Color kAppBodyTextColor = Color(0xFF4B5563);
const Color kAppMutedTextColor = Color(0xFF6B7280);
const Color kAppLightAccentColor = Color(0xFF8FA6BE);

enum AppPage { home, services, serviceDetails, listingDetails, register, login, manageListings, requestService, admin }

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
  final int listingCount;
  final bool hasPaidSubscription;
  final int monthlyListingCount;
  final DateTime? subscriptionStartDate;

  User({
    this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    this.isAdmin = false,
    this.active = true,
    this.listingCount = 0,
    this.hasPaidSubscription = false,
    this.monthlyListingCount = 0,
    this.subscriptionStartDate,
  });

  User copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    bool? isAdmin,
    bool? active,
    int? listingCount,
    bool? hasPaidSubscription,
    int? monthlyListingCount,
    DateTime? subscriptionStartDate,
  }) {
    return User(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      isAdmin: isAdmin ?? this.isAdmin,
      active: active ?? this.active,
      listingCount: listingCount ?? this.listingCount,
      hasPaidSubscription: hasPaidSubscription ?? this.hasPaidSubscription,
      monthlyListingCount: monthlyListingCount ?? this.monthlyListingCount,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
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
      'listingCount': listingCount,
      'hasPaidSubscription': hasPaidSubscription,
      'monthlyListingCount': monthlyListingCount,
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
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
      listingCount: map['listingCount'] ?? 0,
      hasPaidSubscription: map['hasPaidSubscription'] ?? false,
      monthlyListingCount: map['monthlyListingCount'] ?? 0,
      subscriptionStartDate: map['subscriptionStartDate'] != null 
          ? DateTime.tryParse(map['subscriptionStartDate']) 
          : null,
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
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: kAppPrimaryColor,
          onPrimary: Colors.white,
          secondary: kAppSecondaryColor,
          onSecondary: Colors.white,
          error: kAppErrorColor,
          onError: Colors.white,
          background: kAppBackgroundColor,
          onBackground: kAppHeaderTextColor,
          surface: kAppCardColor,
          onSurface: kAppHeaderTextColor,
        ),
        scaffoldBackgroundColor: kAppBackgroundColor,
        cardColor: kAppCardColor,
        canvasColor: kAppBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kAppBackgroundColor,
          foregroundColor: kAppHeaderTextColor,
          elevation: 0,
          iconTheme: IconThemeData(color: kAppHeaderTextColor),
          titleTextStyle: TextStyle(color: kAppHeaderTextColor, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: kAppHeaderTextColor,
              displayColor: kAppHeaderTextColor,
              fontFamily: 'Roboto',
            ),
        iconTheme: const IconThemeData(color: kAppHeaderTextColor),
        useMaterial3: true,
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
  CarListing? _selectedCarListing;
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

  int _adminTabIndex = 0;
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
  final TextEditingController _forgotPasswordController = TextEditingController();

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
  String? _selectedMake = 'All Makes';
  String? _selectedModel = 'Model';
  String? _selectedYear = 'Year';
  String? _selectedCondition = 'Condition';
  String _selectedTab = 'All';
  final List<ListingPackage> _listingPackages = [
    ListingPackage(
      name: 'Free Package',
      description: 'Up to 10 listings with basic visibility.',
      price: 'KES 0',
      maxListings: 10,
      isFeatured: false,
      durationDays: 30,
    ),
    ListingPackage(
      name: 'Premium Package',
      description: 'Priority visibility and unlimited listings.',
      price: 'KES 2,000',
      maxListings: 1000,
      isFeatured: true,
      durationDays: 365,
    ),
  ];
  String _selectedListingPackage = 'Free Package';
  String? _editingListingId;
  bool _isLoading = false;
  bool _isUploadingImages = false;

  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _serviceLocationController = TextEditingController();
  final TextEditingController _serviceDescriptionController = TextEditingController();
  final TextEditingController _serviceRequesterNameController = TextEditingController();
  final TextEditingController _serviceRequesterPhoneController = TextEditingController();
  final TextEditingController _serviceCarDetailsController = TextEditingController();
  final TextEditingController _servicePreferredDateTimeController = TextEditingController();
  final List<User> _users = [];
  final List<PaymentRecord> _paymentRecords = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isAdminUser => _currentUser?.isAdmin == true;

  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 900;

  int _responsiveColumns(BuildContext context, {int desktop = 4}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return desktop;
  }

  EdgeInsets _responsiveSectionPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return const EdgeInsets.symmetric(horizontal: 16, vertical: 24);
    if (width < 900) return const EdgeInsets.symmetric(horizontal: 24, vertical: 32);
    return const EdgeInsets.symmetric(horizontal: 40, vertical: 40);
  }

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
      phone: '+254719838935',
      location: 'Nairobi',
      isAdmin: true,
    );
    _users.add(adminUser);
  }

  void _showAppSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? kAppErrorColor : kAppSuccessColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildNavigationDrawer() : null,
      floatingActionButton: _buildWhatsAppButton(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildPageContent(),
            ),
          ),
        ],
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
      backgroundColor: kAppSuccessColor,
      elevation: 6,
      child: SvgPicture.string(
        '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path fill="white" d="M380.9 97.1C339 55.1 283.2 32 223.9 32c-122.4 0-222 99.6-222 222 0 39.1 10.2 77.3 29.6 111L0 480l117.7-30.9c32.4 17.7 68.9 27 106.1 27h.1c122.3 0 224.1-99.6 224.1-222 0-59.3-25.2-115-67.1-157zm-157 341.6c-33.1 0-65.6-8.9-94-25.7l-6.7-4-69.8 18.3L72 359.2l-4.4-7c-18.5-29.4-28.2-63.3-28.2-98.2 0-101.7 82.8-184.5 184.6-184.5 49.3 0 95.6 19.2 130.4 54.1 34.8 34.9 56.2 81.2 56.1 130.5 0 101.8-84.9 184.6-186.6 184.6zm101.2-138.2c-5.5-2.8-32.8-16.2-37.9-18-5.1-1.9-8.8-2.8-12.5 2.8-3.7 5.6-14.3 18-17.6 21.8-3.2 3.7-6.5 4.2-12 1.4-5.5-2.8-23.2-8.5-44.2-27.1-16.4-14.6-27.4-32.6-30.6-37.9-3.2-5.5-.3-8.5 2.4-11.2 2.5-2.6 5.5-6.5 8.3-9.8 2.8-3.2 3.7-5.5 5.5-9.3 1.9-3.7.9-6.9-.5-9.8-1.4-2.8-12.5-30.1-17.1-41.2-4.5-10.8-9.1-9.3-12.5-9.5-3.2-.2-6.9-.2-10.6-.2-3.7 0-9.7 1.4-14.8 6.9-5.1 5.6-19.4 19-19.4 46.3 0 27.3 19.9 53.7 22.6 57.4 2.8 3.7 39.1 59.7 94.8 83.8 13.2 5.8 23.5 9.2 31.5 11.8 13.3 4.2 25.4 3.6 35 2.2 10.7-1.6 32.8-13.4 37.4-26.4 4.6-13 4.6-24.1 3.2-26.4-1.3-2.5-5-3.9-10.5-6.6z"/></svg>''',
        height: 32,
        width: 32,
      ),
    );
  }

  Widget _buildNavigationBar() {
    final isMobile = _isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: kAppCardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 15),
            child: isMobile
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPage = AppPage.home),
                          child: SvgPicture.asset(
                            'public/img/logo/logo.svg',
                            height: 60,
                            placeholderBuilder: (context) => const SizedBox(
                              height: 60,
                              width: 60,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu),
                        color: kAppPrimaryColor,
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        tooltip: 'Open navigation menu',
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPage = AppPage.home),
                          child: SvgPicture.asset(
                            'public/img/logo/logo.svg',
                            height: 60,
                            placeholderBuilder: (context) => const SizedBox(
                              height: 60,
                              width: 60,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildNavButton('Home', AppPage.home),
                            _buildNavButton('Services', AppPage.services),
                            _buildNavButton('My Listings', AppPage.manageListings),
                            _buildNavButton('Request Service', AppPage.requestService),
                            if (_isAdminUser) _buildNavButton('Admin', AppPage.admin),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_currentUser != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Hello, ${_currentUser!.fullName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                setState(() {
                                  _currentUser = null;
                                  _selectedPage = AppPage.home;
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: kAppPrimaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _selectedPage = AppPage.login),
                              child: const Text('Sign In'),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () => setState(() => _selectedPage = AppPage.register),
                              style: TextButton.styleFrom(
                                foregroundColor: kAppPrimaryColor,
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
        ),
      ],
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() => _selectedPage = AppPage.home);
                      },
                      child: SvgPicture.asset(
                        'public/img/logo/logo.svg',
                        height: 40,
                        placeholderBuilder: (context) => const SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Grounded Cars', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildDrawerNavTile('Home', AppPage.home),
            _buildDrawerNavTile('Services', AppPage.services),
            _buildDrawerNavTile('My Listings', AppPage.manageListings),
            _buildDrawerNavTile('Request Service', AppPage.requestService),
            if (_isAdminUser) _buildDrawerNavTile('Admin', AppPage.admin),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _currentUser != null
                  ? TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          _currentUser = null;
                          _selectedPage = AppPage.home;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: kAppPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Logout'),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() => _selectedPage = AppPage.login);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: kAppPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Sign In'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() => _selectedPage = AppPage.register);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: kAppPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerNavTile(String label, AppPage page, {VoidCallback? onPressed}) {
    final bool active = _selectedPage == page;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? kAppPrimaryColor : kAppBodyTextColor,
        ),
      ),
      onTap: onPressed ?? () {
        Navigator.of(context).pop();
        setState(() => _selectedPage = page);
      },
    );
  }

  Widget _buildNavButton(String label, AppPage page, {VoidCallback? onPressed}) {
    final bool active = _selectedPage == page;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: active ? kAppPrimaryColor : kAppBodyTextColor,
          textStyle: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal),
        ),
        onPressed: onPressed ?? () => setState(() => _selectedPage = page),
        child: Text(label),
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
        backgroundColor: kAppSuccessColor,
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
            _buildServicesSection(),
            _buildFilterSection(),
            _buildCarListingsSection(),
            _buildSellRentSection(),
            _buildWhyChooseSection(),
            _buildFooter(),
          ],
        );
      case AppPage.services:
        return _buildServicesPage();
      case AppPage.serviceDetails:
        return _buildServiceDetailsSection();
      case AppPage.listingDetails:
        return _buildListingDetailsSection();
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
    final isMobile = _isMobile(context);
    return Padding(
      padding: _responsiveSectionPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Card(
            color: kAppCardColor,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 20.0 : 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.person_add_alt_1, color: kAppPrimaryColor, size: 32),
                      SizedBox(width: 14),
                      Text('Sign Up', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _registerFormKey,
                    child: Column(
                      children: [
                        if (isMobile) ...[
                          _buildTextField(controller: _regFullNameController, label: 'Full name', prefixIcon: Icons.person, validator: _requiredValidator),
                          _buildTextField(controller: _regEmailController, label: 'Email address', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email, validator: _requiredValidator),
                        ] else
                          Row(
                            children: [
                              Expanded(child: _buildTextField(controller: _regFullNameController, label: 'Full name', prefixIcon: Icons.person, validator: _requiredValidator)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField(controller: _regEmailController, label: 'Email address', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email, validator: _requiredValidator)),
                            ],
                          ),
                        if (isMobile) ...[
                          _buildTextField(controller: _regPhoneController, label: 'Phone number', keyboardType: TextInputType.phone, prefixIcon: Icons.phone_android, validator: _requiredValidator),
                          _buildTextField(controller: _regLocationController, label: 'Location', prefixIcon: Icons.location_on, validator: _requiredValidator),
                        ] else
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
                            child: const Text('Already have an account? Sign in', style: TextStyle(color: kAppPrimaryColor)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitRegisterForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAppPrimaryColor,
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
    final isMobile = _isMobile(context);
    return Padding(
      padding: _responsiveSectionPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            color: kAppCardColor,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 20.0 : 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.login, color: kAppPrimaryColor, size: 32),
                      SizedBox(width: 14),
                      Text('Sign In', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        _buildTextField(controller: _loginEmailController, label: 'Email address', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email, validator: _requiredValidator),
                        _buildTextField(controller: _loginPasswordController, label: 'Password', obscureText: true, prefixIcon: Icons.lock, validator: _requiredValidator),
                        const SizedBox(height: 12),
                        isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextButton(
                                    onPressed: _showForgotPasswordDialog,
                                    child: const Text('Forgot password?', style: TextStyle(color: kAppPrimaryColor)),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() => _selectedPage = AppPage.register),
                                    child: const Text('Need an account? Sign up', style: TextStyle(color: kAppPrimaryColor)),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: _showForgotPasswordDialog,
                                    child: const Text('Forgot password?', style: TextStyle(color: kAppPrimaryColor)),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() => _selectedPage = AppPage.register),
                                    child: const Text('Need an account? Sign up', style: TextStyle(color: kAppPrimaryColor)),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitLoginForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAppPrimaryColor,
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

    final isMobile = _isMobile(context);
    return Padding(
      padding: _responsiveSectionPadding(context),
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
          isMobile
              ? Column(
                  children: _listingPackages
                      .map((pkg) => Card(
                            color: pkg.isFeatured ? Color(0xFFEAF4FF) : Colors.grey.shade100,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kAppHeaderTextColor)),
                                  const SizedBox(height: 8),
                                  Text(pkg.price, style: const TextStyle(fontSize: 14, color: kAppHeaderTextColor)),
                                  const SizedBox(height: 8),
                                  Text('Max Listings: ${pkg.maxListings}', style: const TextStyle(fontSize: 12, color: kAppBodyTextColor)),
                                  Text('Duration: ${pkg.durationDays} days', style: const TextStyle(fontSize: 12, color: kAppBodyTextColor)),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                )
              : Row(
                  children: _listingPackages
                      .map((pkg) => Expanded(
                            child: Card(
                              color: pkg.isFeatured ? Color(0xFFEAF4FF) : Colors.grey.shade100,
                              margin: const EdgeInsets.only(right: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kAppHeaderTextColor)),
                                    const SizedBox(height: 8),
                                    Text(pkg.price, style: const TextStyle(fontSize: 14, color: kAppHeaderTextColor)),
                                    const SizedBox(height: 8),
                                    Text('Max Listings: ${pkg.maxListings}', style: const TextStyle(fontSize: 12, color: kAppBodyTextColor)),
                                    Text('Duration: ${pkg.durationDays} days', style: const TextStyle(fontSize: 12, color: kAppBodyTextColor)),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
          const SizedBox(height: 24),
          Form(
            key: _listingFormKey,
            child: Column(
              children: [
                _buildTextField(controller: _listingTitleController, label: 'Listing Title', validator: _requiredValidator),
                if (isMobile) ...[
                  _buildTextField(controller: _listingMakeController, label: 'Make', validator: _requiredValidator),
                  _buildTextField(controller: _listingModelController, label: 'Model', validator: _requiredValidator),
                ] else
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _listingMakeController, label: 'Make', validator: _requiredValidator)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(controller: _listingModelController, label: 'Model', validator: _requiredValidator)),
                    ],
                  ),
                if (isMobile) ...[
                  _buildTextField(controller: _listingYearController, label: 'Year', keyboardType: TextInputType.number, validator: _requiredValidator),
                  _buildTextField(controller: _listingMileageController, label: 'Mileage', keyboardType: TextInputType.number, validator: _requiredValidator),
                ] else
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _listingYearController, label: 'Year', keyboardType: TextInputType.number, validator: _requiredValidator)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(controller: _listingMileageController, label: 'Mileage', keyboardType: TextInputType.number, validator: _requiredValidator)),
                    ],
                  ),
                if (isMobile) ...[
                  _buildDropdownField(controller: _listingConditionController, label: 'Condition', items: ['Used', 'Grounded'], validator: _requiredValidator),
                  _buildDropdownField(controller: _listingTransmissionController, label: 'Transmission', items: ['Hybrid', 'Manual', 'Automatic'], validator: _requiredValidator),
                ] else
                  Row(
                    children: [
                      Expanded(child: _buildDropdownField(controller: _listingConditionController, label: 'Condition', items: ['Used', 'Grounded'], validator: _requiredValidator)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDropdownField(controller: _listingTransmissionController, label: 'Transmission', items: ['Hybrid', 'Manual', 'Automatic'], validator: _requiredValidator)),
                    ],
                  ),
                if (isMobile) ...[
                  _buildDropdownField(controller: _listingFuelController, label: 'Fuel Type', items: ['Hybrid', 'Petrol', 'Diesel', 'Electronic'], validator: _requiredValidator),
                  _buildTextField(controller: _listingLocationController, label: 'Location', validator: _requiredValidator),
                ] else
                  Row(
                    children: [
                      Expanded(child: _buildDropdownField(controller: _listingFuelController, label: 'Fuel Type', items: ['Hybrid', 'Petrol', 'Diesel', 'Electronic'], validator: _requiredValidator)),
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
                  items: (_isAdminUser ? ['For Sale', 'For Hire', 'Grounded Car'] : ['For Sale', 'Grounded Car'])
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
                _buildTextField(controller: _listingDescriptionController, label: 'Description', validator: _requiredValidator),
                const SizedBox(height: 16),
                _buildImageUrlEntry(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isUploadingImages ? null : _submitListingForm,
                  child: _isUploadingImages
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Listing'),
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
          if (_listings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No listings have been created yet.', style: TextStyle(color: kAppBodyTextColor)),
            )
          else
            GridView.count(
              crossAxisCount: _responsiveColumns(context, desktop: 4),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
              children: _listings.map((listing) => Card(
                    color: kAppCardColor,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (listing.imageUrls.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 120,
                                width: double.infinity,
                                child: _ImageSlider(imageUrls: listing.imageUrls),
                              ),
                            ),
                          if (listing.imageUrls.isNotEmpty) const SizedBox(height: 12),
                          Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Text('${listing.year} ${listing.make} ${listing.model}', style: const TextStyle(fontSize: 13, color: kAppBodyTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Text('Status: ${listing.status}', style: const TextStyle(fontSize: 13)),
                          Text('Package: ${listing.packageType}', style: const TextStyle(fontSize: 13)),
                          if (listing.isFeatured)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text('Featured listing', style: TextStyle(color: kAppPrimaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          const SizedBox(height: 8),
                          Text('Price: ${listing.price}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Mileage: ${listing.mileage}', style: const TextStyle(fontSize: 13)),
                          Text('Condition: ${listing.condition}', style: const TextStyle(fontSize: 13)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Contact: ${listing.ownerPhone}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedCarListing = listing;
                                    _selectedPage = AppPage.listingDetails;
                                  });
                                },
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
            )
        ],
      ),
    );
  }

  Widget _buildAdminSection() {
    final isMobile = _isMobile(context);
    if (!_isAdminUser) {
      return Padding(
        padding: _responsiveSectionPadding(context),
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
      initialIndex: _adminTabIndex,
      child: Padding(
        padding: _responsiveSectionPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Admin Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 16) / 2;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildAdminSummaryCard('Users', _users.length.toString(), 'Manage accounts', width: cardWidth > 160 ? cardWidth : double.infinity),
                              _buildAdminSummaryCard('Listings', _listings.length.toString(), 'Approve / feature', width: cardWidth > 160 ? cardWidth : double.infinity),
                              _buildAdminSummaryCard('Payments', _paymentRecords.length.toString(), 'Track invoices', width: cardWidth > 160 ? cardWidth : double.infinity),
                            ],
                          );
                        }
                      ),
                    ],
                  )
                : Row(
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
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              onTap: (index) {
                setState(() {
                  _adminTabIndex = index;
                });
              },
              tabs: const [
                Tab(text: 'Listings Management'),
                Tab(text: 'User Management'),
                Tab(text: 'Service Requests'),
                Tab(text: 'Package Management'),
                Tab(text: 'Payment Tracking'),
              ],
              labelColor: kAppLightAccentColor,
              unselectedLabelColor: kAppMutedTextColor,
              indicatorColor: kAppLightAccentColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildAdminTabContent(_adminTabIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTabContent(int index) {
    switch (index) {
      case 0:
        return _buildAdminListingsTab();
      case 1:
        return _buildAdminUsersTab();
      case 2:
        return _buildAdminServiceRequestsTab();
      case 3:
        return _buildAdminPackagesTab();
      case 4:
        return _buildAdminPaymentsTab();
      default:
        return _buildAdminListingsTab();
    }
  }

  Widget _buildAdminListingsTab() {
    final isMobile = _isMobile(context);
    return Column(
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
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  listing.imageUrls.isNotEmpty ? listing.imageUrls[0] : 'https://images.unsplash.com/photo-1542362567-b058c02b56f2?q=80&w=2070&auto=format&fit=crop',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildListingCardDetails(listing, isMobile),
                            ],
                          )
                        : Row(
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
                                child: _buildListingCardDetails(listing, isMobile),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
        ],
      );
  }

  Widget _buildListingCardDetails(CarListing listing, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatusChip(listing.approvalStatus),
                      if (listing.isFeatured)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Chip(
                            label: const Text('FEATURED', style: TextStyle(fontSize: 10, color: Colors.white)),
                            backgroundColor: kAppWarningColor,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(width: 12),
                  _buildStatusChip(listing.approvalStatus),
                  if (listing.isFeatured)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Chip(
                        label: const Text('FEATURED', style: TextStyle(fontSize: 10, color: Colors.white)),
                        backgroundColor: kAppWarningColor,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
        const SizedBox(height: 8),
        Text('Owner: ${listing.ownerName}'),
        Text('(${listing.ownerEmail})', style: const TextStyle(fontSize: 12, color: kAppMutedTextColor)),
        Text('Package: ${listing.packageType} • Channel: ${listing.status}'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCarListing = listing;
                  _selectedPage = AppPage.listingDetails;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Details'),
            ),
            if (listing.approvalStatus == 'Pending')
              ElevatedButton(
                onPressed: () => _updateListing(listing.copyWith(approvalStatus: 'Approved')),
                style: ElevatedButton.styleFrom(backgroundColor: kAppSuccessColor, foregroundColor: Colors.white),
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
                  backgroundColor: listing.isFeatured ? Colors.grey : kAppWarningColor,
                  foregroundColor: Colors.white,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: kAppErrorColor),
              onPressed: () => _deleteListing(listing),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Approved') color = kAppSuccessColor;
    if (status == 'Rejected') color = kAppErrorColor;
    if (status == 'Pending') color = kAppWarningColor;

    return Chip(
      label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildAdminUsersTab() {
    final isMobile = _isMobile(context);
    return Column(
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
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: kAppPrimaryColor,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(user.email, style: const TextStyle(color: kAppMutedTextColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildUserCardDetails(user, isMobile),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            backgroundColor: kAppPrimaryColor,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildUserCardDetails(user, isMobile),
                          ),
                        ],
                      ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildUserCardDetails(User user, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) ...[
          Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(user.email, style: const TextStyle(color: kAppMutedTextColor)),
        ],
        Text(user.phone, style: const TextStyle(color: kAppMutedTextColor, fontSize: 12)),
        Text('Listings: ${user.listingCount}', style: const TextStyle(color: kAppMutedTextColor, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(
              label: Text(user.isAdmin ? 'ADMIN' : 'USER', style: const TextStyle(fontSize: 10)),
              backgroundColor: user.isAdmin ? kAppPrimaryColor.withOpacity(0.18) : Colors.grey.shade100,
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(user.active ? 'ACTIVE' : 'INACTIVE', style: const TextStyle(fontSize: 10)),
              backgroundColor: user.active ? kAppSuccessColor.withOpacity(0.18) : kAppErrorColor.withOpacity(0.18),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(user.hasPaidSubscription ? 'SUBSCRIBED' : 'NOT SUBSCRIBED', style: const TextStyle(fontSize: 10)),
              backgroundColor: user.hasPaidSubscription ? kAppSuccessColor.withOpacity(0.18) : Colors.orange.withOpacity(0.18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => _updateUser(user.copyWith(active: !user.active)),
              style: ElevatedButton.styleFrom(
                backgroundColor: user.active ? kAppErrorColor.withOpacity(0.12) : kAppSuccessColor.withOpacity(0.12),
                foregroundColor: user.active ? kAppErrorColor : kAppSuccessColor,
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
              OutlinedButton(
                onPressed: () {
                  final isActivating = !user.hasPaidSubscription;
                  _updateUser(user.copyWith(
                    hasPaidSubscription: isActivating,
                    subscriptionStartDate: isActivating ? DateTime.now() : null,
                    monthlyListingCount: isActivating ? 0 : user.monthlyListingCount,
                  ));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: user.hasPaidSubscription ? Colors.orange : kAppSuccessColor,
                  side: BorderSide(color: user.hasPaidSubscription ? Colors.orange : kAppSuccessColor),
                ),
                child: Text(user.hasPaidSubscription ? 'Revoke Premium' : 'Activate Premium'),
              ),
            if (user.email != 'admin@groundedcars.co.ke')
              IconButton(
                icon: const Icon(Icons.delete, color: kAppErrorColor),
                onPressed: () => _deleteUser(user),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminServiceRequestsTab() {
    final isMobile = _isMobile(context);
    return Column(
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
                      isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text('${request.type} request', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                                    _buildRequestStatusChip(request.status),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${request.type} request', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                _buildRequestStatusChip(request.status),
                              ],
                            ),
                      const SizedBox(height: 12),
                      isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(Icons.person, 'Requester: ${request.requesterName}'),
                                _buildDetailRow(Icons.phone, 'Contact: ${request.requesterPhone}'),
                                _buildDetailRow(Icons.email, 'Email: ${request.requesterEmail}'),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.directions_car, 'Car: ${request.carDetails}'),
                                _buildDetailRow(Icons.location_on, 'Location: ${request.location}'),
                                _buildDetailRow(Icons.calendar_today, 'Preferred: ${request.preferredDateTime}'),
                              ],
                            )
                          : Row(
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
                      Text('Description: ${request.description}', style: const TextStyle(color: kAppMutedTextColor)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          if (request.status == 'Assigned')
                            ElevatedButton(
                              onPressed: () => _updateServiceRequest(request.copyWith(status: 'In Progress')),
                              child: const Text('Start Work'),
                            ),
                          if (request.status == 'In Progress')
                            ElevatedButton(
                              onPressed: () => _updateServiceRequest(request.copyWith(status: 'Completed')),
                              style: ElevatedButton.styleFrom(backgroundColor: kAppSuccessColor, foregroundColor: Colors.white),
                              child: const Text('Mark Completed'),
                            ),
                          if (request.status != 'Completed' && request.status != 'Rejected')
                            OutlinedButton(
                              onPressed: () => _updateServiceRequest(request.copyWith(status: 'Rejected')),
                              child: const Text('Reject'),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: kAppErrorColor),
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
    );
  }

  Widget _buildRequestStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Completed') color = kAppSuccessColor;
    if (status == 'In Progress') color = kAppPrimaryColor;
    if (status == 'Rejected') color = kAppErrorColor;
    if (status == 'Assigned') color = kAppWarningColor;

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
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildAdminPackagesTab() {
    final isMobile = _isMobile(context);
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (width < 600) {
      crossAxisCount = 1;
    } else if (width < 1000) {
      crossAxisCount = 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Listing Packages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showPackageDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Package'),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Listing Packages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: () => _showPackageDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Package'),
                  ),
                ],
              ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isMobile ? 2.0 : 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _listingPackages.length,
          itemBuilder: (context, index) {
              final pkg = _listingPackages[index];
              return Card(
                color: pkg.isFeatured ? const Color(0xFFEAF4FF) : Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: pkg.isFeatured ? kAppLightAccentColor : Colors.white12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black))),
                          if (pkg.isFeatured) const Icon(Icons.star, color: kAppWarningColor, size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(pkg.price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kAppPrimaryColor)),
                      const SizedBox(height: 4),
                      Text(pkg.description, style: const TextStyle(fontSize: 12, color: Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _showPackageDialog(package: pkg, index: index),
                            child: const Text('Edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: kAppErrorColor, size: 20),
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
    final isMobile = _isMobile(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Tracking', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_paymentRecords.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No payment records found'))))
          else if (isMobile)
            ..._paymentRecords.map((payment) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(payment.userEmail, style: const TextStyle(fontWeight: FontWeight.bold))),
                          _buildPaymentStatusBadge(payment.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Package: ${payment.packageName}', style: const TextStyle(color: kAppMutedTextColor)),
                          Text(payment.amount, style: const TextStyle(fontWeight: FontWeight.bold, color: kAppPrimaryColor)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Date: ${payment.date}', style: const TextStyle(fontSize: 12, color: kAppMutedTextColor)),
                    ],
                  ),
                ),
              );
            }).toList()
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
                      DataCell(_buildPaymentStatusBadge(payment.status)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'Completed' ? kAppSuccessColor.withOpacity(0.18) : kAppWarningColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: TextStyle(color: status == 'Completed' ? kAppSuccessColor : kAppWarningColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildServiceRequestSection() {
    if (_currentUser == null) {
      return Padding(
        padding: _responsiveSectionPadding(context),
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
      padding: _responsiveSectionPadding(context),
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
                      Text('Preferred: ${request.preferredDateTime}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('Assigned to: ${request.assignedTo}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('Status: ${request.status}', style: const TextStyle(color: Colors.white70)),
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
    final isMobile = _isMobile(context);
    return Padding(
      padding: _responsiveSectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Services Marketplace',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kAppHeaderTextColor),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _selectedPage = AppPage.home),
                      style: TextButton.styleFrom(
                        foregroundColor: kAppPrimaryColor,
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Back to Home'),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Text(
                      'Services Marketplace',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kAppHeaderTextColor),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _selectedPage = AppPage.home),
                      style: TextButton.styleFrom(
                        foregroundColor: kAppPrimaryColor,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          const Text(
            'Book on-demand mobile automotive services to your home or office.',
            style: TextStyle(fontSize: 16, color: kAppBodyTextColor),
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: _responsiveColumns(context, desktop: 4),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: _isMobile(context) ? 1.1 : 0.9,
            children: _serviceDefinitions.map((service) => _buildServiceCard(service)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsSection() {
    final isMobile = _isMobile(context);
    final service = _selectedService;
    if (service == null) {
      return Padding(
        padding: _responsiveSectionPadding(context),
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
      padding: _responsiveSectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kAppHeaderTextColor)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _selectedPage = AppPage.services),
                      style: TextButton.styleFrom(
                        foregroundColor: kAppPrimaryColor,
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Back to Services'),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Text(service.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kAppHeaderTextColor)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _selectedPage = AppPage.services),
                      child: const Text('Back to Services', style: TextStyle(color: kAppPrimaryColor)),
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
          Text(service.details, style: const TextStyle(fontSize: 16, color: kAppBodyTextColor, height: 1.5)),
          const SizedBox(height: 24),
          const Text('Service features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kAppHeaderTextColor)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: service.features.map((feature) => Chip(label: Text(feature))).toList(),
          ),
          const SizedBox(height: 32),
          const Text('On-demand mobile service for home or office', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kAppHeaderTextColor)),
          const SizedBox(height: 12),
          const Text('Technicians travel to your location and complete the job on-site, whether at home or at the office.', style: TextStyle(fontSize: 16, color: kAppBodyTextColor, height: 1.5)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _navigateToServiceRequest(service.title),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppPrimaryColor,
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
              Text('Thank you for requesting $serviceName for quick services chat us', style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _selectedPage = _currentUser == null ? AppPage.services : AppPage.requestService);
              },
              child: const Text('view more', style: TextStyle(color: kAppPrimaryColor)),
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
                backgroundColor: kAppSuccessColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHirePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Car Hire', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Thank you for Hiring a Car with us for quick services. Chat us here.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  setState(() => _selectedPage = AppPage.home);
                }
              },
              child: const Text('View More', style: TextStyle(color: kAppPrimaryColor)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final Uri url = Uri.parse('https://wa.me/254719838935');
                Navigator.of(context).pop();
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAppSuccessColor,
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
        style: const TextStyle(color: kAppHeaderTextColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: kAppBodyTextColor),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: kAppPrimaryColor) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kAppPrimaryColor.withOpacity(0.7), width: 1.5)),
          filled: true,
          fillColor: const Color(0xFFF4F7FB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required List<String> items,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: kAppBodyTextColor),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: kAppPrimaryColor) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kAppPrimaryColor.withOpacity(0.7), width: 1.5)),
          filled: true,
          fillColor: const Color(0xFFF4F7FB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: kAppHeaderTextColor))))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => controller.text = value);
          }
        },
        validator: validator,
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showAppSnackBar('You must be logged in to upload images.', isError: true);
        return;
      }

      if (_currentUser != null) {
        bool canUpload = false;
        if (_currentUser!.listingCount < 10) {
          canUpload = true;
        } else if (_currentUser!.hasPaidSubscription) {
          if (_currentUser!.subscriptionStartDate != null) {
            final daysSinceStart = DateTime.now().difference(_currentUser!.subscriptionStartDate!).inDays;
            if (daysSinceStart < 30) {
              if (_currentUser!.monthlyListingCount < 1000) {
                canUpload = true;
              }
            }
          } else {
            // Allowance for missing start date
            canUpload = true;
          }
        }

        if (!canUpload) {
          _showAppSnackBar('You have reached your listing limit. Please subscribe or renew to upload more images.', isError: true);
          return;
        }
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      if (_listingImageUrls.length >= 10) {
        _showAppSnackBar('You can upload a maximum of 10 images. Remove one before adding another.', isError: true);
        return;
      }

      if (_listingImageUrls.length + result.files.length > 10) {
        _showAppSnackBar('Please select fewer files. Maximum 10 images are allowed.', isError: true);
        return;
      }

      setState(() => _isUploadingImages = true);
      
      int successCount = 0;
      int failCount = 0;

      final List<Future<void>> uploadFutures = result.files.asMap().entries.map((entry) async {
        final index = entry.key;
        final file = entry.value;
        try {
          // Use unique file names to avoid collisions, especially when uploading in parallel
          final fileName = 'listing_images/${DateTime.now().millisecondsSinceEpoch}_${index}_${file.name}';
          final storageRef = FirebaseStorage.instance.ref().child(fileName);
          final metadata = SettableMetadata(contentType: _getContentType(file.name));

          Uint8List? fileBytes = file.bytes;
          if (fileBytes == null && !kIsWeb && file.path != null) {
            fileBytes = await readFileBytes(file.path!);
          }

          if (fileBytes == null) {
            failCount++;
            return;
          }

          final uploadTask = storageRef.putData(fileBytes, metadata);
          
          // Add a timeout to prevent infinite loading
          final snapshot = await uploadTask.timeout(const Duration(seconds: 45));
          final downloadUrl = await snapshot.ref.getDownloadURL();

          if (mounted) {
            setState(() {
              _listingImageUrls.add(downloadUrl);
            });
            successCount++;
          }
        } catch (e) {
          debugPrint('Image upload error: $e');
          failCount++;
        }
      }).toList();

      await Future.wait(uploadFutures);

      if (mounted) {
        setState(() => _isUploadingImages = false);
        if (successCount > 0) {
          _showAppSnackBar('Successfully uploaded $successCount image(s).${failCount > 0 ? " $failCount failed." : ""}');
        } else if (failCount > 0) {
          _showAppSnackBar('Failed to upload images. Please check your connection and try again.', isError: true);
        }
      }
    } catch (e) {
      debugPrint('Overall image pick/upload error: $e');
      if (mounted) {
        setState(() => _isUploadingImages = false);
        _showAppSnackBar('An unexpected error occurred: $e', isError: true);
      }
    } finally {
      if (mounted && _isUploadingImages) {
        setState(() => _isUploadingImages = false);
      }
    }
  }

  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  Widget _buildImageUrlEntry() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13213A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add images for the listing', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 8),
          const Text(
            'Upload between 3 and 10 photos. Good photos help your car get noticed.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploadingImages ? null : _pickAndUploadImage,
                  icon: _isUploadingImages
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.photo_library),
                  label: Text(_isUploadingImages ? 'Uploading...' : 'Upload Images from Computer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Selected images: ${_listingImageUrls.length}/10', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(width: 12),
              if (_listingImageUrls.length < 3)
                const Text('Minimum 3 required.', style: TextStyle(color: kAppErrorColor, fontSize: 12)),
            ],
          ),
          if (_listingImageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _listingImageUrls.map((url) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        height: 96,
                        width: 96,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 96,
                            width: 96,
                            color: Colors.grey.shade100,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Image loading error: $error for URL: $url');
                          return Container(
                            height: 96,
                            width: 96,
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.broken_image, color: Colors.black45),
                                SizedBox(height: 4),
                                Text('Error', style: TextStyle(fontSize: 10, color: Colors.black45)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Material(
                      color: Colors.black45,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => _listingImageUrls.remove(url)),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
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

      debugPrint('Checking uniqueness of phone number: $phone');
      final phoneCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get()
          .timeout(const Duration(seconds: 10));

      if (phoneCheck.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The phone number provided is already registered.'),
              backgroundColor: kAppErrorColor,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

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
              backgroundColor: kAppSuccessColor,
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
            backgroundColor: kAppErrorColor,
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
            backgroundColor: kAppWarningColor,
          ),
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout during registration: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operation timed out. Please check your connection.'),
            backgroundColor: kAppWarningColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during registration: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: kAppErrorColor,
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

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kAppCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your email or phone number to receive a password reset link.', style: TextStyle(color: kAppBodyTextColor)),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _forgotPasswordController,
              label: 'Email or Phone Number',
              prefixIcon: Icons.email,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _submitForgotPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppPrimaryColor, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForgotPassword() async {
    final input = _forgotPasswordController.text.trim();
    if (input.isEmpty) return;

    Navigator.pop(context); // Close dialog
    setState(() => _isLoading = true);
    
    try {
      String email = input;
      
      // If input doesn't look like an email, try to find the user by phone number in Firestore
      if (!input.contains('@')) {
        debugPrint('Input is not an email, searching by phone: $input');
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: input)
            .get()
            .timeout(const Duration(seconds: 10));
        
        if (userSnapshot.docs.isEmpty) {
          throw 'No user found with the phone number provided.';
        }
        email = userSnapshot.docs.first.get('email');
        debugPrint('Found email associated with phone: $email');
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email.'),
            backgroundColor: kAppSuccessColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in _submitForgotPassword: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is String ? e : 'An error occurred sending reset link. Please try again.'),
            backgroundColor: kAppErrorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _forgotPasswordController.clear();
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
              backgroundColor: kAppSuccessColor,
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
                backgroundColor: kAppSuccessColor,
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
                backgroundColor: kAppSuccessColor,
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
                backgroundColor: kAppErrorColor,
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
            backgroundColor: kAppErrorColor,
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
            backgroundColor: kAppWarningColor,
          ),
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout during login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operation timed out. Please check your connection.'),
            backgroundColor: kAppWarningColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: kAppErrorColor,
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
    if (_isUploadingImages) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait for image upload to finish before saving the listing.')),
        );
      }
      return;
    }

    if (!_listingFormKey.currentState!.validate() || _currentUser == null) return;
    
    // Check subscription status and listing limits
    bool canList = false;
    String errorMessage = '';

    if (_currentUser!.listingCount < 10) {
      canList = true;
    } else if (_currentUser!.hasPaidSubscription) {
      if (_currentUser!.subscriptionStartDate != null) {
        final now = DateTime.now();
        final daysSinceStart = now.difference(_currentUser!.subscriptionStartDate!).inDays;
        
        if (daysSinceStart < 30) {
          if (_currentUser!.monthlyListingCount < 1000) {
            canList = true;
          } else {
            errorMessage = 'You have reached your monthly limit of 1000 listings. Please wait for renewal or contact support.';
          }
        } else {
          errorMessage = 'Your monthly subscription has expired. Please renew to continue listing.';
        }
      } else {
        // If hasPaidSubscription is true but no start date, we might want to allow it or set a start date
        // For now, let's treat it as a new subscription starting now if we were to be proactive, 
        // but here we'll just show an error or allow it.
        canList = true; // Temporary allowance or you could set errorMessage
      }
    } else {
      errorMessage = 'You have reached the free limit of 10 listings. Please subscribe for KES 2,000 monthly to list up to 1000 cars.';
    }

    if (!canList) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    final selectedPackage = _listingPackages.firstWhere((pkg) => pkg.name == _selectedListingPackage);

    if (_listingImageUrls.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least 3 images for your listing.')),
      );
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
      // Update user listing count
      if (_currentUser != null) {
        int newListingCount = _currentUser!.listingCount + 1;
        int newMonthlyCount = _currentUser!.monthlyListingCount;
        DateTime? newSubStartDate = _currentUser!.subscriptionStartDate;

        if (_currentUser!.hasPaidSubscription) {
          if (_currentUser!.subscriptionStartDate != null) {
            final now = DateTime.now();
            final daysSinceStart = now.difference(_currentUser!.subscriptionStartDate!).inDays;
            if (daysSinceStart >= 30) {
              newMonthlyCount = 1;
              newSubStartDate = now;
            } else {
              newMonthlyCount += 1;
            }
          } else {
            newMonthlyCount += 1;
            newSubStartDate = DateTime.now();
          }
        }

        final updatedUser = _currentUser!.copyWith(
          listingCount: newListingCount,
          monthlyListingCount: newMonthlyCount,
          subscriptionStartDate: newSubStartDate,
        );

        FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update({
          'listingCount': updatedUser.listingCount,
          'monthlyListingCount': updatedUser.monthlyListingCount,
          'subscriptionStartDate': updatedUser.subscriptionStartDate?.toIso8601String(),
        });

        if (mounted) {
          setState(() {
            _currentUser = updatedUser;
          });
        }
      }
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
          color: active ? kAppPrimaryColor : kAppBodyTextColor,
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final isMobile = _isMobile(context);
    const Color heroBg = Color(0xFF1B261C); // Even duller/darker greenish
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 520 : 620),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: heroBg,
        image: DecorationImage(
          image: const AssetImage('public/img/hero-image.png'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          colorFilter: ColorFilter.mode(heroBg.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      padding: _responsiveSectionPadding(context),
      child: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _selectedPage = AppPage.manageListings),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('List Your Car', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                      onPressed: _showHirePopup,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Hire a Car', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome to\nGroundedCars Kenya',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white, // Brighter white
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Kenya's Largest Used, Salvage & Rental Car Marketplace\n& On-Demand Automotive Services",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFE5E7EB), // Brighter light grey
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildLargeButton('Request Service', kAppPrimaryColor, AppPage.services),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 24,
                        runSpacing: 16,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _selectedPage = AppPage.manageListings),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('List Your Car', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          TextButton(
                            onPressed: _showHirePopup,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('Hire a Car', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      const Text(
                        'Welcome to\nGroundedCars Kenya',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // Brighter white
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Kenya's Largest Used, Salvage & Rental Car Marketplace\n& On-Demand Automotive Services",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFE5E7EB), // Brighter light grey
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildLargeButton('Request Service', kAppPrimaryColor, AppPage.services),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLargeButton(String label, Color color, AppPage page, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: onPressed ?? () => setState(() => _selectedPage = page),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAdminSummaryCard(String title, String value, String subtitle, {double? width}) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kAppPrimaryColor)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: kAppMutedTextColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final isMobile = _isMobile(context);
    return Container(
      transform: Matrix4.translationValues(0, isMobile ? 0 : -40, 0),
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore Car Listings',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildTab('All', _selectedTab == 'All'),
                        const SizedBox(width: 8),
                        _buildTab('For Hire', _selectedTab == 'For Hire'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedMake = 'All Makes';
                              _selectedModel = 'Model';
                              _selectedYear = 'Year';
                              _selectedCondition = 'Condition';
                              _selectedTab = 'All';
                            });
                          },
                          child: const Row(
                            children: [
                              Text('View All'),
                              Icon(Icons.chevron_right, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    const Text(
                      'Explore Car Listings',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    _buildTab('All', _selectedTab == 'All'),
                    _buildTab('For Hire', _selectedTab == 'For Hire'),
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
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppPrimaryColor,
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
    return InkWell(
      onTap: () => setState(() => _selectedTab = label),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? kAppPrimaryColor : Colors.grey,
              ),
            ),
            if (active)
              Container(
                height: 2,
                width: 20,
                color: kAppPrimaryColor,
                margin: const EdgeInsets.only(top: 4),
              ),
          ],
        ),
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
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(label, style: const TextStyle(color: kAppBodyTextColor)),
          isExpanded: true,
          items: dropdownItems,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCarListingsSection() {
    final isMobile = _isMobile(context);
    return Container(
      color: kAppBackgroundColor,
      padding: _responsiveSectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kAppPrimaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Explore Car Listings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: kAppHeaderTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedMake = 'All Makes';
                          _selectedModel = 'Model';
                          _selectedYear = 'Year';
                          _selectedCondition = 'Condition';
                          _selectedTab = 'All';
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: kAppPrimaryColor,
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View All'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
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
                            color: kAppPrimaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Explore Car Listings',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: kAppHeaderTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedMake = 'All Makes';
                          _selectedModel = 'Model';
                          _selectedYear = 'Year';
                          _selectedCondition = 'Condition';
                          _selectedTab = 'All';
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: kAppPrimaryColor,
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
                _buildBrandFilter('All Makes', Icons.car_rental, _selectedMake == 'All Makes'),
                _buildBrandFilter('Toyota', Icons.directions_car, _selectedMake == 'Toyota'),
                _buildBrandFilter('Nissan', Icons.directions_car, _selectedMake == 'Nissan'),
                _buildBrandFilter('Mazda', Icons.directions_car, _selectedMake == 'Mazda'),
                _buildBrandFilter('BMW', Icons.directions_car, _selectedMake == 'BMW'),
                _buildBrandFilter('Mercedes-Benz', Icons.directions_car, _selectedMake == 'Mercedes-Benz'),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Builder(
            builder: (context) {
              final approvedListings = _listings.where((listing) {
                // First filter by approval status
                if (listing.approvalStatus != 'Approved') return false;
                
                // Filter by Tab (All vs For Hire)
                if (_selectedTab == 'For Hire' && listing.status != 'For Hire') return false;
                
                // Filter by Make/Brand
                if (_selectedMake != null && _selectedMake != 'All Makes' && 
                    !listing.make.toLowerCase().contains(_selectedMake!.toLowerCase()) &&
                    !listing.title.toLowerCase().contains(_selectedMake!.toLowerCase())) return false;
                
                // Filter by Model
                if (_selectedModel != null && _selectedModel != 'Model' && 
                    !listing.model.toLowerCase().contains(_selectedModel!.toLowerCase())) return false;
                
                // Filter by Year
                if (_selectedYear != null && _selectedYear != 'Year') {
                  if (_selectedYear == 'Earlier') {
                    final year = int.tryParse(listing.year);
                    if (year != null && year >= 2010) return false;
                  } else if (listing.year != _selectedYear) {
                    return false;
                  }
                }
                
                // Filter by Condition
                if (_selectedCondition != null && _selectedCondition != 'Condition') {
                  if (_selectedCondition == 'Used Cars' && listing.condition != 'Used') return false;
                  // Add more condition mapping if needed
                }
                
                return true;
              }).toList();
                  if (approvedListings.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Text(
                      _listings.isEmpty
                          ? 'Loading listings...'
                          : 'No approved car listings are available right now.',
                      style: const TextStyle(fontSize: 16, color: kAppBodyTextColor),
                    ),
                  ),
                );
              }

              return GridView.count(
                crossAxisCount: _responsiveColumns(context, desktop: 4),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 32,
                crossAxisSpacing: 32,
                childAspectRatio: _isMobile(context) ? 1.1 : 0.7,
                children: approvedListings.map((listing) {
                  return _buildCarCard(listing);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListingDetailsSection() {
    final listing = _selectedCarListing;
    if (listing == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Listing not found.', style: TextStyle(fontSize: 18, color: kAppBodyTextColor)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => _selectedPage = AppPage.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final isMobile = _isMobile(context);
    return SingleChildScrollView(
      child: Container(
        color: kAppBackgroundColor,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Back Button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: kAppPrimaryColor),
                  onPressed: () => setState(() => _selectedPage = AppPage.home),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    listing.title,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.w900,
                      color: kAppHeaderTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Content
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Image / Slider
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: listing.imageUrls.isNotEmpty
                          ? SizedBox(
                              height: isMobile ? 300 : 450,
                              width: double.infinity,
                              child: _ImageSlider(imageUrls: listing.imageUrls),
                            )
                          : Container(
                              height: isMobile ? 300 : 450,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Details Grid
                    Wrap(
                      spacing: isMobile ? 20 : 40,
                      runSpacing: isMobile ? 20 : 40,
                      children: [
                        _buildDetailItem('Price', listing.price.isNotEmpty ? listing.price : 'Contact', Icons.attach_money),
                        _buildDetailItem('Year', listing.year, Icons.calendar_today),
                        _buildDetailItem('Mileage', listing.mileage, Icons.speed),
                        _buildDetailItem('Condition', listing.condition, Icons.info_outline),
                        _buildDetailItem('Transmission', listing.transmission, Icons.settings),
                        _buildDetailItem('Fuel Type', listing.fuelType, Icons.local_gas_station),
                        _buildDetailItem('Location', listing.location, Icons.location_on),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 40),
                    
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kAppHeaderTextColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      listing.description,
                      style: const TextStyle(fontSize: 16, color: kAppBodyTextColor, height: 1.6),
                    ),
                    
                    const SizedBox(height: 40),
                    const Text(
                      'Features',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kAppHeaderTextColor),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: listing.features.isNotEmpty
                          ? listing.features.split(',').where((f) => f.trim().isNotEmpty).map((f) => Chip(label: Text(f.trim()))).toList()
                          : [const Text('No specific features listed.', style: TextStyle(color: kAppBodyTextColor))],
                    ),
                    
                    const SizedBox(height: 60),
                    // Contact Owner
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: kAppCardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Interested in this car?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: kAppPrimaryColor.withOpacity(0.1),
                                child: const Icon(Icons.person, color: kAppPrimaryColor),
                              ),
                              const SizedBox(width: 12),
                              Text(listing.ownerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_isAdminUser)
                            isMobile
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.phone),
                                        label: Text(listing.ownerPhone),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kAppPrimaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.email),
                                        label: const Text('Email Owner'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: kAppSecondaryColor,
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(Icons.phone),
                                          label: Text(listing.ownerPhone),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kAppPrimaryColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(Icons.email),
                                          label: const Text('Email Owner'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: kAppSecondaryColor,
                                            padding: const EdgeInsets.symmetric(vertical: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Contact details are hidden for privacy. Only admins can view owner contact information.',
                                style: TextStyle(
                                  color: kAppMutedTextColor,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      width: 200,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kAppPrimaryColor, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: kAppBodyTextColor)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kAppHeaderTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandFilter(String name, IconData icon, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => setState(() => _selectedMake = name),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: active ? kAppPrimaryColor : const Color(0xFFD7E2EF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? kAppPrimaryColor : const Color(0xFFBFCFDE),
              width: 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: kAppPrimaryColor.withOpacity(0.22),
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
                color: active ? Colors.white : const Color(0xFF4A6D8C),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF4A6D8C),
                  fontWeight: active ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarCard(CarListing listing) {
    final bool hasImages = listing.imageUrls.isNotEmpty;
    final String title = listing.title;
    final String tag = listing.status;
    final String price = listing.price.isNotEmpty ? listing.price : 'Contact for price';
    final String? year = listing.year.isNotEmpty ? listing.year : null;
    final String? mileage = listing.mileage.isNotEmpty ? listing.mileage : null;
    final bool isFeatured = listing.isFeatured;
    final String location = listing.location.isNotEmpty ? listing.location : 'Nairobi, Kenya';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCarListing = listing;
          _selectedPage = AppPage.listingDetails;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: kAppCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
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
                  if (hasImages)
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: _ImageSlider(imageUrls: listing.imageUrls),
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
                        color: tag == 'For Sale' ? kAppSuccessColor : kAppPrimaryColor,
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
                          color: kAppWarningColor,
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
                        color: kAppHeaderTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: kAppBodyTextColor),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: const TextStyle(color: kAppBodyTextColor, fontSize: 12),
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
                            color: kAppPrimaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: kAppPrimaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildSpecIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: kAppBodyTextColor, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    final isMobile = _isMobile(context);
    return Container(
      color: const Color(0xFF2B333D),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'On-Demand Car Services',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() => _selectedPage = AppPage.services),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(isMobile ? 'View All' : 'View All Services >'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: isMobile ? 1.2 : 0.85,
            children: _serviceDefinitions.map((service) => _buildServiceCard(service)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceDefinition service) {
    return Card(
      color: const Color(0xFF3F4A57),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  service.shortDescription,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                          backgroundColor: kAppPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _navigateToServiceRequest(service.title),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
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
    final isMobile = _isMobile(context);
    return Container(
      color: Color(0xFF1E293B),
      padding: _responsiveSectionPadding(context),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    children: [
                      TextSpan(text: 'Sell '),
                      TextSpan(text: 'or ', style: TextStyle(fontWeight: FontWeight.normal)),
                      TextSpan(text: 'Rent Out ', style: TextStyle(color: kAppLightAccentColor)),
                      TextSpan(text: 'Your Car Today!'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Get started by creating a listing for sale or hire. Track how many views,\nfavorites, and inquiries your listing receives, and respond to interested renters.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                _buildSmallLargeButton('List Your Car', kAppPrimaryColor, Icons.send, onPressed: () => setState(() => _selectedPage = AppPage.manageListings)),
                const SizedBox(height: 16),
                _buildSmallLargeButton('Hire Your Car', kAppSecondaryColor, Icons.car_rental, onPressed: _showHirePopup),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          children: [
                            TextSpan(text: 'Sell '),
                            TextSpan(text: 'or ', style: TextStyle(fontWeight: FontWeight.normal)),
                            TextSpan(text: 'Rent Out ', style: TextStyle(color: kAppLightAccentColor)),
                            TextSpan(text: 'Your Car Today!'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Get started by creating a listing for sale or hire. Track how many views,\nfavorites, and inquiries your listing receives, and respond to interested renters.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Row(
                  children: [
                    _buildSmallLargeButton('List Your Car', kAppPrimaryColor, Icons.send, onPressed: () => setState(() => _selectedPage = AppPage.manageListings)),
                    const SizedBox(width: 20),
                    _buildSmallLargeButton('Hire Your Car', kAppSecondaryColor, Icons.car_rental, onPressed: _showHirePopup),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSmallLargeButton(String label, Color color, IconData icon, {VoidCallback? onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildWhyChooseSection() {
    return Container(
      color: kAppBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Choose GroundedCars?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (context, constraints) {
            final isMobile = _isMobile(context);
            if (isMobile) {
              return Column(
                children: [
                  _buildFeatureItem(
                    Icons.list_alt,
                    'Free & Premium Listings',
                    'Free for everyone. Change and EDIT to extend your ads\nappropriate, marketing to reach more and offer\nsatisfaction through visibility, reach, and rating.',
                    kAppPrimaryColor,
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    Icons.settings_suggest,
                    'On-Demand Car Services',
                    'Professional watch payments listings car services send\nextensive services, is hiring your sitting for,\ntrade and updates, local ads, building more.',
                    kAppPrimaryColor,
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    Icons.security,
                    'Secure, Easy Payments',
                    'Fast and secure booking, family payments,\npossible, keeping services, better experience for\nusers, easy maintenance, and more.',
                    kAppSecondaryColor,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem(
                  Icons.list_alt,
                  'Free & Premium Listings',
                  'Free for everyone. Change and EDIT to extend your ads\nappropriate, marketing to reach more and offer\nsatisfaction through visibility, reach, and rating.',
                  kAppPrimaryColor,
                ),
                const SizedBox(width: 40),
                _buildFeatureItem(
                  Icons.settings_suggest,
                  'On-Demand Car Services',
                  'Professional watch payments listings car services send\nextensive services, is hiring your sitting for,\ntrade and updates, local ads, building more.',
                  kAppPrimaryColor,
                ),
                const SizedBox(width: 40),
                _buildFeatureItem(
                  Icons.security,
                  'Secure, Easy Payments',
                  'Fast and secure booking, family payments,\npossible, keeping services, better experience for\nusers, easy maintenance, and more.',
                  kAppSecondaryColor,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kAppHeaderTextColor),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: kAppBodyTextColor, fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Color(0xFF111827),
      padding: _responsiveSectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 32,
            runSpacing: 24,
            alignment: WrapAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Grounded Cars', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text(
                      'Discover grounded cars across Kenya, request service, and list vehicles easily with our trusted marketplace.',
                      style: TextStyle(color: Colors.white70, height: 1.6),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Useful Links', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildFooterLink('Home', AppPage.home),
                    _buildFooterLink('Services', AppPage.services),
                    _buildFooterLink('My Listings', AppPage.manageListings),
                    _buildFooterLink('Request Service', AppPage.requestService),
                  ],
                ),
              ),
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Phone: +254 719 838 935', style: TextStyle(color: Colors.white70, height: 1.6)),
                    const SizedBox(height: 8),
                    const Text('Email: support@groundedcars.co.ke', style: TextStyle(color: Colors.white70, height: 1.6)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildWhatsAppGroupButton(
                  label: 'Join Group A',
                  url: 'https://chat.whatsapp.com/INBzE6XzEkxHLbukiutVnH',
                ),
                _buildWhatsAppGroupButton(
                  label: 'Join Group B',
                  url: 'https://chat.whatsapp.com/Ep1RHz89pxU3kQNuEO8gyO',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white12),
          const SizedBox(height: 24),
          const Text('© 2026 GroundedCars. All Rights Reserved.', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label, AppPage page) {
    return InkWell(
      onTap: () => setState(() => _selectedPage = page),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ),
    );
  }

}

class _ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  const _ImageSlider({required this.imageUrls});

  @override
  State<_ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<_ImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrls.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (_currentPage < widget.imageUrls.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox();
    
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemBuilder: (context, index) {
            return Image.network(
              widget.imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
              ),
            );
          },
        ),
        if (widget.imageUrls.length > 1) ...[
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                onPressed: _currentPage > 0 
                  ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                  : null,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 30),
                onPressed: _currentPage < widget.imageUrls.length - 1
                  ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                  : null,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

