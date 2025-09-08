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
        padding: EdgeInsets.all(20),
        color: Color(0xffffffff),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => onItemTapped(0),
              child: Container(
                child: SvgPicture.asset(
                  'assets/home.svg',
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 0 ? Color(0xff92d400) : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                width: 35,
                height: 35,
              ),
            ),

            GestureDetector(
              onTap: () => onItemTapped(1),
              child: Container(
                child: SvgPicture.asset(
                  'assets/notification.svg',
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 1 ? Color(0xff92d400) : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                width: 35,
                height: 35,
              ),
            ),

            GestureDetector(
              onTap: () => onItemTapped(2),
              child: Container(
                child: SvgPicture.asset(
                  'assets/qr.svg',
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 2 ? Color(0xff92d400) : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                width: 35,
                height: 35,
              ),
            ),

            GestureDetector(
              onTap: () => onItemTapped(3),
              child: Container(
                child: SvgPicture.asset(
                  'assets/history.svg',
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 3 ? Color(0xff92d400) : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                width: 35,
                height: 35,
              ),
            ),

            GestureDetector(
              onTap: () => onItemTapped(4),
              child: Container(
                child: SvgPicture.asset(
                  'assets/profile.svg',
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 4 ? Color(0xff92d400) : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                width: 35,
                height: 35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
