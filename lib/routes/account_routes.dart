import 'package:flutter/material.dart';
import 'package:driver/screens/account/addvehicle/view/add_vehicle_screen.dart';
import 'package:driver/screens/account/inbox/view/inbox_screen.dart';
import 'package:driver/screens/account/ratings/view/ratings_screen.dart';
import 'package:driver/screens/account/ride_history/views/history_screen.dart';
import 'package:driver/screens/account/document/views/document_screen.dart';
import 'package:driver/screens/account/wallet/view/payment_overview_screen.dart';


class AccountRoutes {
  static const String ridesHistory = '/rides-history';
  static const String ratings = '/ratings';
  static const String documentScreen = '/document-screen';
  static const String addvehicle ='/add-vehicle';
  static const String inbox = '/inbox';
  static const String paymentOverview = '/payment-overview';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      ridesHistory: (context) => const HistoryScreen(),
      ratings: (context) => const RatingsScreen(),
      documentScreen: (context) => const DocumentScreen(),
      addvehicle: (context) => const AddVehicleScreen(),
      inbox: (content) => const InboxScreen(),
      paymentOverview: (context) => const PaymentOverviewScreen(),
    };
  }
}
