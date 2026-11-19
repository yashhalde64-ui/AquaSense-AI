import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/widgets/civic_ai_modal.dart';
import 'package:watermangment/widgets/app_drawer.dart';
import 'package:watermangment/widgets/notifications_modal.dart';
import 'package:watermangment/widgets/location_picker_modal.dart';
import 'package:watermangment/screens/report_screen.dart';
import 'package:watermangment/screens/complaints_screen.dart';
import 'package:watermangment/screens/map_screen.dart';
import 'package:watermangment/screens/profile_screen.dart';
import 'package:watermangment/widgets/screen_background.dart';
import 'package:watermangment/screens/raise_complaint_screen.dart';
import 'package:watermangment/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onSelectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeDashboard(
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        onSelectTab: _onSelectTab,
      ),
      const ReportScreen(),
      const ComplaintsScreen(),
      const MapScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: Colors.transparent,
      drawer: AppDrawer(onSelectTab: _onSelectTab),
      body: ScreenBackground(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          color: Colors.transparent,
          child: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        borderRadius: 25,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.water_drop_outlined, 'Report', 1),
            _buildNavItem(Icons.assignment_outlined, 'Complaints', 2),
            _buildNavItem(Icons.map_outlined, 'Map', 3),
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.cyanAccent : Colors.white70,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppTheme.cyanAccent : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(
              width: 16,
              height: 2,
              color: AppTheme.cyanAccent,
            )
          ]
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final Function(int) onSelectTab;

  const _HomeDashboard({
    required this.onOpenDrawer,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildGreeting(context),
            const SizedBox(height: 20),
            _buildLocationSelector(context),
            const SizedBox(height: 20),
            _buildWaterStatusCard(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildQuickActionsHeader(),
            const SizedBox(height: 15),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 20),
            _buildAlertBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Hamburger Menu Button -> Opens App Drawer
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: onOpenDrawer,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Row(
          children: [
            Image.asset('assets/images/logo.png', height: 26, fit: BoxFit.contain),
            const SizedBox(width: 8),
            const Text(
              'AquaSense AI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Civic AI Button
            GestureDetector(
              onTap: () => showCivicAIModal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.cyanAccent, AppTheme.primaryBlue]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cyanAccent.withOpacity(0.3),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Notification Bell Button
            GestureDetector(
              onTap: () => showNotificationsModal(context),
              child: Stack(
                children: [
                  const Icon(Icons.notifications_none, color: Colors.white, size: 26),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Profile Avatar -> Opens Profile Tab
            GestureDetector(
              onTap: () => onSelectTab(4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning,',
          style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 2),
        Text(
          '${user.name} 👋',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLocationSelector(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return GestureDetector(
      onTap: () => showLocationPickerModal(context),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.area,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Thane, Maharashtra',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterStatusCard() {
    return GlassContainer(
      color: Colors.blueAccent.withOpacity(0.1),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Water Supply Status',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              SizedBox(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppTheme.statusGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'NORMAL',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.statusGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: AppTheme.cyanAccent, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expected Supply',
                                style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                              ),
                              const Text(
                                '7:00 AM – 9:00 AM',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.78,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.statusGreen),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '78%',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Reliability\nScore',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.access_time,
            title: 'Today\'s\nDuration',
            value: '1.5 Hours',
            progressColor: AppTheme.primaryBlue,
            progress: 0.6,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.speed,
            title: 'Water\nPressure',
            value: 'Medium',
            progressColor: AppTheme.statusOrange,
            progress: 0.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.water_drop_outlined,
            title: 'Water\nQuality',
            value: 'Good',
            progressColor: AppTheme.statusGreen,
            progress: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color progressColor,
    required double progress,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: progressColor, size: 20),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          'View All',
          style: TextStyle(fontSize: 14, color: AppTheme.primaryBlue),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionBtn(Icons.water_drop, 'Report\nWater', Colors.blue, () {
          onSelectTab(1); // Navigates to Daily Water Report tab
        }),
        _buildActionBtn(Icons.assignment, 'Raise\nComplaint', Colors.pink, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RaiseComplaintScreen()));
        }),
        _buildActionBtn(Icons.map, 'Live\nMap', Colors.green, () {
          onSelectTab(3); // Navigates to Live Map tab
        }),
        _buildActionBtn(Icons.bar_chart, 'History', Colors.purple, () {
          onSelectTab(2); // Navigates to Complaints / History tab
        }),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          GlassContainer(
            width: 70,
            height: 70,
            padding: EdgeInsets.zero,
            child: Center(
              child: Icon(icon, color: color, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelectTab(2), // Opens Complaints / Alerts
      child: GlassContainer(
        color: Colors.redAccent.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: const [
            Icon(Icons.people, color: Colors.redAccent),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '12 people reported\nlow pressure today',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
