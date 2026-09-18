import 'package:core_project/core/sessions/auth_session.dart';
import 'package:core_project/view/ui/buttompages/main_page.dart';
import 'package:core_project/view/ui/login_page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  bool _isLoading = false;

  static const String _webClientId =
      '679853410873-el4dph39et87n1vnm1c0mnbm1027r5m0.apps.googleusercontent.com';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _webClientId,
      );

      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      await AuthSession.saveLogin(          // save info
        name: googleUser.displayName ?? 'User',
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${googleUser.displayName ?? googleUser.email}!',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.pink,
              AppColors.purple,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ==================================================
              // CENTER CONTENT + PADDING SLIDE TOGETHER
              // ==================================================

              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 39,
                        right: 39,
                        top: 38,
                        bottom: 150,
                      ),
                      child: _buildPageContent(index),
                    );
                  },
                ),
              ),

              // ==================================================
              // FIXED PAGE INDICATOR
              // ==================================================

              Positioned(
                top: 38,
                right: 39,
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: AppColors.yellow,
                    dotColor: AppColors.white,
                    dotHeight: 5,
                    dotWidth: 6,
                    expansionFactor: 3,
                    spacing: 4,
                  ),
                ),
              ),

              // ==================================================
              // FIXED GOOGLE + SKIP BUTTONS
              // ==================================================

              Positioned(
                left: 39,
                right: 39,
                bottom: 10,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                        _isLoading ? null : _handleGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.red,
                          ),
                        )
                            : Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/google.png',
                              height: 22,
                              width: 22,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                 'Google',
                                overflow: TextOverflow.ellipsis,
                                style:
                                AppTextStyle.interSemiBold(
                                  textSize: 16,
                                  textColor: AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    SizedBox(
                      height: 42,
                      child: TextButton(
                        onPressed:
                        _isLoading ? null : _handleLogin,
                        child: Text(
                          'LOGIN',
                          style: AppTextStyle.interSemiBold(
                            textColor: AppColors.white,
                            textSize: 14,
                          ),
                        ),
                      ),
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

  Widget _buildPageContent(int index) {
    if (index == 0) {
      return const OnboardingPageContent(
        title: 'CYBER\nLINIO',
        discountText: '40%',
        dscntLabel: 'DSCNT',
        techText: 'in technology',
        showFreeShipping: true,
        image: 'assets/images/lap.png',
        footnote:
        '*Valid from 27/03 to 01/09/2026. Min stock: 1 unit',
      );
    }

    if (index == 1) {
      return const OnboardingPageContent(
        title: 'SHOP\nSMART',
        discountText: '30%',
        dscntLabel: 'OFF',
        techText: 'on electronics',
        showFreeShipping: false,
        image: 'assets/images/ppp.png',
        footnote:
        '*Valid for limited time only. Terms apply.',
      );
    }

    return const OnboardingPageContent(
      title: 'FAST\nDELIVERY',
      discountText: '100%',
      dscntLabel: 'SECURE',
      techText: 'to your doorstep',
      showFreeShipping: true,
      image: 'assets/images/abc.png',
      footnote:
      '*Applies to standard nationwide orders.',
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String discountText;
  final String dscntLabel;
  final String techText;
  final bool showFreeShipping;
  final String image;
  final String footnote;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.discountText,
    required this.dscntLabel,
    required this.techText,
    required this.showFreeShipping,
    required this.image,
    required this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.interBold(
            textColor: AppColors.yellow,
            textSize: 45,
          ).copyWith(
            height: 0.95,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              discountText,
              style: AppTextStyle.interSemiBold(
                textColor: AppColors.white,
                textSize: 34,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              dscntLabel,
              style: AppTextStyle.interRegular(
                textSize: 14,
                textColor: AppColors.white,
              ),
            ),
          ],
        ),

        Text(
          techText,
          style: AppTextStyle.interSemiBold(
            textSize: 22,
            textColor: AppColors.white,
          ),
        ),

        const SizedBox(height: 10),

        if (showFreeShipping)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'FREE SHIPPING',
              style: AppTextStyle.interBold(
                textSize: 10,
                textColor: AppColors.red,
              ),
            ),
          ),

        Expanded(
          child: Center(
            child: Image.asset(
              image,
              height: 360,
              fit: BoxFit.contain,
            ),
          ),
        ),

        Center(
          child: Text(
            footnote,
            textAlign: TextAlign.center,
            style: AppTextStyle.interMedium(
              textSize: 10,
              textColor: Colors.grey,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}