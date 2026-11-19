import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/services/mongo_service.dart';
import 'package:watermangment/providers/user_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  double _pressureValue = 2.0;
  double _qualityValue = 2.0;
  bool _waterAvailable = true;
  bool _isSubmitting = false;

  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 30);

  final List<String> _pressureLabels = ['Low', 'Medium', 'High'];
  final List<String> _qualityLabels = ['Poor', 'Fair', 'Good', 'Excellent'];

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submitReport() async {
    setState(() => _isSubmitting = true);

    final user = Provider.of<UserProvider>(context, listen: false);

    await MongoDatabase.submitWaterReport(
      userEmail: user.email,
      area: user.area,
      availability: _waterAvailable,
      startTime: _startTime.format(context),
      duration: '2.5 Hours',
      pressure: _pressureLabels[_pressureValue.toInt()],
      quality: _qualityLabels[_qualityValue.toInt()],
    );

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daily Water Report saved to MongoDB!'),
        backgroundColor: AppTheme.statusGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 110.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Water Report',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Help us monitor water supply in your area.',
                style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
              ),
              const SizedBox(height: 30),
              _buildAvailabilityToggle(),
              const SizedBox(height: 24),
              if (_waterAvailable) ...[
                _buildTimeSelector(),
                const SizedBox(height: 24),
                _buildSliderSection(
                  title: 'Water Pressure',
                  value: _pressureValue,
                  labels: _pressureLabels,
                  onChanged: (val) => setState(() => _pressureValue = val),
                  activeColor: AppTheme.statusOrange,
                ),
                const SizedBox(height: 24),
                _buildSliderSection(
                  title: 'Water Quality',
                  value: _qualityValue,
                  labels: _qualityLabels,
                  onChanged: (val) => setState(() => _qualityValue = val),
                  activeColor: AppTheme.statusGreen,
                  divisions: 3,
                  max: 3,
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return GlassContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _waterAvailable ? Icons.water_drop : Icons.water_drop_outlined,
                color: _waterAvailable ? AppTheme.cyanAccent : Colors.grey,
              ),
              const SizedBox(width: 12),
              const Text(
                'Is water available today?',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
          Switch(
            value: _waterAvailable,
            onChanged: (val) => setState(() => _waterAvailable = val),
            activeColor: AppTheme.cyanAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supply Timings',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(true),
                  child: _buildTimeField('Start Time', _startTime.format(context)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('to', style: TextStyle(color: Colors.white54)),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(false),
                  child: _buildTimeField('End Time', _endTime.format(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(color: Colors.white)),
              const Icon(Icons.access_time, color: Colors.white54, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required List<String> labels,
    required Function(double) onChanged,
    required Color activeColor,
    int divisions = 2,
    double max = 2.0,
  }) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                labels[value.toInt()],
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: activeColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: activeColor.withOpacity(0.2),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
              activeTickMarkColor: Colors.white,
              inactiveTickMarkColor: Colors.white.withOpacity(0.5),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map((l) => Text(l, style: const TextStyle(fontSize: 10, color: Colors.white54)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
