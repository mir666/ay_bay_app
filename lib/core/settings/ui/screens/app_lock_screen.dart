import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController pinController = TextEditingController();
  String savedPin = ''; // SharedPreferences থেকে load হবে
  bool isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
    _authenticateBiometric();
  }

  /// SharedPreferences থেকে PIN load
  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedPin = prefs.getString('appLockPin') ?? '1234'; // default PIN 1234
    });
  }

  /// Biometric authentication
  Future<void> _authenticateBiometric() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) return;

      setState(() => isAuthenticating = true);

      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app');

      setState(() => isAuthenticating = false);

      if (didAuthenticate) {
        _unlockApp();
      }
    } catch (e) {
      setState(() => isAuthenticating = false);
      if (kDebugMode) print('Biometric error: $e');
    }
  }

  /// PIN check
  void _checkPin() {
    if (pinController.text == savedPin) {
      _unlockApp();
    } else {
      Get.snackbar(
        'Error',
        'Invalid PIN',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Unlock app
  void _unlockApp() {
    Get.back(); // বা Get.offAll(HomeScreen()) ইত্যাদি
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unlock App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter PIN',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkPin,
                child: const Text('Unlock'),
              ),
              if (isAuthenticating)
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
