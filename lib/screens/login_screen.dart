import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/widgets/screen_background.dart';
import 'package:watermangment/screens/home_screen.dart';
import 'package:watermangment/screens/admin_home_screen.dart';
import 'package:watermangment/screens/worker_home_screen.dart';
import 'package:watermangment/screens/signup_screen.dart';
import 'package:watermangment/providers/user_provider.dart';
import 'package:watermangment/services/mongo_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'citizen'; // 'citizen', 'admin', 'worker'

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final userMap = await MongoDatabase.loginUser(email, password);
    setState(() => _isLoading = false);

    String role = _selectedRole;
    String name = email.split('@').first;
    if (userMap != null) {
      if (userMap['role'] != null) role = userMap['role'];
      if (userMap['name'] != null) name = userMap['name'];
    }
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    // Save user session in UserProvider
    Provider.of<UserProvider>(context, listen: false).setUser(
      name,
      email,
      userMap != null && userMap['area'] != null ? userMap['area'] : 'Bhayandar East',
      role: role,
    );

    // Route based on role
    if (role == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHomeScreen()));
    } else if (role == 'worker') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WorkerHomeScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  void _quickDemoLogin(String role, String email, String password, String name) {
    _emailController.text = email;
    _passwordController.text = password;
    setState(() {
      _selectedRole = role;
    });

    Provider.of<UserProvider>(context, listen: false).setUser(
      name,
      email,
      'Bhayandar East',
      role: role,
    );

    if (role == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHomeScreen()));
    } else if (role == 'worker') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WorkerHomeScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Image.asset('assets/images/logo.png', height: 90, fit: BoxFit.contain),
                const SizedBox(height: 8),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select your role & log in to AquaSense AI',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 24),

                // Role Selector Chips
                Row(
                  children: [
                    _buildRoleChip('citizen', 'Citizen'),
                    const SizedBox(width: 8),
                    _buildRoleChip('admin', 'Admin'),
                    const SizedBox(width: 8),
                    _buildRoleChip('worker', 'Worker'),
                  ],
                ),
                const SizedBox(height: 20),
                
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Email Address',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.backgroundDark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('Reset Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                content: const Text('Enter your registered email to receive a password reset link.', style: TextStyle(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Password reset link sent to your email!'), backgroundColor: AppTheme.statusGreen),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                                    child: const Text('Send Link', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.cyanAccent)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('Log In as ${_selectedRole[0].toUpperCase()}${_selectedRole.substring(1)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Demo Logins Banner
                const Text('Instant Demo Logins:', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDemoChip('User Demo', () => _quickDemoLogin('citizen', 'citizen@aquasense.ai', '123456', 'Yash (Citizen)')),
                    const SizedBox(width: 6),
                    _buildDemoChip('Admin Demo', () => _quickDemoLogin('admin', 'yashhalde18@gmail.com', 'Mrunali@2006', 'Yash Halde (Admin)')),
                    const SizedBox(width: 6),
                    _buildDemoChip('Worker Demo', () => _quickDemoLogin('worker', 'yash.a.halde24@slrtce.in', 'Yash@1975', 'Yash Halde (Field Worker)')),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account? ', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text('Sign Up', style: TextStyle(color: AppTheme.cyanAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String roleKey, String label) {
    bool isSelected = _selectedRole == roleKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = roleKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppTheme.cyanAccent : Colors.white10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoChip(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.cyanAccent.withOpacity(0.3)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
