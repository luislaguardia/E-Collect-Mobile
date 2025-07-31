import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Rewards extends StatelessWidget {
  const Rewards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Rewards',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:
                  MediaQuery.of(context).size.width * 0.9, //90% width ng screen
              height: 90,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.only(left: 20),
              child: Row(
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
                      'assets/reward.svg', //fetch from db nalang based sa ano ibibigay sa user (voucher ba or some shit)

                      fit: BoxFit.contain,
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "Earned a reward", //reward, coupons, etc, not sure pa ask kay boss cilla
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Text(
                                "+200", //gained points
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "1d ago", //time from db
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              margin: EdgeInsets.only(top: 30),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:
                  MediaQuery.of(context).size.width * 0.9, //90% width ng screen
              height: 90,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.only(left: 20),
              child: Row(
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
                      'assets/coupon.svg', //fetch from db nalang based sa activity ng user

                      fit: BoxFit.contain,
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "Earned a coupon", //reward, coupons, etc, not sure pa ask kay boss cilla
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Text(
                                "+200", //gained points
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "1d ago", //time from db
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              margin: EdgeInsets.only(top: 30, bottom: 20),
            ),
          ],
        ),
      ],
    );
  }
}
