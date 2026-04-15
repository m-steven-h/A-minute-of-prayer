// screens/welcome_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../providers/theme_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _showNameInput = false;
  bool _showSuccessAnimation = false;
  String _welcomeText = 'اهلاً بيك';
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _animationController.forward().then((_) {
          setState(() {
            _showNameInput = true;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showNameInput = false;
        _showSuccessAnimation = true;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text.trim());
      await prefs.setBool('isFirstTime', false);

      // انتظار 5 ثوانٍ للأنيميشن قبل الانتقال
      await Future.delayed(const Duration(seconds: 5));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor:
              themeProvider.backgroundColor, // ✅ خلفية بيضاء أو داكنة حسب الثيم
          body: SafeArea(
            child: Stack(
              children: [
                // ✅ خلفية بيضاء بسيطة (أو حسب الثيم)
                Positioned.fill(
                  child: Container(
                    color: themeProvider.backgroundColor,
                  ),
                ),

                // دوائر زخرفية خفيفة جداً
                ..._buildBackgroundCircles(themeProvider),

                // المحتوى الرئيسي
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_showNameInput && !_showSuccessAnimation)
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeAnimation.value,
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4ADE80)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4ADE80)
                                                  .withOpacity(0.2),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.church_rounded,
                                          color: Color(0xFF4ADE80),
                                          size: 80,
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        _welcomeText,
                                        style: GoogleFonts.cairo(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF4ADE80),
                                          shadows: const [
                                            Shadow(
                                              blurRadius: 10,
                                              color: Colors.black12,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        if (_showNameInput && !_showSuccessAnimation)
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.elasticOut,
                                    builder: (context, double value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4ADE80)
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF4ADE80)
                                                    .withOpacity(0.2),
                                                blurRadius: 20,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.church_rounded,
                                            color: Color(0xFF4ADE80),
                                            size: 60,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 40),
                                  Text(
                                    'ما اسمك؟',
                                    style: GoogleFonts.cairo(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'دعنا نتعرف عليك لتبدأ رحلتك الروحية',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      color: themeProvider.secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, double value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 30 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: themeProvider.cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: TextFormField(
                                              controller: _nameController,
                                              textAlign: TextAlign.center,
                                              textDirection: TextDirection.rtl,
                                              style: GoogleFonts.cairo(
                                                fontSize: 18,
                                                color: themeProvider.textColor,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'اكتب اسمك هنا',
                                                hintStyle: GoogleFonts.cairo(
                                                  color: themeProvider
                                                      .secondaryTextColor
                                                      .withOpacity(0.5),
                                                  fontSize: 16,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: BorderSide.none,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 16,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'الرجاء إدخال اسمك';
                                                }
                                                if (value.trim().length < 2) {
                                                  return 'الاسم قصير جداً';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, double value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 50 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: ElevatedButton(
                                            onPressed: _saveUserData,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF4ADE80),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 50,
                                                vertical: 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              elevation: 5,
                                              shadowColor:
                                                  const Color(0xFF4ADE80)
                                                      .withOpacity(0.5),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'متابعة',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // أنيميشن النجاح
                        if (_showSuccessAnimation)
                          _buildSuccessAnimation(themeProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessAnimation(ThemeProvider themeProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80).withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ADE80).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, double angle, child) {
                        return Transform.rotate(
                          angle: angle * 2 * 3.14159,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF4ADE80).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Color(0xFF4ADE80),
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                    const Icon(
                      Icons.church_rounded,
                      color: Color(0xFF4ADE80),
                      size: 100,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Column(
                  children: [
                    Text(
                      'مرحباً بك',
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _nameController.text.trim(),
                      style: GoogleFonts.cairo(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4ADE80),
                        shadows: const [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'نتمنى لك رحلة روحية ممتعة',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: const Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 50),
        Column(
          children: [
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Color(0xFF4ADE80),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'جاري التحميل...',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: themeProvider.secondaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildBackgroundCircles(ThemeProvider themeProvider) {
    final circles = <Widget>[];
    final positions = [
      const Offset(50, 100),
      const Offset(-30, 200),
      const Offset(300, 150),
      const Offset(-20, 500),
      const Offset(320, 600),
      const Offset(100, 700),
    ];
    final sizes = [120.0, 80.0, 150.0, 100.0, 90.0, 130.0];

    for (int i = 0; i < positions.length; i++) {
      circles.add(
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          builder: (context, double value, child) {
            return Positioned(
              left: positions[i].dx,
              top: positions[i].dy - (20 * value),
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: sizes[i],
                  height: sizes[i],
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4ADE80).withOpacity(0.05),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return circles;
  }
}
