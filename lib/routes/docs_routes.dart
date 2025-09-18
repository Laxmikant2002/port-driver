import 'package:flutter/material.dart';
import 'package:driver/screens/document_verification/document_verify/docs_list/view/docs_screen.dart';
import 'package:driver/screens/document_verification/document_verify/aadhar/view/aadhar_screen.dart';
import 'package:driver/screens/document_verification/document_verify/license/view/license_screen.dart';
import 'package:driver/screens/document_verification/document_verify/profile_pic/view/pic_screen.dart';
import 'package:driver/screens/document_verification/document_verify/rc_book/view/rc_screen.dart';
import 'package:driver/screens/document_verification/document_verify/insurance/view/insurance_screen.dart';

class DocsRoutes {
  static const String docsVerification = '/docs-verification';
  static const String aadharVerification = '/aadhar-verification';
  static const String licenseVerification = '/license-verification';
  static const String profilePicVerification = '/profile-picture-verification';
  static const String rcVerification = '/rc-verification';
  static const String insuranceVerification = '/insurance-verification';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      docsVerification: (context) => const DocsPage(),
      aadharVerification: (context) => const AadharScreen(),
      licenseVerification: (context) => const LicenseScreen(),
      profilePicVerification: (context) => const PicScreen(),
      rcVerification: (context) => const RcScreen(),
      insuranceVerification: (context) => const InsuranceScreen(),
    };
  }
}
