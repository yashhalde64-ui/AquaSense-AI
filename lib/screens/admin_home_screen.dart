import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/widgets/screen_background.dart';
import 'package:watermangment/services/mongo_service.dart';
import 'package:watermangment/providers/user_provider.dart';
import 'package:watermangment/screens/login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedAdminTab = 0;
  List<Map<String, dynamic>> _allComplaints = [];
  bool _isLoading = true;

  final List<Map<String, String>> _workers = [
    {'name': 'Yash Halde (Field Worker)', 'email': 'yash.a.halde24@slrtce.in'},
    {'name': 'Ramesh (Pipe Engineer - Leakage)', 'email': 'ramesh.worker@aquasense.ai'},
    {'name': 'Suresh (Pressure Specialist)', 'email': 'suresh.worker@aquasense.ai'},
    {'name': 'Mahesh (Water Quality Inspector)', 'email': 'mahesh.worker@aquasense.ai'},
    {'name': 'Dinesh (Outage & Supply Manager)', 'email': 'dinesh.worker@aquasense.ai'},
  ];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final complaints = await MongoDatabase.getAllComplaints();
    if (mounted) {
      setState(() {
        _allComplaints = complaints;
        _isLoading = false;
      });
    }
  }

  void _assignWorker(String complaintId, Map<String, String> worker) async {
    await MongoDatabase.assignComplaintToWorker(
      complaintId: complaintId,
      workerEmail: worker['email']!,
      workerName: worker['name']!,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dispatched to ${worker['name']}!'),
        backgroundColor: AppTheme.statusGreen,
      ),
    );
    _loadComplaints();
  }

  void _approveResolution(String complaintId) async {
    await MongoDatabase.adminApproveResolution(complaintId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resolution Approved! Citizen notified.'),
        backgroundColor: AppTheme.statusGreen,
      ),
    );
    _loadComplaints();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Distinct Admin Command Center Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/logo.png', height: 38),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Municipal Command Center',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: AppTheme.statusGreen, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ADMIN PORTAL | ${user.name}',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.cyanAccent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppTheme.statusRed),
                      onPressed: () {
                        user.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Active Tab Body
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.cyanAccent))
                    : RefreshIndicator(
                        onRefresh: _loadComplaints,
                        color: AppTheme.cyanAccent,
                        child: IndexedStack(
                          index: _selectedAdminTab,
                          children: [
                            _buildDispatchTab(),
                            _buildApprovalTab(),
                            _buildAreaControlTab(),
                            _buildAdminAccountTab(user),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GlassContainer(
            borderRadius: 25,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAdminNavItem(Icons.assignment_turned_in_outlined, 'Dispatch', 0),
                _buildAdminNavItem(Icons.verified_outlined, 'Approvals', 1),
                _buildAdminNavItem(Icons.water_drop_outlined, 'Command', 2),
                _buildAdminNavItem(Icons.admin_panel_settings_outlined, 'Admin', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedAdminTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAdminTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppTheme.cyanAccent : Colors.white60, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppTheme.cyanAccent : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 0: DISPATCH WORKERS ---
  Widget _buildDispatchTab() {
    final list = _allComplaints.where((c) => (c['status'] ?? 'Pending') == 'Pending' || (c['status'] ?? 'Pending') == 'Assigned').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dispatch Field Workers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Assign citizen reported issues to active field engineers.', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 16),

          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Center(child: Text('No pending complaints to dispatch!', style: TextStyle(color: Colors.white54))),
            )
          else
            ...list.map((c) {
              final idStr = c['_id'] != null ? c['_id'].toString().substring(0, 6) : '0';
              String status = c['status'] ?? 'Pending';
              String userImagePath = c['imagePath'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('#CMP-$idStr', style: const TextStyle(color: AppTheme.cyanAccent, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'Assigned' ? AppTheme.primaryBlue.withOpacity(0.3) : AppTheme.statusOrange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(status, style: TextStyle(color: status == 'Assigned' ? AppTheme.cyanAccent : AppTheme.statusOrange, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(c['category'] ?? 'Water Issue', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(c['description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      
                      // Citizen Attached Complaint Photo Preview Section
                      const SizedBox(height: 12),
                      const Text('📷 User Complaint Photo Proof:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      if (userImagePath.isNotEmpty && File(userImagePath).existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(userImagePath),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.white38, size: 20),
                              SizedBox(width: 8),
                              Text('No photo attached by user', style: TextStyle(color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),
                      const Text('Dispatch to Field Engineer:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, String>>(
                            hint: Text(c['assignedWorkerName']?.isNotEmpty == true ? 'Assigned: ${c['assignedWorkerName']}' : 'Select Worker to Assign', style: const TextStyle(color: Colors.white, fontSize: 13)),
                            dropdownColor: AppTheme.backgroundMedium,
                            isExpanded: true,
                            items: _workers.map((w) {
                              return DropdownMenuItem<Map<String, String>>(
                                value: w,
                                child: Text(w['name']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null && c['_id'] != null) {
                                _assignWorker(c['_id'].toHexString(), val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- TAB 1: APPROVAL QUEUE ---
  Widget _buildApprovalTab() {
    final list = _allComplaints.where((c) => (c['status'] ?? 'Pending') == 'Awaiting Approval').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Approval Queue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Review completed work & photo proof submitted by field workers.', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 16),

          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Center(child: Text('No worker submissions awaiting approval!', style: TextStyle(color: Colors.white54))),
            )
          else
            ...list.map((c) {
              final idStr = c['_id'] != null ? c['_id'].toString().substring(0, 6) : '0';
              String userImagePath = c['imagePath'] ?? '';
              String proofImagePath = c['proofImagePath'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('#CMP-$idStr', style: const TextStyle(color: AppTheme.cyanAccent, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.cyanAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Awaiting Approval', style: TextStyle(color: AppTheme.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(c['category'] ?? 'Water Issue', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Worker: ${c['assignedWorkerName'] ?? 'Yash Halde (Worker)'}', style: const TextStyle(color: AppTheme.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                      
                      // 1. Citizen Original Issue Photo
                      if (userImagePath.isNotEmpty && File(userImagePath).existsSync()) ...[
                        const SizedBox(height: 12),
                        const Text('📷 Citizen Original Issue Photo:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(userImagePath),
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],

                      // 2. Worker Completion Proof Photo Section
                      const SizedBox(height: 12),
                      const Text('📸 Worker Completion Proof Photo:', style: TextStyle(color: AppTheme.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      if (proofImagePath.isNotEmpty && File(proofImagePath).existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(proofImagePath),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 90,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: AppTheme.cyanAccent, size: 28),
                              SizedBox(height: 4),
                              Text('Proof Photo Submitted by Worker', style: TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (c['_id'] != null) {
                              _approveResolution(c['_id'].toHexString());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.statusGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Approve Resolution', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- TAB 2: WATER COMMAND CENTER ---
  Widget _buildAreaControlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Water Supply Command Center', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Control municipal water supply status for service areas.', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 20),

          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bhayandar East, Thane', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip('NORMAL', AppTheme.statusGreen, true),
                    const SizedBox(width: 8),
                    _buildStatusChip('LOW PRESS', AppTheme.statusOrange, false),
                    const SizedBox(width: 8),
                    _buildStatusChip('OUTAGE', AppTheme.statusRed, false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mira Road East, Thane', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip('NORMAL', AppTheme.statusGreen, true),
                    const SizedBox(width: 8),
                    _buildStatusChip('LOW PRESS', AppTheme.statusOrange, false),
                    const SizedBox(width: 8),
                    _buildStatusChip('OUTAGE', AppTheme.statusRed, false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? color : Colors.white10),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? color : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // --- TAB 3: ADMIN ACCOUNT ---
  Widget _buildAdminAccountTab(UserProvider user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 90),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 45,
            backgroundColor: AppTheme.statusOrange,
            child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(user.email, style: const TextStyle(fontSize: 14, color: Colors.white54)),
          const SizedBox(height: 30),

          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAdminInfoTile(Icons.security, 'System Access Level', 'Super Admin'),
                const Divider(color: Colors.white12),
                _buildAdminInfoTile(Icons.storage, 'Database Connection', 'Local MongoDB Connected'),
                const Divider(color: Colors.white12),
                _buildAdminInfoTile(Icons.verified_user, 'Assigned Authority', 'Mira-Bhayandar Municipal Corp'),
              ],
            ),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                user.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.statusRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Log Out of Admin Panel', style: TextStyle(color: AppTheme.statusRed, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfoTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.cyanAccent, size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
