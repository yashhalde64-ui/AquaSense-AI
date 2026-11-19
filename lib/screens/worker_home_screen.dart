import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/widgets/screen_background.dart';
import 'package:watermangment/services/mongo_service.dart';
import 'package:watermangment/providers/user_provider.dart';
import 'package:watermangment/screens/login_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  List<Map<String, dynamic>> _myTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    final tasks = await MongoDatabase.getWorkerTasks(user.email);
    if (mounted) {
      setState(() {
        _myTasks = tasks;
        _isLoading = false;
      });
    }
  }

  void _showCompleteTaskSheet(Map<String, dynamic> complaint) {
    File? proofImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: GlassContainer(
                borderRadius: 25,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Complete Task & Upload Proof', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Complaint: ${complaint['category']}', style: const TextStyle(color: AppTheme.cyanAccent)),
                    const SizedBox(height: 20),

                    if (proofImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(proofImage!, height: 160, width: double.infinity, fit: BoxFit.cover),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picker = ImagePicker();
                                final file = await picker.pickImage(source: ImageSource.camera);
                                if (file != null) {
                                  setSheetState(() => proofImage = File(file.path));
                                }
                              },
                              child: GlassContainer(
                                child: const Column(
                                  children: [
                                    Icon(Icons.camera_alt, color: AppTheme.cyanAccent, size: 28),
                                    SizedBox(height: 6),
                                    Text('Camera Proof', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picker = ImagePicker();
                                final file = await picker.pickImage(source: ImageSource.gallery);
                                if (file != null) {
                                  setSheetState(() => proofImage = File(file.path));
                                }
                              },
                              child: GlassContainer(
                                child: const Column(
                                  children: [
                                    Icon(Icons.photo_library, color: AppTheme.cyanAccent, size: 28),
                                    SizedBox(height: 6),
                                    Text('Gallery', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (complaint['_id'] != null) {
                            await MongoDatabase.workerSubmitResolution(
                              complaintId: complaint['_id'].toHexString(),
                              proofImagePath: proofImage?.path ?? '',
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Submitted for Admin Approval!'),
                                backgroundColor: AppTheme.statusGreen,
                              ),
                            );
                            _loadTasks();
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                        child: const Text('Submit Work to Admin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/logo.png', height: 35),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.cyanAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.cyanAccent, width: 0.5),
                              ),
                              child: const Text('FIELD WORKER', style: TextStyle(fontSize: 9, color: AppTheme.cyanAccent, fontWeight: FontWeight.bold)),
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('My Assigned Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.cyanAccent))
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        color: AppTheme.cyanAccent,
                        child: _myTasks.isEmpty
                            ? const Center(child: Text('No tasks assigned yet!', style: TextStyle(color: Colors.white54)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _myTasks.length,
                                itemBuilder: (context, index) {
                                  final task = _myTasks[index];
                                  final idStr = task['_id'] != null ? task['_id'].toString().substring(0, 6) : '$index';
                                  final status = task['status'] ?? 'Assigned';

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
                                                  color: status == 'Resolved' ? AppTheme.statusGreen.withOpacity(0.2) : AppTheme.statusOrange.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(status, style: TextStyle(color: status == 'Resolved' ? AppTheme.statusGreen : AppTheme.statusOrange, fontSize: 11, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(task['category'] ?? 'Task', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                          const SizedBox(height: 4),
                                          Text(task['description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                          const SizedBox(height: 16),

                                          if (status == 'Assigned')
                                            SizedBox(
                                              width: double.infinity,
                                              height: 45,
                                              child: ElevatedButton.icon(
                                                onPressed: () => _showCompleteTaskSheet(task),
                                                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                                label: const Text('Complete & Upload Proof', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                                              ),
                                            )
                                          else if (status == 'Awaiting Approval')
                                            const Text('Submitted to Admin for Approval', style: TextStyle(color: AppTheme.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold))
                                          else
                                            const Text('Resolved & Approved', style: TextStyle(color: AppTheme.statusGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
