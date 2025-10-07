import 'package:local_auth/local_auth.dart';
import 'dart:async';

/// Minimal helper wrapper that delegates to system biometric prompt only.
class BiometricHelper {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheck() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final can = await _auth.canCheckBiometrics;
      return supported && can;
    } catch (_) {
      return false;
    }
  }

  /// Shows the native biometric prompt (FaceID / TouchID / Fingerprint / Device credential fallback if allowed).
  Future<bool> authenticateSystem({String reason = 'Идентифицирайте се'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // --- Compatibility layer (legacy interface expected by biometric_dialog.dart) ---
  // Locking/backoff was removed; always report not locked.
  bool get isLocked => false;
  Duration? get remainingLock => null;
  Future<bool> authenticate() => authenticateSystem();
}
