import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDraft {
  // ================= CAR INFO =================
  String carType;
  String carBrand;
  String carModel;
  String carYear;

  /// 🔑 Legacy (fallback only)
  String licensePlate;

  /// ✅ Saudi plate formats (PRIMARY)
  String licensePlateEn;
  String licensePlateAr;

  /// Selected vehicle (from My Vehicles)
  String? vehicleId;

  // ================= SERVICE INFO =================
  String serviceName; // ✅ FROM DATABASE
  String washType;

  /// 🔥 Service ID from Firestore
  String serviceId;

  /// 🔥 Controls booking flow
  /// Values: 'admin_location' | 'user_location'
  String serviceType;

  /// 🔥 Branch ID (only for admin_location)
  String? locationId;

  /// Selected services (Full / Deep extras)
  List<String> selectedWashServices;

  // ================= NOTES =================
  String washNote;
  String deepNote;
  String basicNote;

  // ================= BOOKING INFO =================
  DateTime dateTime;
  TimeOfDay? selectedTime;

  // ================= LOCATION (USER LOCATION) =================
  double? latitude;
  double? longitude;
  String address;
  String city;

  // ================= PAYMENT =================
  String paymentMethod;

  // ================= PRICING =================
  int totalPrice; // 🔥 MUST COME FROM DB / SERVICE

  // ================= EXTRA FLAGS =================
  bool interiorCleaning;
  bool tirePolish;
  bool engineCleaning;
  bool petHairRemoval;

  // ================= CONSTRUCTOR =================
  BookingDraft({
    this.carType = '',
    this.carBrand = '',
    this.carModel = '',
    this.carYear = '',

    // legacy
    this.licensePlate = '',

    // saudi plates
    this.licensePlateEn = '',
    this.licensePlateAr = '',

    this.vehicleId,

    // service
    this.serviceName = '',
    this.washType = '',
    this.serviceId = '',
    this.serviceType = 'user_location',
    this.locationId,

    List<String>? selectedWashServices,

    // notes
    this.washNote = '',
    this.deepNote = '',
    this.basicNote = '',

    // booking
    DateTime? dateTime,
    this.selectedTime,

    // user location
    this.latitude,
    this.longitude,
    this.address = '',
    this.city = '',

    // payment
    this.paymentMethod = '',

    // pricing
    this.totalPrice = 0,

    // extras
    this.interiorCleaning = false,
    this.tirePolish = false,
    this.engineCleaning = false,
    this.petHairRemoval = false,
  })  : selectedWashServices = selectedWashServices ?? [],
        dateTime = dateTime ?? DateTime.now();

  // ================= FIRESTORE =================

  Map<String, dynamic> toMap() {
    return {
      // car
      'carType': carType,
      'carBrand': carBrand,
      'carModel': carModel,
      'carYear': carYear,

      // plates
      'licensePlateEn': licensePlateEn,
      'licensePlateAr': licensePlateAr,
      'licensePlate': licensePlateEn.isNotEmpty
          ? licensePlateEn
          : licensePlate,

      'vehicleId': vehicleId,

      // service
      'serviceId': serviceId,
      'serviceName': serviceName, // ✅ DB SOURCE
      'washType': washType,
      'serviceType': serviceType,
      'locationId': locationId,
      'selectedWashServices': selectedWashServices,

      // notes
      'washNote': washNote,
      'deepNote': deepNote,
      'basicNote': basicNote,

      // booking
      'dateTime': Timestamp.fromDate(dateTime),
      'selectedTime': selectedTime == null
          ? null
          : {
              'hour': selectedTime!.hour,
              'minute': selectedTime!.minute,
            },

      // location
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,

      // payment & pricing
      'paymentMethod': paymentMethod,
      'totalPrice': totalPrice, // 🔥 NO FALLBACK

      // extras
      'interiorCleaning': interiorCleaning,
      'tirePolish': tirePolish,
      'engineCleaning': engineCleaning,
      'petHairRemoval': petHairRemoval,
    };
  }

  // ================= FROM FIRESTORE =================

  factory BookingDraft.fromMap(Map<String, dynamic> map) {
    String s(dynamic v) => v == null ? '' : v.toString();
    int i(dynamic v) => v is int ? v : int.tryParse(s(v)) ?? 0;
    double? d(dynamic v) => v is num ? v.toDouble() : null;

    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(s(v)) ?? DateTime.now();
    }

    TimeOfDay? parseTime(dynamic v) {
      if (v is Map && v['hour'] != null && v['minute'] != null) {
        return TimeOfDay(
          hour: i(v['hour']),
          minute: i(v['minute']),
        );
      }
      return null;
    }

    final plateEn = s(map['licensePlateEn']).isNotEmpty
        ? s(map['licensePlateEn'])
        : s(map['licensePlate']);

    return BookingDraft(
      carType: s(map['carType']),
      carBrand: s(map['carBrand']),
      carModel: s(map['carModel']),
      carYear: s(map['carYear']),

      licensePlate: plateEn,
      licensePlateEn: plateEn,
      licensePlateAr: s(map['licensePlateAr']),

      vehicleId: s(map['vehicleId']).isNotEmpty
          ? s(map['vehicleId'])
          : null,

      // service
      serviceId: s(map['serviceId']),
      serviceName: s(map['serviceName']),
      washType: s(map['washType']),
      serviceType: s(map['serviceType']).isNotEmpty
          ? s(map['serviceType'])
          : 'user_location',
      locationId: s(map['locationId']).isNotEmpty
          ? s(map['locationId'])
          : null,

      selectedWashServices: map['selectedWashServices'] is List
          ? map['selectedWashServices'].whereType<String>().toList()
          : [],

      // notes
      washNote: s(map['washNote']),
      deepNote: s(map['deepNote']),
      basicNote: s(map['basicNote']),

      // booking
      dateTime: parseDate(map['dateTime']),
      selectedTime: parseTime(map['selectedTime']),

      // location
      latitude: d(map['latitude']),
      longitude: d(map['longitude']),
      address: s(map['address']),
      city: s(map['city']),

      // payment
      paymentMethod: s(map['paymentMethod']),
      totalPrice: i(map['totalPrice']), // 🔥 SOURCE OF TRUTH

      // extras
      interiorCleaning: map['interiorCleaning'] == true,
      tirePolish: map['tirePolish'] == true,
      engineCleaning: map['engineCleaning'] == true,
      petHairRemoval: map['petHairRemoval'] == true,
    );
  }
}