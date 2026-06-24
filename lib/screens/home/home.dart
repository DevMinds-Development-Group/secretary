import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../routes/routes.dart';
import '../../widgets/auth_background.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    const BrandLockup(),
                    const Spacer(flex: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Comenzar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: infoColor,
                          foregroundColor: primaryColor,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthFooter(color: infoColor.withOpacity(0.85)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
