import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ecollect/navContainer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  int currentView = 0;
  static const String BASE_URL =
      'https://ecollect-server.onrender.com/api/auth';

  final _loginControllers = [TextEditingController(), TextEditingController()];
  final _regControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  late AnimationController slideAnimationController,
      popupAnimationController,
      fadeAnimationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> popupScaleAnimation, fadeAnimation;

  List<bool> _loginErrors = [false, false];
  List<bool> _regErrors = [false, false, false];
  bool showPopup = false, isSuccess = false, isLoading = false;
  String popupMessage = '';

  bool _loginPasswordVisible = false;
  bool _regPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
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
    [
      slideAnimationController,
      popupAnimationController,
      fadeAnimationController,
    ].forEach((c) => c.dispose());
    [..._loginControllers, ..._regControllers].forEach((c) => c.dispose());
    super.dispose();
  }

  void switchView(int index) {
    if (index != currentView) {
      setState(() {
        currentView = index;
        _resetErrors();
        showPopup = false;
        isLoading = false;
        //para ma reset password visibility when switching
        _loginPasswordVisible = false;
        _regPasswordVisible = false;
      });
      slideAnimationController.forward(from: 0.0);
    }
  }

  void _resetErrors() {
    _loginErrors = [false, false];
    _regErrors = [false, false, false];
  }

  void showAnimatedPopup(bool success, String message) {
    setState(() {
      showPopup = true;
      isSuccess = success;
      popupMessage = message;
    });
    popupAnimationController.forward(from: 0.0);

    Future.delayed(Duration(milliseconds: 2000), () {
      popupAnimationController.reverse().then((_) {
        setState(() => showPopup = false);

        if (success) {
          if (currentView == 0) {
            _navigateToHome();
          } else {
            _regControllers.forEach((c) => c.clear());
            switchView(0);
          }
        }
      });
    });
  }

  void _navigateToHome() {
    fadeAnimationController.forward().then((_) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, _) => NavigationContainer(),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    });
  }

  Future<void> _handleAuth(bool isLogin) async {
    final controllers = isLogin ? _loginControllers : _regControllers;
    final errors = isLogin ? _loginErrors : _regErrors;

    setState(() {
      for (int i = 0; i < controllers.length; i++) {
        errors[i] = controllers[i].text.isEmpty;
      }
      isLoading = true;
    });

    if (errors.any((e) => e)) {
      setState(() => isLoading = false);
      showAnimatedPopup(false, 'Please fill in all fields');
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$BASE_URL/${isLogin ? 'login' : 'register'}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(
              isLogin
                  ? {
                      'username': controllers[0].text.trim(),
                      'password': controllers[1].text,
                    }
                  : {
                      'fullName': controllers[0].text.trim(),
                      'username': controllers[1].text.trim(),
                      'password': controllers[2].text,
                    },
            ),
          )
          .timeout(Duration(seconds: 10));

      setState(() => isLoading = false);

      if ((isLogin && response.statusCode == 200) ||
          (!isLogin && response.statusCode == 201)) {
        final data = jsonDecode(response.body);

        if (isLogin) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          await prefs.setString('user_id', data['user']['id']);
          await prefs.setString('full_name', data['user']['fullName']);
          await prefs.setString('username', data['user']['username']);
        }

        showAnimatedPopup(
          true,
          data['message'] ?? '${isLogin ? 'Login' : 'Registration'} successful',
        );
      } else {
        final errorData = jsonDecode(response.body);
        showAnimatedPopup(
          false,
          errorData['message'] ??
              '${isLogin ? 'Login' : 'Registration'} failed',
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      String errorMessage = e is TimeoutException
          ? 'Request timeout. Please check your connection.'
          : 'Network error. Please try again.';
      showAnimatedPopup(false, errorMessage);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isError,
    Function(bool) setError, {
    bool obscureText = false,
    bool isPassword = false,
    bool isLogin = true,
  }) {
    bool passwordVisible = isLogin
        ? _loginPasswordVisible
        : _regPasswordVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? !passwordVisible : obscureText,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
            filled: true,
            fillColor: Colors.grey[100],
            border: _buildBorder(isError),
            enabledBorder: _buildBorder(isError),
            focusedBorder: _buildBorder(isError, focused: true),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              if (isLogin) {
                                _loginPasswordVisible = !_loginPasswordVisible;
                              } else {
                                _regPasswordVisible = !_regPasswordVisible;
                              }
                            });
                          },
                  )
                : null,
          ),
          onChanged: (value) {
            if (isError && value.isNotEmpty) {
              setState(() => setError(false));
            }
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  OutlineInputBorder _buildBorder(bool isError, {bool focused = false}) {
    Color color = isError
        ? Colors.red
        : (focused ? Color(0xff92d400) : Colors.grey[300]!);
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildAuthView(bool isLogin) {
    final controllers = isLogin ? _loginControllers : _regControllers;
    final errors = isLogin ? _loginErrors : _regErrors;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            SizedBox(height: 80),
            Image.asset('assets/logoTransparent2.png', width: 220, height: 220),
            SizedBox(height: 20),

            if (isLogin) ...[
              _buildTextField(
                'Username',
                controllers[0],
                errors[0],
                (val) => errors[0] = val,
                isLogin: true,
              ),
              _buildTextField(
                'Password',
                controllers[1],
                errors[1],
                (val) => errors[1] = val,
                isPassword: true,
                isLogin: true,
              ),
            ] else ...[
              _buildTextField(
                'Full Name',
                controllers[0],
                errors[0],
                (val) => errors[0] = val,
                isLogin: false,
              ),
              _buildTextField(
                'Username',
                controllers[1],
                errors[1],
                (val) => errors[1] = val,
                isLogin: false,
              ),
              _buildTextField(
                'Password',
                controllers[2],
                errors[2],
                (val) => errors[2] = val,
                isPassword: true,
                isLogin: false,
              ),
            ],

            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _handleAuth(isLogin),
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
                        isLogin ? 'Login' : 'Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: isLoading ? null : () => switchView(isLogin ? 1 : 0),
              child: Text(
                isLogin ? 'Register' : 'Back to Login',
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
              transitionBuilder: (child, animation) =>
                  SlideTransition(position: slideAnimation, child: child),
              child: _buildAuthView(currentView == 0),
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
