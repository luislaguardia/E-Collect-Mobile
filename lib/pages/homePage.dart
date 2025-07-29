import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ecollect/pages/qr.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => HomePageContentState();
}

class HomePageContentState extends State<HomePageContent> {
  String selectedActivity = 'Activity';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Title(),
          Btns(
            onActivityChanged: (activity) {
              setState(() {
                selectedActivity = activity;
              });
            },
          ),
          SizedBox(height: 10),
          Circle(),
          SizedBox(height: 10),

          Activity(activity: selectedActivity),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Btns extends StatefulWidget {
  final Function(String) onActivityChanged;

  const Btns({super.key, required this.onActivityChanged});

  @override
  _BtnsState createState() => _BtnsState();
}

class _BtnsState extends State<Btns> {
  bool coupon = false;
  bool rewards = false;
  bool voucher = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (!coupon) {
                  coupon = true;
                  rewards = false;
                  voucher = false;
                }
              });
              widget.onActivityChanged('Coupon');
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              child: Container(
                key: ValueKey<bool>(coupon),
                height: 50,
                width: 110,
                decoration: BoxDecoration(
                  color: coupon ? Colors.black : Colors.transparent,
                  border: Border.all(color: Colors.black, width: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Coupons',
                    style: TextStyle(
                      color: coupon ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                if (!rewards) {
                  rewards = true;
                  coupon = false;
                  voucher = false;
                }
              });
              widget.onActivityChanged('Rewards');
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              child: Container(
                key: ValueKey<bool>(rewards),
                height: 50,
                width: 110,
                decoration: BoxDecoration(
                  color: rewards ? Colors.black : Colors.transparent,
                  border: Border.all(color: Colors.black, width: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Rewards',
                    style: TextStyle(
                      color: rewards ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                if (!voucher) {
                  voucher = true;
                  coupon = false;
                  rewards = false;
                }
              });
              widget.onActivityChanged('Vouchers');
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              child: Container(
                key: ValueKey<bool>(voucher),
                height: 50,
                width: 110,
                decoration: BoxDecoration(
                  color: voucher ? Colors.black : Colors.transparent,
                  border: Border.all(color: Colors.black, width: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Vouchers',
                    style: TextStyle(
                      color: voucher ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      margin: EdgeInsets.only(top: 15),
    );
  }
}

class Circle extends StatelessWidget {
  const Circle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      width: 270,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 270,
              height: 270,
              child: Lottie.asset('assets/confetti2.json', fit: BoxFit.contain),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.amber,
              ),
              child: Center(
                child: Text(
                  '800 \n Points', //fetch from db yung points ng user then lagay here
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Activity extends StatelessWidget {
  final String activity;

  const Activity({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            width: 363,
            height: 285,
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 25, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10),
                  Padding(padding: const EdgeInsets.only(left: 15)),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.amber,
                        ),
                        margin: EdgeInsets.only(bottom: 10, left: 3),
                        child: SvgPicture.asset(
                          'assets/recycle.svg',
                          width: 10,
                          height: 10,
                          fit: BoxFit.contain,
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //activity ni user with points on same line
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Dropped off E-waste", //lagay here from db (either dropped off e waste or rewad langs)
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),

                                //points na nakuha ni user
                                Padding(
                                  padding: const EdgeInsets.only(right: 30),
                                  child: Text(
                                    "+200", //lagay here from db
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            //time (how many days ago)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "1d ago", //lagay here from db
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.amber,
                        ),
                        margin: EdgeInsets.only(bottom: 10, left: 3),
                        child: SvgPicture.asset(
                          'assets/recycle.svg',
                          width: 10,
                          height: 10,
                          fit: BoxFit.contain,
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //activity ni user with points on same line
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Dropped off E-waste", //lagay here from db (either dropped off e waste or rewad langs)
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),

                                //points na nakuha ni user
                                Padding(
                                  padding: const EdgeInsets.only(right: 30),
                                  child: Text(
                                    "+200", //lagay here from db
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            //time (how many days ago)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "1d ago", //lagay here from db
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.amber,
                        ),
                        margin: EdgeInsets.only(bottom: 10, left: 3),
                        child: SvgPicture.asset(
                          'assets/reward.svg',
                          width: 10,
                          height: 10,
                          fit: BoxFit.contain,
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Reward", //lagay here from db (either dropped off e waste or reward langs)
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),

                                //points na nakuha ni user
                                Padding(
                                  padding: const EdgeInsets.only(right: 30),
                                  child: Text(
                                    "+200", //lagay here from db
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            //time (how many days ago)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "1d ago", //lagay here from db
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        //onclick listener
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRContent(),
                          ), //here (placeholder para pag clinick mag redirect sa map)
                        );
                      },
                      child: Container(
                        width: 310,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.only(top: 8),
                        child: Center(
                          child: Text(
                            'Find drop-off location',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
