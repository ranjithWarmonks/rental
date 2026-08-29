import 'package:flutter/material.dart';
import 'package:rental/features/rentals/views/add_rental_view.dart';
import 'package:rental/features/profile/views/more_view.dart';
import 'package:rental/presentaion/customers/customers_screen.dart';
import 'package:rental/presentaion/home/home_screen.dart';
import 'package:rental/presentaion/rentals/rentals_screen.dart';
import 'package:rental/shared/theme/app_color.dart';

import 'package:rental/shared/utils/permission_manager.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  void _showPermissionDenied(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Access Denied: You do not have permission for $feature.', style: const TextStyle(fontFamily: 'Urbanist')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onTabTapped(BuildContext context, int index) async {
    if (index == currentIndex && index != 2) return;

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        if (!await PermissionManager.hasPermission('rental-view')) {
          if (context.mounted) _showPermissionDenied(context, 'Rentals Management');
          return;
        }
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RentalsScreen()),
          );
        }
        break;
      case 2:
        if (!await PermissionManager.hasPermission('rental-add')) {
          if (context.mounted) _showPermissionDenied(context, 'Create Rental');
          return;
        }
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRentalView()),
          );
        }
        break;
      case 3:
        if (!await PermissionManager.hasPermission('customer-view')) {
          if (context.mounted) _showPermissionDenied(context, 'Customer Management');
          return;
        }
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CustomersScreen()),
          );
        }
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MoreView()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTabTapped(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: buttonColor1,
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Urbanist', fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Urbanist', fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), activeIcon: Icon(Icons.business_center), label: 'Rentals'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded, size: 28), activeIcon: Icon(Icons.add_circle_rounded, size: 28), label: 'Add'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), activeIcon: Icon(Icons.people), label: 'Customers'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), activeIcon: Icon(Icons.more_horiz), label: 'More'),
      ],
    );
  }
}
