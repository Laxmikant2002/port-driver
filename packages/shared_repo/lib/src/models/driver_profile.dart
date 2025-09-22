import 'package:equatable/equatable.dart';

/// Driver status enum
enum DriverStatus {
  offline,
  online,
  busy,
  suspended,
}

/// Document verification status enum
enum DocumentVerificationStatus {
  pending,
  inProgress,
  verified,
  rejected,
  expired,
}

/// Driver profile model - comprehensive model for complete driver lifecycle
class DriverProfile extends Equatable {
  const DriverProfile({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.profilePicture,
    this.dateOfBirth,
    this.gender,
    this.alternativePhone,
    
    // Vehicle Information
    this.vehicleId,
    this.vehicleType,
    this.plateNumber,
    this.assignedByAdmin = false,
    
    // Work Information
    this.preferredLocation,
    this.serviceArea,
    this.languagesSpoken = const [],
    this.driverStatus = DriverStatus.offline,
    
    // Document Status
    this.documents = const [],
    this.documentVerificationStatus = DocumentVerificationStatus.pending,
    
    // System Managed (not input, backend controls)
    this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.rating = 0.0,
    this.completedTrips = 0,
    this.earningsSummary = 0.0,
    this.lastActiveAt,
    this.isActive = true,
  });

  // Basic Information
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? profilePicture;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? alternativePhone;
  
  // Vehicle Information (assigned by admin or selected from allowed list)
  final String? vehicleId;
  final String? vehicleType;
  final String? plateNumber;
  final bool assignedByAdmin;
  
  // Work Information
  final String? preferredLocation;
  final String? serviceArea;
  final List<String> languagesSpoken;
  final DriverStatus driverStatus;
  
  // Document Status
  final List<Document> documents;
  final DocumentVerificationStatus documentVerificationStatus;
  
  // System Managed (not input, backend controls)
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final double rating;
  final int completedTrips;
  final double earningsSummary;
  final DateTime? lastActiveAt;
  final bool isActive;

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      profilePicture: json['profilePicture'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String) 
          : null,
      gender: json['gender'] as String?,
      alternativePhone: json['alternativePhone'] as String?,
      
      // Vehicle Information
      vehicleId: json['vehicleId'] as String?,
      vehicleType: json['vehicleType'] as String?,
      plateNumber: json['plateNumber'] as String?,
      assignedByAdmin: json['assignedByAdmin'] as bool? ?? false,
      
      // Work Information
      preferredLocation: json['preferredLocation'] as String?,
      serviceArea: json['serviceArea'] as String?,
      languagesSpoken: (json['languagesSpoken'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      driverStatus: DriverStatus.values.firstWhere(
        (e) => e.name == json['driverStatus'],
        orElse: () => DriverStatus.offline,
      ),
      
      // Document Status
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      documentVerificationStatus: DocumentVerificationStatus.values.firstWhere(
        (e) => e.name == json['documentVerificationStatus'],
        orElse: () => DocumentVerificationStatus.pending,
      ),
      
      // System Managed
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completedTrips: json['completedTrips'] as int? ?? 0,
      earningsSummary: (json['earningsSummary'] as num?)?.toDouble() ?? 0.0,
      lastActiveAt: json['lastActiveAt'] != null 
          ? DateTime.parse(json['lastActiveAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'alternativePhone': alternativePhone,
      
      // Vehicle Information
      'vehicleId': vehicleId,
      'vehicleType': vehicleType,
      'plateNumber': plateNumber,
      'assignedByAdmin': assignedByAdmin,
      
      // Work Information
      'preferredLocation': preferredLocation,
      'serviceArea': serviceArea,
      'languagesSpoken': languagesSpoken,
      'driverStatus': driverStatus.name,
      
      // Document Status
      'documents': documents.map((e) => e.toJson()).toList(),
      'documentVerificationStatus': documentVerificationStatus.name,
      
      // System Managed
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerified': isVerified,
      'rating': rating,
      'completedTrips': completedTrips,
      'earningsSummary': earningsSummary,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  DriverProfile copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? profilePicture,
    DateTime? dateOfBirth,
    String? gender,
    String? alternativePhone,
    
    // Vehicle Information
    String? vehicleId,
    String? vehicleType,
    String? plateNumber,
    bool? assignedByAdmin,
    
    // Work Information
    String? preferredLocation,
    String? serviceArea,
    List<String>? languagesSpoken,
    DriverStatus? driverStatus,
    
    // Document Status
    List<Document>? documents,
    DocumentVerificationStatus? documentVerificationStatus,
    
    // System Managed
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    double? rating,
    int? completedTrips,
    double? earningsSummary,
    DateTime? lastActiveAt,
    bool? isActive,
  }) {
    return DriverProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      
      // Vehicle Information
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      assignedByAdmin: assignedByAdmin ?? this.assignedByAdmin,
      
      // Work Information
      preferredLocation: preferredLocation ?? this.preferredLocation,
      serviceArea: serviceArea ?? this.serviceArea,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      driverStatus: driverStatus ?? this.driverStatus,
      
      // Document Status
      documents: documents ?? this.documents,
      documentVerificationStatus: documentVerificationStatus ?? this.documentVerificationStatus,
      
      // System Managed
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      completedTrips: completedTrips ?? this.completedTrips,
      earningsSummary: earningsSummary ?? this.earningsSummary,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        email,
        profilePicture,
        dateOfBirth,
        gender,
        alternativePhone,
        
        // Vehicle Information
        vehicleId,
        vehicleType,
        plateNumber,
        assignedByAdmin,
        
        // Work Information
        preferredLocation,
        serviceArea,
        languagesSpoken,
        driverStatus,
        
        // Document Status
        documents,
        documentVerificationStatus,
        
        // System Managed
        createdAt,
        updatedAt,
        isVerified,
        rating,
        completedTrips,
        earningsSummary,
        lastActiveAt,
        isActive,
      ];

  // Helper getters
  /// Returns true if the driver is currently online and available
  bool get isOnline => driverStatus == DriverStatus.online;
  
  /// Returns true if the driver is currently busy (on a trip)
  bool get isBusy => driverStatus == DriverStatus.busy;
  
  /// Returns true if the driver is suspended
  bool get isSuspended => driverStatus == DriverStatus.suspended;
  
  /// Returns true if all required documents are verified
  bool get areDocumentsVerified => documentVerificationStatus == DocumentVerificationStatus.verified;
  
  /// Returns true if the driver has a vehicle assigned
  bool get hasVehicle => vehicleId != null && vehicleId!.isNotEmpty;
  
  /// Returns the driver's display name (fallback to phone if name is empty)
  String get displayName => fullName.isNotEmpty ? fullName : phoneNumber;
  
  /// Returns the driver's initials for avatar display
  String get initials {
    if (fullName.isEmpty) return phoneNumber.substring(0, 1);
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }
  
  /// Returns a summary of the driver's status
  String get statusSummary {
    if (isSuspended) return 'Suspended';
    if (isBusy) return 'On Trip';
    if (isOnline) return 'Available';
    return 'Offline';
  }
  
  /// Returns the verification status as a readable string
  String get verificationStatusText {
    switch (documentVerificationStatus) {
      case DocumentVerificationStatus.verified:
        return 'Verified';
      case DocumentVerificationStatus.inProgress:
        return 'Under Review';
      case DocumentVerificationStatus.rejected:
        return 'Rejected';
      case DocumentVerificationStatus.expired:
        return 'Expired';
      case DocumentVerificationStatus.pending:
        return 'Pending';
    }
  }
  
  /// Returns the number of completed trips formatted as a string
  String get tripsText => '$completedTrips trip${completedTrips != 1 ? 's' : ''}';
  
  /// Returns the rating formatted as a string
  String get ratingText => rating > 0 ? rating.toStringAsFixed(1) : 'No rating';
  
  /// Returns the earnings formatted as currency
  String get earningsText => '₹${earningsSummary.toStringAsFixed(2)}';
  
  /// Returns true if the driver profile is complete for onboarding
  bool get isProfileComplete {
    return fullName.isNotEmpty &&
           phoneNumber.isNotEmpty &&
           preferredLocation != null &&
           preferredLocation!.isNotEmpty &&
           languagesSpoken.isNotEmpty;
  }
  
  /// Returns true if the driver is ready to start working
  bool get isReadyToWork {
    return isProfileComplete &&
           hasVehicle &&
           areDocumentsVerified &&
           isActive &&
           !isSuspended;
  }
  
  /// Returns a list of missing requirements for the driver to be ready
  List<String> get missingRequirements {
    final missing = <String>[];
    
    if (fullName.isEmpty) missing.add('Full name');
    if (phoneNumber.isEmpty) missing.add('Phone number');
    if (preferredLocation == null || preferredLocation!.isEmpty) {
      missing.add('Preferred location');
    }
    if (languagesSpoken.isEmpty) missing.add('Languages spoken');
    if (!hasVehicle) missing.add('Vehicle assignment');
    if (!areDocumentsVerified) missing.add('Document verification');
    if (isSuspended) missing.add('Account suspension resolved');
    
    return missing;
  }
}
