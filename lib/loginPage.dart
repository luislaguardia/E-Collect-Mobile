import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ecollect/navContainer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// line 220, shared pref

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  int currentView = 0;

  // still need to move to env file when deployed
  // backend URL

  // static const String BASE_URL = 'http://localhost:5080/api/auth';
  static const String BASE_URL =
      'https://ecollect-server.onrender.com/api/auth';

  // state
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController regUsernameController = TextEditingController();
  TextEditingController regPasswordController = TextEditingController();

  late AnimationController slideAnimationController;
  late AnimationController popupAnimationController;
  late AnimationController fadeAnimationController;

  late Animation<Offset> slideAnimation;
  late Animation<double> popupScaleAnimation;
  late Animation<double> fadeAnimation;

  bool isUsernameError = false;
  bool isPasswordError = false;
  bool isFullNameError = false;
  bool isRegUsernameError = false;
  bool isRegPasswordError = false;

  bool showPopup = false;
  bool isSuccess = false;
  String popupMessage = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    popupAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: slideAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    popupScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: popupAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: fadeAnimationController, curve: Curves.easeInOut),
    );

    slideAnimationController.forward();
  }

  @override
  void dispose() {
    slideAnimationController.dispose();
    popupAnimationController.dispose();
    fadeAnimationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    regUsernameController.dispose();
    regPasswordController.dispose();
    super.dispose();
  }

  void switchView(int index) {
    if (index != currentView) {
      setState(() {
        currentView = index;

        isUsernameError = false;
        isPasswordError = false;
        isFullNameError = false;
        isRegUsernameError = false;
        isRegPasswordError = false;
        showPopup = false;
        isLoading = false;
      });
      slideAnimationController.forward(from: 0.0);
    }
  }

  void showAnimatedPopup(bool success, String message) {
    setState(() {
      showPopup = true;
      isSuccess = success;
      popupMessage = message;
    });
    popupAnimationController.forward(from: 0.0);

    if (success && currentView == 0) {
      // Login success
      Future.delayed(Duration(milliseconds: 2000), () {
        popupAnimationController.reverse().then((_) {
          setState(() {
            showPopup = false;
          });

          fadeAnimationController.forward().then((_) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    NavigationContainer(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
          });
        });
      });
    } else if (success && currentView == 1) {
      // Registration success
      Future.delayed(Duration(milliseconds: 2000), () {
        popupAnimationController.reverse().then((_) {
          setState(() {
            showPopup = false;
          });
          // Switch to login view after successful registration
          fullNameController.clear();
          regUsernameController.clear();
          regPasswordController.clear();
          switchView(0);
        });
      });
    } else {
      // Error
      Future.delayed(Duration(milliseconds: 2000), () {
        popupAnimationController.reverse().then((_) {
          setState(() {
            showPopup = false;
          });
        });
      });
    }
  }

  Future<void> handleLogin() async {
    bool hasError = false;

    setState(() {
      isUsernameError = usernameController.text.isEmpty;
      isPasswordError = passwordController.text.isEmpty;
      isLoading = true;
    });

    hasError = isUsernameError || isPasswordError;

    if (hasError) {
      setState(() {
        isLoading = false;
      });
      showAnimatedPopup(false, 'Please fill in all fields');
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$BASE_URL/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': usernameController.text.trim(),
              'password': passwordController.text,
            }),
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // storing user data - maybe for view profile like that..
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', data['user']['id']);
        await prefs.setString('full_name', data['user']['fullName']);
        await prefs.setString('username', data['user']['username']);

        showAnimatedPopup(true, data['message'] ?? 'Login successful');
      } else {
        final errorData = jsonDecode(response.body);
        showAnimatedPopup(false, errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = 'Network error. Please try again.';
      if (e is TimeoutException) {
        errorMessage = 'Request timeout. Please check your connection.';
      }

      showAnimatedPopup(false, errorMessage);
    }
  }

  Future<void> handleRegister() async {
    bool hasError = false;

    setState(() {
      isFullNameError = fullNameController.text.isEmpty;
      isRegUsernameError = regUsernameController.text.isEmpty;
      isRegPasswordError = regPasswordController.text.isEmpty;
      isLoading = true;
    });

    hasError = isFullNameError || isRegUsernameError || isRegPasswordError;

    if (hasError) {
      setState(() {
        isLoading = false;
      });
      showAnimatedPopup(false, 'Please fill in all fields');
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$BASE_URL/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': fullNameController.text.trim(),
              'username': regUsernameController.text.trim(),
              'password': regPasswordController.text,
            }),
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        showAnimatedPopup(true, data['message'] ?? 'Registration successful');
      } else {
        final errorData = jsonDecode(response.body);
        showAnimatedPopup(false, errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = 'Network error. Please try again.';
      if (e is TimeoutException) {
        errorMessage = 'Request timeout. Please check your connection.';
      }

      showAnimatedPopup(false, errorMessage);
    }
  }

  Widget getCurrentView() {
    switch (currentView) {
      case 0:
        return buildLoginView();
      case 1:
        return buildRegisterView();
      default:
        return buildLoginView();
    }
  }

  Widget buildLoginView() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80),

            Image.asset('assets/logoTransparent2.png', width: 220, height: 220),
            SizedBox(height: 20),

            //user
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Username',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: usernameController,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'Enter your username',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isUsernameError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isUsernameError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isUsernameError ? Colors.red : Color(0xff92d400),
                  ),
                ),
              ),
              onChanged: (value) {
                if (isUsernameError && value.isNotEmpty) {
                  setState(() {
                    isUsernameError = false;
                  });
                }
              },
            ),
            SizedBox(height: 20),

            //pass
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isPasswordError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isPasswordError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isPasswordError ? Colors.red : Color(0xff92d400),
                  ),
                ),
              ),
              onChanged: (value) {
                if (isPasswordError && value.isNotEmpty) {
                  setState(() {
                    isPasswordError = false;
                  });
                }
              },
            ),
            SizedBox(height: 40),

            //login button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff92d400),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),

            //reg link
            GestureDetector(
              onTap: isLoading ? null : () => switchView(1),
              child: Text(
                'Register',
                style: TextStyle(
                  fontSize: 16,
                  color: isLoading ? Colors.grey : Color(0xFFFFBF00),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildRegisterView() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80),

            Image.asset('assets/logoTransparent2.png', width: 220, height: 220),
            SizedBox(height: 20),

            //full name
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: fullNameController,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isFullNameError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isFullNameError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isFullNameError ? Colors.red : Color(0xff92d400),
                  ),
                ),
              ),
              onChanged: (value) {
                if (isFullNameError && value.isNotEmpty) {
                  setState(() {
                    isFullNameError = false;
                  });
                }
              },
            ),
            SizedBox(height: 20),

            //user
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Username',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: regUsernameController,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'Enter your username',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isRegUsernameError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isRegUsernameError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isRegUsernameError ? Colors.red : Color(0xff92d400),
                  ),
                ),
              ),
              onChanged: (value) {
                if (isRegUsernameError && value.isNotEmpty) {
                  setState(() {
                    isRegUsernameError = false;
                  });
                }
              },
            ),
            SizedBox(height: 20),

            //pass
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: regPasswordController,
              obscureText: true,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isRegPasswordError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isRegPasswordError ? Colors.red : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isRegPasswordError ? Colors.red : Color(0xff92d400),
                  ),
                ),
              ),
              onChanged: (value) {
                if (isRegPasswordError && value.isNotEmpty) {
                  setState(() {
                    isRegPasswordError = false;
                  });
                }
              },
            ),
            SizedBox(height: 40),

            //reg button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff92d400),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),

            //balik login
            GestureDetector(
              onTap: isLoading ? null : () => switchView(0),
              child: Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: 16,
                  color: isLoading ? Colors.grey : Color(0xFFFFBF00),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f7),
      body: FadeTransition(
        opacity: fadeAnimation,
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(position: slideAnimation, child: child);
              },
              child: getCurrentView(),
            ),

            if (showPopup)
              Container(
                color: Colors.black54,
                child: Center(
                  child: ScaleTransition(
                    scale: popupScaleAnimation,
                    child: Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            child: Lottie.asset(
                              isSuccess
                                  ? 'assets/newcheck.json'
                                  : 'assets/errorAnimation.json',
                              repeat: false,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              popupMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSuccess ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
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
