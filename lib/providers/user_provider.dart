import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = 'User';
  String _email = 'user@example.com';
  String _area = 'Bhayandar East';
  String _role = 'citizen'; // 'citizen', 'admin', 'worker'

  String get name => _name;
  String get email => _email;
  String get area => _area;
  String get role => _role;

  void setUser(String name, String email, String area, {String role = 'citizen'}) {
    _name = name;
    _email = email;
    _area = area;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _name = 'User';
    _email = 'user@example.com';
    _area = 'Bhayandar East';
    _role = 'citizen';
    notifyListeners();
  }
}
