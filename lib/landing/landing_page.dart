import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_gate.dart';
import '../l10n/app_localizations.dart';

class LandingPage extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const LandingPage({
    super.key,
    required this.onLanguageChange,
  });

  Future<void> _getStarted(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AuthGate(
          onLanguageChange: onLanguageChange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          // ================= HERO IMAGE =================
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  'assets/images/onboarding_car.jpg',
                  fit: BoxFit.cover,
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // App name
                Positioned(
                  top: 90,
                  left: isArabic ? null : 24,
                  right: isArabic ? 24 : null,
                  child: Text(
                    t.translate('app_name'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= LANGUAGE SWITCH =================
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {
                    onLanguageChange(
                      isArabic
                          ? const Locale('en')
                          : const Locale('ar'),
                    );
                  },
                  child: Text(
                    t.translate('language'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ================= BOTTOM CARD =================
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: SmoothTopCurveClipper(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Title
                    Text(
                      t.translate('landing_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      t.translate('landing_subtitle'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),

                    const SizedBox(height: 32),

                    // ================= START BUTTON =================
                    GestureDetector(
                      onTap: () => _getStarted(context),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ================= DIVIDER =================
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),

                    const SizedBox(height: 16),

                    // ================= POWERED BY =================
                    Column(
                      children: [

                        const Text(
                          "Powered by",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          height: 120,
                          child: Image.asset(
                            "assets/images/image.png",
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Red Sand Technology",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ================= SMOOTH CURVE CLIPPER =================

class SmoothTopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double cornerRadius = 36;
    const double curveDepth = 46;

    final path = Path();

    path.moveTo(0, cornerRadius);

    path.quadraticBezierTo(
      0,
      0,
      cornerRadius,
      0,
    );

    path.lineTo(size.width / 2 - 120, 0);

    path.cubicTo(
      size.width / 2 - 60,
      0,
      size.width / 2 - 60,
      curveDepth,
      size.width / 2,
      curveDepth,
    );

    path.cubicTo(
      size.width / 2 + 60,
      curveDepth,
      size.width / 2 + 60,
      0,
      size.width / 2 + 120,
      0,
    );

    path.lineTo(size.width - cornerRadius, 0);

    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      cornerRadius,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}