import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:task_management_app/models/user.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _username;
  String? _profileImagePath;
  bool _isLoading = false;
  String? _error;
  bool _isFirstLogin = false;
  Map<String, String> _userCredentials = {};
  bool _isAdmin = false;

  String? get userId => _userId;
  String? get username => _username;
  String? get profileImagePath => _profileImagePath;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFirstLogin => _isFirstLogin;
  bool get isAdmin => _isAdmin;

  AuthProvider() {
    _loadUserData();
    _loadUserCredentials().then((_) {
      _initializeDefaultAdmin();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
      _username = prefs.getString('username');
      _profileImagePath = prefs.getString('profileImagePath');
      _isFirstLogin = prefs.getBool('isFirstLogin') ?? false;
      _isAdmin = prefs.getBool('isAdmin') ?? false;

      // Enforce admin status
      if (_userId == 'admin@gmail.com') {
        if (!_isAdmin) {
          // If somehow admin user exists without admin status, log them out
          await logout();
          return;
        }
        _isAdmin = true;
        await prefs.setBool('isAdmin', true);
      }

      print('Loaded user data - userId: $_userId, isAdmin: $_isAdmin');
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
      // On error, reset to safe state
      _userId = null;
      _isAdmin = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getString('userCredentials');
    if (credentialsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(credentialsJson);
      _userCredentials = Map<String, String>.from(decoded);
    }
  }

  Future<void> _saveUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userCredentials', jsonEncode(_userCredentials));
  }

  Future<void> updateEmail(
      String currentEmail, String newEmail, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate current credentials
      if (!_userCredentials.containsKey(currentEmail)) {
        throw 'Current email not found';
      }
      if (_userCredentials[currentEmail] != password) {
        throw 'Invalid password';
      }

      // Check if new email already exists
      if (_userCredentials.containsKey(newEmail)) {
        throw 'New email already registered';
      }

      // Update credentials
      final currentPassword = _userCredentials[currentEmail]!;
      _userCredentials.remove(currentEmail);
      _userCredentials[newEmail] = currentPassword;
      await _saveUserCredentials();

      // Update user data
      _userId = newEmail;
      _username = newEmail.split('@')[0];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _userId!);
      await prefs.setString('username', _username!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e.toString();
    }
  }

  Future<void> updatePassword(
      String email, String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate current credentials
      if (!_userCredentials.containsKey(email)) {
        throw 'Email not found';
      }
      if (_userCredentials[email] != currentPassword) {
        throw 'Invalid current password';
      }

      // Validate new password
      if (newPassword.length < 6) {
        throw 'New password must be at least 6 characters';
      }

      // Update password
      _userCredentials[email] = newPassword;
      await _saveUserCredentials();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e.toString();
    }
  }

  Future<void> register(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simple validation
      if (email.isEmpty || !email.contains('@')) {
        throw 'Invalid email address';
      }
      if (password.length < 6) {
        throw 'Password must be at least 6 characters';
      }

      // Check if user already exists
      if (_userCredentials.containsKey(email)) {
        throw 'Email already registered';
      }

      // Register new user
      _userCredentials[email] = password;
      await _saveUserCredentials();
      _isFirstLogin = true;

      // Set admin status based on email domain
      _isAdmin = email.endsWith('@admin.com');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e.toString();
    }
  }

  Future<void> _initializeDefaultAdmin() async {
    const defaultAdminEmail = 'admin@gmail.com';
    const defaultAdminPassword = 'admin12';

    if (!_userCredentials.containsKey(defaultAdminEmail)) {
      _userCredentials[defaultAdminEmail] = defaultAdminPassword;
      await _saveUserCredentials();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Login attempt - Email: $email');

      // Validate credentials
      if (!_userCredentials.containsKey(email)) {
        throw 'Email not registered';
      }
      if (_userCredentials[email] != password) {
        throw 'Invalid password';
      }

      // Set admin status first
      _isAdmin = (email == 'admin@gmail.com' && password == 'admin12');

      // If this is admin login but from wrong screen, prevent it
      if (email == 'admin@gmail.com' && !_isAdmin) {
        throw 'Invalid admin credentials';
      }

      // Login successful
      _userId = email;
      _username = email.split('@')[0];

      print('Login successful - isAdmin: $_isAdmin');

      // Save user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear any existing data first
      await prefs.setString('userId', _userId!);
      await prefs.setString('username', _username!);
      await prefs.setBool('isAdmin', _isAdmin);
      await prefs.setBool('isFirstLogin', false);
      _isFirstLogin = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear all stored data
      await prefs.clear();

      // Reset all state variables
      _userId = null;
      _username = null;
      _profileImagePath = null;
      _isAdmin = false;
      _isFirstLogin = false;

      // Reload credentials to ensure admin account is available
      await _loadUserCredentials();
      await _initializeDefaultAdmin();

      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_userId == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'profile_${_userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');

      if (_profileImagePath != null) {
        final oldFile = File(_profileImagePath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      _profileImagePath = savedImage.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', _profileImagePath!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw 'Error saving profile image: $e';
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_profileImagePath != null) {
        final file = File(_profileImagePath!);
        if (await file.exists()) {
          await file.delete();
        }
        _profileImagePath = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profileImagePath');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw 'Error deleting profile image: $e';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<User> getAllUsers() {
    return _userCredentials.entries
        .map((entry) => User(
              email: entry.key,
              name: entry.key.split('@')[0],
              isAdmin: entry.key == 'admin@gmail.com',
            ))
        .toList();
  }

  Future<void> deleteUser(String email) async {
    if (email == 'admin@gmail.com') return; // Prevent admin deletion
    _userCredentials.remove(email);
    await _saveUserCredentials();
    notifyListeners();
  }
}
