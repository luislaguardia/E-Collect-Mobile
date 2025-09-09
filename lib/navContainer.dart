import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ecollect/pages/homePage.dart';
import 'package:ecollect/pages/rewards.dart';
import 'package:ecollect/pages/history.dart';
import 'package:ecollect/pages/profile.dart';
import 'package:ecollect/pages/qr.dart';

class NavigationContainer extends StatefulWidget {
  const NavigationContainer({super.key});

  @override
  State<NavigationContainer> createState() => NavigationContainerState();
}

class NavigationContainerState extends State<NavigationContainer>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController animationController;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    slideAnimation = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
        );
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    if (index != selectedIndex) {
      setState(() {
        selectedIndex = index;
      });
      animationController.forward(from: 0.0);
    }
  }

  Widget getCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return HomePageContent();
      case 1:
        return Rewards();
      case 2:
        return QRContent();
      case 3:
        return HistoryContent();
      case 4:
        return ProfileContent();
      default:
        return HomePageContent();
    }
  }

  Widget _buildNavItem(String assetPath, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                assetPath,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  selectedIndex == index ? Color(0xff92d400) : Colors.grey.shade600,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(position: slideAnimation, child: child);
        },
        child: getCurrentPage(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildNavItem('assets/home.svg', 0),
                _buildNavItem('assets/notification.svg', 1),
                _buildNavItem('assets/qr.svg', 2),
                _buildNavItem('assets/history.svg', 3),
                _buildNavItem('assets/profile.svg', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}