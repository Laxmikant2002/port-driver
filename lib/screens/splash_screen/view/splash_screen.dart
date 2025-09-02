import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:driver/routes/auth_routes.dart';
import 'package:driver/routes/dashboard_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _routeUser);
  }

  void _routeUser() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthRoutes.login,
      (route) => false,
    );
    //For testing purpose
    // Navigator.pushNamedAndRemoveUntil(
    //   context,
    //   DashboardRoutes.home,
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Bg.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/Gaadi_logo_Final.svg',
                width: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
