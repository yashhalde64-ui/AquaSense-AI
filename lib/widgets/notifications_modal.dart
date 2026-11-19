import 'package:flutter/material.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';

void showNotificationsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GlassContainer(
          borderRadius: 30,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildNotifItem(
                icon: Icons.water_drop,
                color: AppTheme.statusGreen,
                title: 'Water Supply Arrived',
                desc: 'Water supply has started in Bhayandar East.',
                time: '10 mins ago',
              ),
              const SizedBox(height: 12),
              _buildNotifItem(
                icon: Icons.assignment_turned_in,
                color: AppTheme.cyanAccent,
                title: 'Complaint Update',
                desc: 'Your complaint #CMP-8842 has been marked resolved.',
                time: '2 hours ago',
              ),
              const SizedBox(height: 12),
              _buildNotifItem(
                icon: Icons.warning_amber_rounded,
                color: AppTheme.statusOrange,
                title: 'Low Pressure Alert',
                desc: 'Multiple users reported low water pressure in your area.',
                time: 'Yesterday',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildNotifItem({
  required IconData icon,
  required Color color,
  required String title,
  required String desc,
  required String time,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}
