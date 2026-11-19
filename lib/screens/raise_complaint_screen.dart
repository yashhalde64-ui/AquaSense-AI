import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/widgets/screen_background.dart';
import 'package:watermangment/services/mongo_service.dart';
import 'package:watermangment/providers/user_provider.dart';

class RaiseComplaintScreen extends StatefulWidget {
  const RaiseComplaintScreen({super.key});

  @override
  State<RaiseComplaintScreen> createState() => _RaiseComplaintScreenState();
}

class _RaiseComplaintScreenState extends State<RaiseComplaintScreen> {
  final _descController = TextEditingController();
  File? _image;
  String _selectedCategory = 'Low Pressure';
  bool _isSubmitting = false;

  // Auto-Location State
  Location _location = Location();
  String _detectedLocation = "Detecting live GPS location...";
  bool _isDetectingLocation = false;

  final List<String> _categories = [
    'Low Pressure',
    'No Water',
    'Water Contamination',
    'Pipe Leakage',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _autoDetectLocation();
  }

  Future<void> _autoDetectLocation() async {
    setState(() => _isDetectingLocation = true);

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _detectedLocation = "GPS Disabled. Default: Bhayandar East, Thane";
            _isDetectingLocation = false;
          });
          return;
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          setState(() {
            _detectedLocation = "Permission Denied. Default: Bhayandar East, Thane";
            _isDetectingLocation = false;
          });
          return;
        }
      }

      LocationData locationData = await _location.getLocation();
      final user = Provider.of<UserProvider>(context, listen: false);

      setState(() {
        _detectedLocation = "${user.area}, Thane (Lat: ${locationData.latitude!.toStringAsFixed(4)}, Lng: ${locationData.longitude!.toStringAsFixed(4)})";
        _isDetectingLocation = false;
      });
    } catch (e) {
      final user = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _detectedLocation = "${user.area}, Thane, Maharashtra";
        _isDetectingLocation = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitComplaint() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description for the complaint')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final userEmail = Provider.of<UserProvider>(context, listen: false).email;

    // Save complaint with live location into local MongoDB
    await MongoDatabase.submitComplaint(
      userEmail: userEmail,
      category: _selectedCategory,
      description: "$desc\n[Location: $_detectedLocation]",
      imagePath: _image?.path,
    );

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complaint saved to MongoDB with Live Location!'),
        backgroundColor: AppTheme.statusGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Raise Complaint',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Auto-Detected Location Banner
                      const Text('Auto-Detected Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location, color: AppTheme.cyanAccent, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _detectedLocation,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: _isDetectingLocation 
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyanAccent))
                                  : const Icon(Icons.refresh, color: Colors.white70, size: 20),
                              onPressed: _autoDetectLocation,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            dropdownColor: AppTheme.backgroundMedium,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                            items: _categories.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text('Description', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _descController,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Describe the issue...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text('Attach Photo (Optional)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_image != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                _image!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _image = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickImage(ImageSource.camera),
                                child: GlassContainer(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.camera_alt, color: AppTheme.cyanAccent, size: 30),
                                      const SizedBox(height: 8),
                                      Text('Camera', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickImage(ImageSource.gallery),
                                child: GlassContainer(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.photo_library, color: AppTheme.cyanAccent, size: 30),
                                      const SizedBox(height: 8),
                                      Text('Gallery', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitComplaint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Submit Complaint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
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
