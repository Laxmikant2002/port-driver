import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:documents_repo/documents_repo.dart';

/// {@template document_quality_validator}
/// Service for validating document quality and performing auto-crop.
/// {@endtemplate}
class DocumentQualityValidator {
  /// {@macro document_quality_validator}
  const DocumentQualityValidator();

  /// Validates document quality and returns validation result
  Future<DocumentQualityResult> validateDocument({
    required String imagePath,
    required DocumentType documentType,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return DocumentQualityResult.failure('File not found');
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return DocumentQualityResult.failure('Invalid image format');
      }

      final validations = <DocumentQualityCheck>[];

      // Check image resolution
      final resolutionCheck = _checkResolution(image);
      validations.add(resolutionCheck);

      // Check image brightness
      final brightnessCheck = _checkBrightness(image);
      validations.add(brightnessCheck);

      // Check image contrast
      final contrastCheck = _checkContrast(image);
      validations.add(contrastCheck);

      // Check for blur
      final blurCheck = _checkBlur(image);
      validations.add(blurCheck);

      // Check document-specific requirements
      final documentSpecificCheck = _checkDocumentSpecific(image, documentType);
      validations.add(documentSpecificCheck);

      // Check if image needs cropping
      final cropRecommendation = _getCropRecommendation(image, documentType);

      final hasErrors = validations.any((check) => check.status == QualityStatus.error);
      final hasWarnings = validations.any((check) => check.status == QualityStatus.warning);

      return DocumentQualityResult.success(
        validations: validations,
        cropRecommendation: cropRecommendation,
        overallScore: _calculateOverallScore(validations),
        needsRetake: hasErrors,
        needsImprovement: hasWarnings,
      );
    } catch (e) {
      return DocumentQualityResult.failure('Validation failed: ${e.toString()}');
    }
  }

  /// Auto-crops document based on detected edges
  Future<String?> autoCropDocument({
    required String imagePath,
    required DocumentType documentType,
  }) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;

      // Detect document edges
      final edges = _detectDocumentEdges(image);
      if (edges == null) return null;

      // Crop the image
      final croppedImage = img.copyCrop(
        image,
        x: edges.left,
        y: edges.top,
        width: edges.width,
        height: edges.height,
      );

      // Enhance the cropped image
      final enhancedImage = _enhanceImage(croppedImage);

      // Save the cropped image
      final tempDir = await getTemporaryDirectory();
      final fileName = 'cropped_${path.basename(imagePath)}';
      final croppedPath = path.join(tempDir.path, fileName);
      
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(img.encodeJpg(enhancedImage, quality: 95));

      return croppedPath;
    } catch (e) {
      debugPrint('Auto-crop failed: $e');
      return null;
    }
  }

  /// Checks image resolution
  DocumentQualityCheck _checkResolution(img.Image image) {
    final width = image.width;
    final height = image.height;
    final megapixels = (width * height) / 1000000;

    if (megapixels >= 2.0) {
      return DocumentQualityCheck(
        type: QualityCheckType.resolution,
        status: QualityStatus.pass,
        message: 'Good resolution (${megapixels.toStringAsFixed(1)}MP)',
        score: 100,
      );
    } else if (megapixels >= 1.0) {
      return DocumentQualityCheck(
        type: QualityCheckType.resolution,
        status: QualityStatus.warning,
        message: 'Low resolution (${megapixels.toStringAsFixed(1)}MP). Consider retaking.',
        score: 70,
      );
    } else {
      return DocumentQualityCheck(
        type: QualityCheckType.resolution,
        status: QualityStatus.error,
        message: 'Very low resolution (${megapixels.toStringAsFixed(1)}MP). Please retake.',
        score: 30,
      );
    }
  }

  /// Checks image brightness
  DocumentQualityCheck _checkBrightness(img.Image image) {
    final brightness = _calculateBrightness(image);
    
    if (brightness >= 0.3 && brightness <= 0.7) {
      return DocumentQualityCheck(
        type: QualityCheckType.brightness,
        status: QualityStatus.pass,
        message: 'Good brightness level',
        score: 100,
      );
    } else if (brightness >= 0.2 && brightness <= 0.8) {
      return DocumentQualityCheck(
        type: QualityCheckType.brightness,
        status: QualityStatus.warning,
        message: 'Brightness could be improved',
        score: 70,
      );
    } else {
      return DocumentQualityCheck(
        type: QualityCheckType.brightness,
        status: QualityStatus.error,
        message: 'Poor brightness. Please retake in better lighting.',
        score: 30,
      );
    }
  }

  /// Checks image contrast
  DocumentQualityCheck _checkContrast(img.Image image) {
    final contrast = _calculateContrast(image);
    
    if (contrast >= 0.3) {
      return DocumentQualityCheck(
        type: QualityCheckType.contrast,
        status: QualityStatus.pass,
        message: 'Good contrast level',
        score: 100,
      );
    } else if (contrast >= 0.2) {
      return DocumentQualityCheck(
        type: QualityCheckType.contrast,
        status: QualityStatus.warning,
        message: 'Contrast could be improved',
        score: 70,
      );
    } else {
      return DocumentQualityCheck(
        type: QualityCheckType.contrast,
        status: QualityStatus.error,
        message: 'Poor contrast. Please retake in better lighting.',
        score: 30,
      );
    }
  }

  /// Checks for blur
  DocumentQualityCheck _checkBlur(img.Image image) {
    final blurScore = _calculateBlurScore(image);
    
    if (blurScore >= 0.7) {
      return DocumentQualityCheck(
        type: QualityCheckType.blur,
        status: QualityStatus.pass,
        message: 'Image is sharp and clear',
        score: 100,
      );
    } else if (blurScore >= 0.5) {
      return DocumentQualityCheck(
        type: QualityCheckType.blur,
        status: QualityStatus.warning,
        message: 'Image is slightly blurry',
        score: 70,
      );
    } else {
      return DocumentQualityCheck(
        type: QualityCheckType.blur,
        status: QualityStatus.error,
        message: 'Image is too blurry. Please retake with steady hands.',
        score: 30,
      );
    }
  }

  /// Checks document-specific requirements
  DocumentQualityCheck _checkDocumentSpecific(img.Image image, DocumentType documentType) {
    switch (documentType) {
      case DocumentType.drivingLicense:
        return _checkDrivingLicense(image);
      case DocumentType.aadhaar:
        return _checkAadhaar(image);
      case DocumentType.pan:
        return _checkPAN(image);
      default:
        return DocumentQualityCheck(
          type: QualityCheckType.documentSpecific,
          status: QualityStatus.pass,
          message: 'Document format looks good',
          score: 100,
        );
    }
  }

  /// Checks driving license specific requirements
  DocumentQualityCheck _checkDrivingLicense(img.Image image) {
    // Check aspect ratio (driving license should be rectangular)
    final aspectRatio = image.width / image.height;
    
    if (aspectRatio >= 1.4 && aspectRatio <= 1.8) {
      return DocumentQualityCheck(
        type: QualityCheckType.documentSpecific,
        status: QualityStatus.pass,
        message: 'Driving license format looks correct',
        score: 100,
      );
    } else {
      return DocumentQualityCheck(
        type: QualityCheckType.documentSpecific,
        status: QualityStatus.warning,
        message: 'Please ensure the entire driving license is visible',
        score: 70,
      );
    }
  }

  /// Checks Aadhaar specific requirements
  DocumentQualityCheck _checkAadhaar(img.Image image) {
    // Aadhaar cards are typically rectangular
    final aspectRatio = image.width / image.height;
    
    if (aspectRatio >= 1.5 && aspectRatio <= 1.7) {
      return DocumentQualityCheck(
        type: QualityCheckType.documentSpecific,
        status: QualityStatus.pass,
        message: 'Aadhaar card format looks correct',
        score: 100,
      );
    } else {
      return DocumentQualityCheck(
        type: QualityCheckType.documentSpecific,
        status: QualityStatus.warning,
        message: 'Please ensure the entire Aadhaar card is visible',
        score: 70,
      );
    }
  }

  /// Checks PAN specific requirements
  DocumentQualityCheck _checkPAN(img.Image image) {
    // PAN cards are typically rectangular
    final aspectRatio = image.width / image.height;
    
    if (aspectRatio >= 1.3 && aspectRatio <= 1.6) {
      return DocumentQualityCheck(
        type: QualityCheckType.documentSpecific,
        status: QualityStatus.pass,
        message: 'PAN card format looks correct',
        score: 100,
      );
    } else {
      return DocumentQualityCheck(
        type: QualityCheckType.documentSpecific,
        status: QualityStatus.warning,
        message: 'Please ensure the entire PAN card is visible',
        score: 70,
      );
    }
  }

  /// Gets crop recommendation
  CropRecommendation? _getCropRecommendation(img.Image image, DocumentType documentType) {
    final edges = _detectDocumentEdges(image);
    if (edges == null) return null;

    return CropRecommendation(
      cropArea: edges,
      confidence: 0.8,
      reason: 'Auto-crop recommended for better document visibility',
    );
  }

  /// Detects document edges
  DocumentEdges? _detectDocumentEdges(img.Image image) {
    // Simplified edge detection - in a real implementation, you'd use more sophisticated algorithms
    final width = image.width;
    final height = image.height;
    
    // For now, return a crop area that removes 10% from each side
    final marginX = (width * 0.1).round();
    final marginY = (height * 0.1).round();
    
    return DocumentEdges(
      left: marginX,
      top: marginY,
      width: width - (marginX * 2),
      height: height - (marginY * 2),
    );
  }

  /// Enhances image quality
  img.Image _enhanceImage(img.Image image) {
    // Apply basic enhancements
    var enhanced = img.adjustColor(image, brightness: 1.1, contrast: 1.1);
    enhanced = img.convolution(enhanced, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);
    return enhanced;
  }

  /// Calculates overall quality score
  int _calculateOverallScore(List<DocumentQualityCheck> validations) {
    if (validations.isEmpty) return 0;
    
    final totalScore = validations.fold<int>(0, (sum, check) => sum + check.score);
    return (totalScore / validations.length).round();
  }

  /// Calculates image brightness
  double _calculateBrightness(img.Image image) {
    // Simplified brightness calculation
    var totalBrightness = 0.0;
    var pixelCount = 0;
    
    for (var y = 0; y < image.height; y += 10) {
      for (var x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final r = (pixel.r / 255.0);
        final g = (pixel.g / 255.0);
        final b = (pixel.b / 255.0);
        totalBrightness += (r + g + b) / 3.0;
        pixelCount++;
      }
    }
    
    return pixelCount > 0 ? totalBrightness / pixelCount : 0.0;
  }

  /// Calculates image contrast
  double _calculateContrast(img.Image image) {
    // Simplified contrast calculation using standard deviation
    var totalBrightness = 0.0;
    var pixelCount = 0;
    final brightnesses = <double>[];
    
    for (var y = 0; y < image.height; y += 10) {
      for (var x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final r = (pixel.r / 255.0);
        final g = (pixel.g / 255.0);
        final b = (pixel.b / 255.0);
        final brightness = (r + g + b) / 3.0;
        brightnesses.add(brightness);
        totalBrightness += brightness;
        pixelCount++;
      }
    }
    
    if (pixelCount == 0) return 0.0;
    
    final mean = totalBrightness / pixelCount;
    var variance = 0.0;
    
    for (final brightness in brightnesses) {
      variance += (brightness - mean) * (brightness - mean);
    }
    
    return sqrt(variance / pixelCount);
  }

  /// Calculates blur score
  double _calculateBlurScore(img.Image image) {
    // Simplified blur detection using Laplacian variance
    var variance = 0.0;
    var mean = 0.0;
    var pixelCount = 0;
    
    // Calculate mean
    for (var y = 1; y < image.height - 1; y += 5) {
      for (var x = 1; x < image.width - 1; x += 5) {
        final pixel = image.getPixel(x, y);
        final r = (pixel.r / 255.0);
        final g = (pixel.g / 255.0);
        final b = (pixel.b / 255.0);
        mean += (r + g + b) / 3.0;
        pixelCount++;
      }
    }
    
    if (pixelCount == 0) return 0.0;
    mean /= pixelCount;
    
    // Calculate variance
    for (var y = 1; y < image.height - 1; y += 5) {
      for (var x = 1; x < image.width - 1; x += 5) {
        final pixel = image.getPixel(x, y);
        final r = (pixel.r / 255.0);
        final g = (pixel.g / 255.0);
        final b = (pixel.b / 255.0);
        final brightness = (r + g + b) / 3.0;
        variance += (brightness - mean) * (brightness - mean);
      }
    }
    
    return (variance / pixelCount).clamp(0.0, 1.0);
  }
}

/// {@template document_quality_result}
/// Result of document quality validation.
/// {@endtemplate}
class DocumentQualityResult {
  /// {@macro document_quality_result}
  const DocumentQualityResult._({
    required this.isSuccess,
    this.validations,
    this.cropRecommendation,
    this.overallScore,
    this.needsRetake,
    this.needsImprovement,
    this.errorMessage,
  });

  final bool isSuccess;
  final List<DocumentQualityCheck>? validations;
  final CropRecommendation? cropRecommendation;
  final int? overallScore;
  final bool? needsRetake;
  final bool? needsImprovement;
  final String? errorMessage;

  factory DocumentQualityResult.success({
    required List<DocumentQualityCheck> validations,
    CropRecommendation? cropRecommendation,
    required int overallScore,
    required bool needsRetake,
    required bool needsImprovement,
  }) {
    return DocumentQualityResult._(
      isSuccess: true,
      validations: validations,
      cropRecommendation: cropRecommendation,
      overallScore: overallScore,
      needsRetake: needsRetake,
      needsImprovement: needsImprovement,
    );
  }

  factory DocumentQualityResult.failure(String errorMessage) {
    return DocumentQualityResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  bool get isFailure => !isSuccess;
}

/// {@template document_quality_check}
/// Individual quality check result.
/// {@endtemplate}
class DocumentQualityCheck {
  /// {@macro document_quality_check}
  const DocumentQualityCheck({
    required this.type,
    required this.status,
    required this.message,
    required this.score,
  });

  final QualityCheckType type;
  final QualityStatus status;
  final String message;
  final int score;
}

/// {@template crop_recommendation}
/// Recommendation for image cropping.
/// {@endtemplate}
class CropRecommendation {
  /// {@macro crop_recommendation}
  const CropRecommendation({
    required this.cropArea,
    required this.confidence,
    required this.reason,
  });

  final DocumentEdges cropArea;
  final double confidence;
  final String reason;
}

/// {@template document_edges}
/// Document edge coordinates for cropping.
/// {@endtemplate}
class DocumentEdges {
  /// {@macro document_edges}
  const DocumentEdges({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final int left;
  final int top;
  final int width;
  final int height;
}

/// {@template quality_check_type}
/// Type of quality check.
/// {@endtemplate}
enum QualityCheckType {
  resolution('resolution', 'Resolution'),
  brightness('brightness', 'Brightness'),
  contrast('contrast', 'Contrast'),
  blur('blur', 'Sharpness'),
  documentSpecific('document_specific', 'Document Format');

  const QualityCheckType(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// {@template quality_status}
/// Status of quality check.
/// {@endtemplate}
enum QualityStatus {
  pass('pass', 'Pass'),
  warning('warning', 'Warning'),
  error('error', 'Error');

  const QualityStatus(this.value, this.displayName);

  final String value;
  final String displayName;
}
