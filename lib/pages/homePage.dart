import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ecollect/pages/qr.dart';

// maybe add some pages or something just not to show it below in the "activity section" in homepage

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String selectedActivity = 'Activity';
  int totalPoints = 0;
  List<dynamic> recentTransactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://ecollect-server.onrender.com/api/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalPoints =
              data['user']['transactionStats']['totalPoints']?.toInt() ?? 0;
          recentTransactions = data['user']['recentTransactions'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching dashboard: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Container(
              width: 300,
              height: 300,
              child: Lottie.asset(
                'assets/loadingoption.json',
                repeat: true,
                animate: true,
              ),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                const DashboardTitle(),
                ActivityButtons(
                  onActivityChanged: (activity) =>
                      setState(() => selectedActivity = activity),
                ),
                const SizedBox(height: 10),
                PointsCircle(points: totalPoints),
                const SizedBox(height: 15),
                ActivitySection(
                  activity: selectedActivity,
                  transactions: recentTransactions,
                ),
              ],
            ),
          );
  }
}

class DashboardTitle extends StatelessWidget {
  const DashboardTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: const Text(
        'Dashboard',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 40,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
    );
  }
}

class ActivityButtons extends StatefulWidget {
  final Function(String) onActivityChanged;
  const ActivityButtons({super.key, required this.onActivityChanged});

  @override
  State<ActivityButtons> createState() => _ActivityButtonsState();
}

class _ActivityButtonsState extends State<ActivityButtons> {
  String selectedButton = '';

  Widget _buildButton(String title) {
    final isSelected = selectedButton == title;
    return GestureDetector(
      onTap: () {
        setState(() => selectedButton = title);
        widget.onActivityChanged(title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 50,
        width: 110,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          border: Border.all(color: Colors.black, width: 0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton('Coupons'),
          const SizedBox(width: 10),
          _buildButton('Rewards'),
          const SizedBox(width: 10),
          _buildButton('Vouchers'),
        ],
      ),
    );
  }
}

class PointsCircle extends StatelessWidget {
  final int points;
  const PointsCircle({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      width: 270,
      child: Stack(
        children: [
          Center(
            child: Lottie.asset('assets/confetti2.json', fit: BoxFit.contain),
          ),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.amber,
              ),
              child: Center(
                child: Text(
                  '$points\nPoints',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivitySection extends StatelessWidget {
  final String activity;
  final List<dynamic> transactions;
  const ActivitySection({
    super.key,
    required this.activity,
    required this.transactions,
  });

  String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 1) return "${diff.inDays}d ago";
    if (diff.inHours > 1) return "${diff.inHours}h ago";
    if (diff.inMinutes > 1) return "${diff.inMinutes}m ago";
    return "just now";
  }

  Widget _buildActivityItem(
    String iconPath,
    String title,
    String points,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.amber,
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              fit: BoxFit.scaleDown,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text(
                        points,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 363,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            for (var tx in transactions.take(3))
              _buildActivityItem(
                'assets/recycle.svg',
                tx['scannedObject'] ?? 'Unknown',
                '+${tx['points'] ?? 0}',
                formatTimeAgo(
                  DateTime.tryParse(tx['scannedDate'] ?? '') ?? DateTime.now(),
                ),
              ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRContent()),
              ),
              child: Container(
                width: double.infinity,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Find drop-off location',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
