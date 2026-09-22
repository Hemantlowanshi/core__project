import 'package:core_project/core/sessions/auth_session.dart';
import 'package:core_project/core/widgets/profile_widgets.dart';
import 'package:core_project/view/ui/map/select_location_screen.dart';
import 'package:core_project/view/ui/onboarding_page/onboarding_page.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/custom_dailog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Logout',
          message: 'Are you sure you want to log out?',
          positiveTextColor: Colors.deepOrange,
          onNegativePressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          onPositivePressed: () async {
            Navigator.of(context).pop(); // Close dialog
            await AuthSession.logout();        // logout screen
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingScreen(),
              ),
              (route) => false,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const UserProfileAvatar(),

            const SizedBox(height: 20),

            const UserNameWidget(),

            const SizedBox(height: 5),

            const UserEmailWidget(),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile Page'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Delivery Addresses'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectLocationScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
