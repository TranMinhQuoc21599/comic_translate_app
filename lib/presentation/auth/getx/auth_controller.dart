import 'package:get/get.dart';

class AuthController extends GetxController {
  final _isLoading = false.obs;
  final _error = Rx<String?>(null);

  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  Future<void> login(String email, String password) async {
    _isLoading.value = true;
    try {
      // Implement login logic
      _error.value = null;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}
