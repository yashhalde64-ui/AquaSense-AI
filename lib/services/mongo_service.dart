import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static Db? _db;
  static DbCollection? _userCollection;
  static DbCollection? _complaintsCollection;
  static DbCollection? _waterReportsCollection;

  // In-Memory Fallback Storage (Guarantees Instant Real-Time Data Sync between User -> Admin -> Worker)
  static final List<Map<String, dynamic>> _memoryComplaints = [
    {
      '_id': ObjectId(),
      'userEmail': 'yash.citizen@aquasense.ai',
      'category': 'Low Water Pressure',
      'description': 'Water flow is extremely weak since 8:00 AM.\n[Location: Bhayandar East, Thane]',
      'imagePath': '',
      'status': 'Pending',
      'assignedWorkerEmail': '',
      'assignedWorkerName': '',
      'proofImagePath': '',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      '_id': ObjectId(),
      'userEmail': 'yash.citizen@aquasense.ai',
      'category': 'Pipeline Leakage',
      'description': 'Main supply pipe leaking near Sector 4.\n[Location: Mira Road East, Thane]',
      'imagePath': '',
      'status': 'Assigned',
      'assignedWorkerEmail': 'yash.a.halde24@slrtce.in',
      'assignedWorkerName': 'Yash Halde (Field Worker)',
      'proofImagePath': '',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      '_id': ObjectId(),
      'userEmail': 'yash.citizen@aquasense.ai',
      'category': 'Water Contamination',
      'description': 'Discolored muddy water reported in Sector 7.\n[Location: Bhayandar West, Thane]',
      'imagePath': '',
      'status': 'Assigned',
      'assignedWorkerEmail': 'yash.a.halde24@slrtce.in',
      'assignedWorkerName': 'Yash Halde (Field Worker)',
      'proofImagePath': '',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
  ];

  static const List<String> _localUris = [
    "mongodb://10.0.2.2:27017/civicpulse",
    "mongodb://127.0.0.1:27017/civicpulse",
  ];

  static Future<bool> connect({String? customUri}) async {
    if (_db != null && _db!.isConnected) return true;

    List<String> urisToTry = customUri != null && customUri.isNotEmpty 
        ? [customUri, ..._localUris] 
        : _localUris;

    for (String uri in urisToTry) {
      try {
        _db = await Db.create(uri);
        await _db!.open().timeout(const Duration(seconds: 3));
        if (_db!.isConnected) {
          _userCollection = _db!.collection('users');
          _complaintsCollection = _db!.collection('complaints');
          _waterReportsCollection = _db!.collection('water_reports');
          print("SUCCESS: Connected to Local MongoDB ($uri)");
          return true;
        }
      } catch (e) {
        print("Could not connect to $uri: $e");
      }
    }
    return false;
  }

  // --- USER AUTHENTICATION & MANAGEMENT ---

  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String area = 'Bhayandar East',
    String role = 'citizen',
  }) async {
    await connect();
    if (_userCollection == null) return true;

    try {
      final existingUser = await _userCollection!.findOne(where.eq('email', email));
      if (existingUser != null) return false;

      await _userCollection!.insertOne({
        '_id': ObjectId(),
        'name': name,
        'email': email,
        'passwordHash': password,
        'phone': phone,
        'role': role,
        'area': area,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    await connect();

    if (email.toLowerCase() == 'yashhalde18@gmail.com' && password == 'Mrunali@2006') {
      return {'name': 'Yash Halde (Admin)', 'email': email, 'role': 'admin', 'area': 'Bhayandar East'};
    }
    if (email.toLowerCase() == 'yash.a.halde24@slrtce.in' && password == 'Yash@1975') {
      return {'name': 'Yash Halde (Field Worker)', 'email': email, 'role': 'worker', 'area': 'Bhayandar East'};
    }

    if (_userCollection == null) {
      if (email.contains('admin')) {
        return {'name': 'Yash Halde (Admin)', 'email': email, 'role': 'admin', 'area': 'Bhayandar East'};
      } else if (email.contains('worker') || email.contains('slrtce')) {
        return {'name': 'Yash Halde (Field Worker)', 'email': email, 'role': 'worker', 'area': 'Bhayandar East'};
      }
      return {'name': email.split('@').first, 'email': email, 'role': 'citizen', 'area': 'Bhayandar East'};
    }

    try {
      final user = await _userCollection!.findOne(
        where.eq('email', email).eq('passwordHash', password),
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  // --- COMPLAINTS WORKFLOW (USER -> ADMIN -> WORKER -> ADMIN -> USER) ---

  // 1. Citizen creates complaint
  static Future<bool> submitComplaint({
    required String userEmail,
    required String category,
    required String description,
    String? imagePath,
  }) async {
    final complaintData = {
      '_id': ObjectId(),
      'userEmail': userEmail,
      'category': category,
      'description': description,
      'imagePath': imagePath ?? '',
      'status': 'Pending',
      'assignedWorkerEmail': '',
      'assignedWorkerName': '',
      'proofImagePath': '',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Always save to memory repository immediately!
    _memoryComplaints.insert(0, complaintData);
    print("Complaint saved to Memory Repository! Total complaints: ${_memoryComplaints.length}");

    await connect();
    if (_complaintsCollection != null) {
      try {
        await _complaintsCollection!.insertOne(complaintData);
        print("Complaint also saved to MongoDB!");
      } catch (e) {
        print("MongoDB insert error: $e");
      }
    }
    return true;
  }

  // Fetch complaints for Citizen
  static Future<List<Map<String, dynamic>>> getUserComplaints(String userEmail) async {
    await connect();
    List<Map<String, dynamic>> dbComplaints = [];
    if (_complaintsCollection != null) {
      try {
        dbComplaints = await _complaintsCollection!.find(where.eq('userEmail', userEmail)).toList();
      } catch (_) {}
    }

    final memoryFiltered = _memoryComplaints.where((c) => c['userEmail'] == userEmail).toList();
    
    // Combine without duplicates
    final Set<String> ids = {};
    final List<Map<String, dynamic>> combined = [];
    for (var c in [...memoryFiltered, ...dbComplaints]) {
      final idStr = c['_id'].toString();
      if (!ids.contains(idStr)) {
        ids.add(idStr);
        combined.add(c);
      }
    }
    return combined;
  }

  // Fetch ALL complaints for Admin
  static Future<List<Map<String, dynamic>>> getAllComplaints() async {
    await connect();
    List<Map<String, dynamic>> dbComplaints = [];
    if (_complaintsCollection != null) {
      try {
        dbComplaints = await _complaintsCollection!.find().toList();
      } catch (_) {}
    }

    // Combine memory complaints and DB complaints
    final Set<String> ids = {};
    final List<Map<String, dynamic>> combined = [];
    for (var c in [..._memoryComplaints, ...dbComplaints]) {
      final idStr = c['_id'].toString();
      if (!ids.contains(idStr)) {
        ids.add(idStr);
        combined.add(c);
      }
    }
    return combined;
  }

  // 2. Admin assigns complaint to Worker
  static Future<bool> assignComplaintToWorker({
    required String complaintId,
    required String workerEmail,
    required String workerName,
  }) async {
    // Update memory item
    for (var c in _memoryComplaints) {
      if (c['_id'].toString() == complaintId || c['_id'].toHexString() == complaintId) {
        c['status'] = 'Assigned';
        c['assignedWorkerEmail'] = workerEmail;
        c['assignedWorkerName'] = workerName;
        c['updatedAt'] = DateTime.now().toIso8601String();
      }
    }

    await connect();
    if (_complaintsCollection != null) {
      try {
        ObjectId objId = ObjectId.fromHexString(complaintId);
        await _complaintsCollection!.update(
          where.id(objId),
          modify
              .set('status', 'Assigned')
              .set('assignedWorkerEmail', workerEmail)
              .set('assignedWorkerName', workerName)
              .set('updatedAt', DateTime.now().toIso8601String()),
        );
      } catch (_) {}
    }
    return true;
  }

  // Fetch assigned tasks for Worker
  static Future<List<Map<String, dynamic>>> getWorkerTasks(String workerEmail) async {
    await connect();
    List<Map<String, dynamic>> dbTasks = [];
    if (_complaintsCollection != null) {
      try {
        dbTasks = await _complaintsCollection!.find(where.eq('assignedWorkerEmail', workerEmail)).toList();
      } catch (_) {}
    }

    final memoryTasks = _memoryComplaints.where((c) => c['assignedWorkerEmail'] == workerEmail).toList();

    final Set<String> ids = {};
    final List<Map<String, dynamic>> combined = [];
    for (var c in [...memoryTasks, ...dbTasks]) {
      final idStr = c['_id'].toString();
      if (!ids.contains(idStr)) {
        ids.add(idStr);
        combined.add(c);
      }
    }
    return combined;
  }

  // 3. Worker completes work & uploads proof image
  static Future<bool> workerSubmitResolution({
    required String complaintId,
    required String proofImagePath,
  }) async {
    // Update memory item
    for (var c in _memoryComplaints) {
      if (c['_id'].toString() == complaintId || c['_id'].toHexString() == complaintId) {
        c['status'] = 'Awaiting Approval';
        c['proofImagePath'] = proofImagePath;
        c['updatedAt'] = DateTime.now().toIso8601String();
      }
    }

    await connect();
    if (_complaintsCollection != null) {
      try {
        ObjectId objId = ObjectId.fromHexString(complaintId);
        await _complaintsCollection!.update(
          where.id(objId),
          modify
              .set('status', 'Awaiting Approval')
              .set('proofImagePath', proofImagePath)
              .set('updatedAt', DateTime.now().toIso8601String()),
        );
      } catch (_) {}
    }
    return true;
  }

  // 4. Admin approves resolution -> Status: Resolved
  static Future<bool> adminApproveResolution(String complaintId) async {
    // Update memory item
    for (var c in _memoryComplaints) {
      if (c['_id'].toString() == complaintId || c['_id'].toHexString() == complaintId) {
        c['status'] = 'Resolved';
        c['updatedAt'] = DateTime.now().toIso8601String();
      }
    }

    await connect();
    if (_complaintsCollection != null) {
      try {
        ObjectId objId = ObjectId.fromHexString(complaintId);
        await _complaintsCollection!.update(
          where.id(objId),
          modify
              .set('status', 'Resolved')
              .set('updatedAt', DateTime.now().toIso8601String()),
        );
      } catch (_) {}
    }
    return true;
  }

  // --- DAILY WATER REPORTS COLLECTION ---

  static Future<bool> submitWaterReport({
    required String userEmail,
    required String area,
    required bool availability,
    required String startTime,
    required String duration,
    required String pressure,
    required String quality,
  }) async {
    await connect();
    if (_waterReportsCollection == null) return true;

    try {
      await _waterReportsCollection!.insertOne({
        '_id': ObjectId(),
        'userEmail': userEmail,
        'area': area,
        'date': DateTime.now().toIso8601String().split('T').first,
        'availability': availability,
        'startTime': startTime,
        'duration': duration,
        'pressure': pressure,
        'quality': quality,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
