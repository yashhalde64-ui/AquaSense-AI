import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/providers/user_provider.dart';

void showLocationPickerModal(BuildContext context) {
  final areas = [
    'Bhayandar East, Thane',
    'Bhayandar West, Thane',
    'Mira Road East, Thane',
    'Borivali East, Mumbai',
    'Kandivali West, Mumbai',
  ];

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Service Area',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              ...areas.map((area) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: AppTheme.cyanAccent),
                      title: Text(area, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white30, size: 18),
                      onTap: () {
                        final parts = area.split(', ');
                        Provider.of<UserProvider>(context, listen: false)
                            .setUser(
                              Provider.of<UserProvider>(context, listen: false).name,
                              Provider.of<UserProvider>(context, listen: false).email,
                              parts.first,
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected Service Area: ${parts.first}')),
                        );
                      },
                    ),
                  )),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}
