import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<bool> login() async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result['statusCode'] == 200 && result['body']['success'] == true) {
        // Save email for profile display in Settings
        const storage = FlutterSecureStorage();
        await storage.write(
            key: 'user_email', value: emailController.text.trim());
        return true;
      } else {
        errorMessage = result['body']['error']?['message'] is List
            ? (result['body']['error']['message'] as List).join('\n')
            : result['body']['error']?['message'] ??
                result['body']['message'] ??
                'Login fallido';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
