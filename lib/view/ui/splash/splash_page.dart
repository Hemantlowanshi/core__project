import 'package:core_project/core/sessions/auth_session.dart';
import 'package:core_project/core/widgets/app_logo.dart';
import 'package:core_project/view/ui/buttompages/main_page.dart';
import 'package:core_project/view/ui/onboarding_page/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/style/theme_style.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String version = '';

  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }

  Future<void> getPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      version = packageInfo.version;
    });

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '679853410873-el4dph39et87n1vnm1c0mnbm1027r5m0.apps.googleusercontent.com',
      );
    } catch (_) {}

    await Future.delayed(
      const Duration(seconds: 2),
    );

    final loggedIn = await AuthSession.isLoggedIn();

    if (!mounted) return;

    final Widget nextScreen =
        loggedIn ? const MainPage() : const OnboardingScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => nextScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: AppLogo(),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Version $version',
              textAlign: TextAlign.center,
              style: AppTextStyle.interRegular(),
            ),
          ),
        ],
      ),
    );
  }
}
