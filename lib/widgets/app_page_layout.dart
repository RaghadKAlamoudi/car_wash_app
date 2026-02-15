import 'package:flutter/material.dart';

class AppPageLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  /// ✅ OPTIONAL language change callback
  final Function(Locale)? onLanguageChange;

  const AppPageLayout({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.onLanguageChange, // ✅ ADD
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (onBack != null) {
                    onBack!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              )
            : null,
        title: Row(
          children: const [
            Icon(Icons.directions_car, size: 22),
            SizedBox(width: 8),
            Text(
              'Car Shine',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),

        // ✅ Use provided actions OR language menu if callback exists
        actions: actions ??
            (onLanguageChange == null
                ? null
                : [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.language),
                      onSelected: (value) {
                        onLanguageChange!(
                          value == 'en'
                              ? const Locale('en')
                              : const Locale('ar'),
                        );
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'en', child: Text('English')),
                        PopupMenuItem(
                            value: 'ar', child: Text('العربية')),
                      ],
                    ),
                  ]),
      ),
      body: SafeArea(child: child),
    );
  }
}