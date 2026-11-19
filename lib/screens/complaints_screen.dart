import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/screens/raise_complaint_screen.dart';
import 'package:watermangment/services/mongo_service.dart';
import 'package:watermangment/providers/user_provider.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  List<Map<String, dynamic>> _mongoComplaints = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final userEmail = Provider.of<UserProvider>(context, listen: false).email;
    final complaints = await MongoDatabase.getUserComplaints(userEmail);
    if (mounted) {
      setState(() {
        _mongoComplaints = complaints;
        _isLoading = false;
      });
    }
  }

  void _showVerificationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Verify Resolution', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Has complaint $id been resolved satisfactorily?', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.statusGreen, size: 40),
                    SizedBox(height: 8),
                    Text('Resolution Proof Attached', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complaint Reopened.')),
                );
              },
              child: const Text('Reopen Complaint', style: TextStyle(color: AppTheme.statusRed)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resolution Verified & Closed!'), backgroundColor: AppTheme.statusGreen),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanAccent),
              child: const Text('Verify & Close', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter complaints
    List<Map<String, dynamic>> filteredList = _mongoComplaints.where((c) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Pending') return (c['status'] ?? 'Pending') == 'Pending';
      if (_selectedFilter == 'Resolved') return (c['status'] ?? 'Pending') == 'Resolved';
      if (_selectedFilter == 'Requires Verification') return (c['status'] ?? 'Pending') == 'Verify Resolution';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Complaints',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const RaiseComplaintScreen()),
                      );
                      _loadComplaints();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab-like filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Pending'),
                  _buildFilterChip('Resolved'),
                  _buildFilterChip('Requires Verification'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.cyanAccent))
                  : RefreshIndicator(
                      onRefresh: _loadComplaints,
                      color: AppTheme.cyanAccent,
                      child: ListView(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 110),
                        children: [
                          ...filteredList.map((c) {
                            String status = c['status'] ?? 'Pending';
                            Color statusColor = AppTheme.statusOrange;
                            if (status == 'Resolved') statusColor = AppTheme.statusGreen;
                            if (status == 'Assigned') statusColor = AppTheme.cyanAccent;
                            if (status == 'Awaiting Approval') statusColor = AppTheme.statusOrange;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildComplaintCard(
                                id: '#CMP-${c['_id'].toString().substring(0, 6)}',
                                date: c['createdAt'] != null 
                                    ? c['createdAt'].toString().split('T').first 
                                    : 'Today',
                                category: c['category'] ?? 'Complaint',
                                status: status,
                                statusColor: statusColor,
                                assignedWorker: c['assignedWorkerName'] ?? '',
                              ),
                            );
                          }),
                          if (_mongoComplaints.isEmpty) ...[
                            if (_selectedFilter == 'All' || _selectedFilter == 'Pending')
                              _buildComplaintCard(
                                id: '#CMP-8901',
                                date: 'Today, 08:30 AM',
                                category: 'Low Pressure',
                                status: 'In Progress',
                                statusColor: AppTheme.statusOrange,
                              ),
                            if (_selectedFilter == 'All' || _selectedFilter == 'Requires Verification') ...[
                              const SizedBox(height: 16),
                              _buildComplaintCard(
                                id: '#CMP-8842',
                                date: '12 Oct, 2023',
                                category: 'Water Contamination',
                                status: 'Verify Resolution',
                                statusColor: AppTheme.cyanAccent,
                                needsAction: true,
                              ),
                            ],
                            if (_selectedFilter == 'All' || _selectedFilter == 'Resolved') ...[
                              const SizedBox(height: 16),
                              _buildComplaintCard(
                                id: '#CMP-8105',
                                date: '05 Sep, 2023',
                                category: 'Pipe Leakage',
                                status: 'Resolved',
                                statusColor: AppTheme.statusGreen,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard({
    required String id,
    required String date,
    required String category,
    required String status,
    required Color statusColor,
    String assignedWorker = '',
    bool needsAction = false,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (assignedWorker.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Assigned to: $assignedWorker',
              style: const TextStyle(color: AppTheme.cyanAccent, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (needsAction)
                ElevatedButton(
                  onPressed: () => _showVerificationDialog(id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyanAccent,
                    foregroundColor: AppTheme.backgroundDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              else
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
            ],
          ),
        ],
      ),
    );
  }
}
