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

  static const List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'CYBER\nLINIO',
      discountText: '40%',
      discountLabel: 'DSCNT',
      techText: 'in technology',
      showFreeShipping: true,
      image: 'assets/images/lap.png',
      footnote: '*Valid from 27/03 to 01/09/2026. Min stock: 1 unit',
    ),
    OnboardingPageData(
      title: 'SHOP\nSMART',
      discountText: '30%',
      discountLabel: 'OFF',
      techText: 'on electronics',
      showFreeShipping: false,
      image: 'assets/images/ppp.png',
      footnote: '*Valid for limited time only. Terms apply.',
    ),
    OnboardingPageData(
      title: 'FAST\nDELIVERY',
      discountText: '100%',
      discountLabel: 'SECURE',
      techText: 'to your doorstep',
      showFreeShipping: true,
      image: 'assets/images/abc.png',
      footnote: '*Applies to standard nationwide orders.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _webClientId,
      );

      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      await AuthSession.saveLogin(
        name: googleUser.displayName ?? 'User',
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );

      if (!mounted) return;

      _showMessage(
        'Welcome, ${googleUser.displayName ?? googleUser.email}!',
      );

      _goToMainPage();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Google Sign-In failed: $error',
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
    if (_isLoading) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _goToMainPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainPage(),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
              _buildPageView(),
              _buildPageIndicator(),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Positioned.fill(
      child: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          final page = _pages[index];

          return Padding(
            padding: const EdgeInsets.only(
              left: 39,
              right: 39,
              top: 38,
              bottom: 150,
            ),
            child: OnboardingPageContent(
              title: page.title,
              discountText: page.discountText,
              discountLabel: page.discountLabel,
              techText: page.techText,
              showFreeShipping: page.showFreeShipping,
              image: page.image,
              footnote: page.footnote,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      top: 38,
      right: 39,
      child: SmoothPageIndicator(
        controller: _pageController,
        count: _pages.length,
        effect: const ExpandingDotsEffect(
          activeDotColor: AppColors.yellow,
          dotColor: AppColors.white,
          dotHeight: 5,
          dotWidth: 6,
          expansionFactor: 3,
          spacing: 4,
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      left: 39,
      right: 39,
      bottom: 10,
      child: Column(
        children: [
          _buildGoogleButton(),
          const SizedBox(height: 4),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
                style: AppTextStyle.interSemiBold(
                  textSize: 16,
                  textColor: AppColors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 42,
      child: TextButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: Text(
          'LOGIN',
          style: AppTextStyle.interSemiBold(
            textColor: AppColors.white,
            textSize: 14,
          ),
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String discountText;
  final String discountLabel;
  final String techText;
  final bool showFreeShipping;
  final String image;
  final String footnote;

  const OnboardingPageData({
    required this.title,
    required this.discountText,
    required this.discountLabel,
    required this.techText,
    required this.showFreeShipping,
    required this.image,
    required this.footnote,
  });
}

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String discountText;
  final String discountLabel;
  final String techText;
  final bool showFreeShipping;
  final String image;
  final String footnote;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.discountText,
    required this.discountLabel,
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
        _buildTitle(),
        const SizedBox(height: 12),
        _buildDiscount(),
        _buildTechnologyText(),
        const SizedBox(height: 10),
        if (showFreeShipping) _buildFreeShipping(),
        _buildImage(),
        _buildFootnote(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: AppTextStyle.interBold(
        textColor: AppColors.yellow,
        textSize: 45,
      ).copyWith(
        height: 0.95,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildDiscount() {
    return Row(
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
          discountLabel,
          style: AppTextStyle.interRegular(
            textSize: 14,
            textColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTechnologyText() {
    return Text(
      techText,
      style: AppTextStyle.interSemiBold(
        textSize: 22,
        textColor: AppColors.white,
      ),
    );
  }

  Widget _buildFreeShipping() {
    return Container(
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
    );
  }

  Widget _buildImage() {
    return Expanded(
      child: Center(
        child: Image.asset(
          image,
          height: 360,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildFootnote() {
    return Center(
      child: Text(
        footnote,
        textAlign: TextAlign.center,
        style: AppTextStyle.interMedium(
          textSize: 10,
          textColor: Colors.grey,
        ),
      ),
    );
  }
}