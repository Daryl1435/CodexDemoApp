import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// Reads the notes that belong to the class identified by [classId].
///
/// The notes are read from the `classNotes` collection where each document
/// stores a `classId` field. The documents are returned in descending
/// chronological order based on a `createdAt` timestamp field when present.
Future<List<Map<String, dynamic>>> readClassNotes(
  String classId, {
  FirebaseFirestore? firestore,
}) async {
  final db = firestore ?? FirebaseFirestore.instance;

  try {
    final querySnapshot = await db
        .collection('classNotes')
        .where('classId', isEqualTo: classId)
        .get();

    final notes = querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList(growable: false);

    notes.sort((a, b) {
      final aTimestamp = a['createdAt'];
      final bTimestamp = b['createdAt'];

      if (aTimestamp is Timestamp && bTimestamp is Timestamp) {
        return bTimestamp.compareTo(aTimestamp);
      }

      return 0;
    });

    return notes;
  } on FirebaseException catch (error) {
    throw Exception('Unable to read notes for class "$classId": ${error.message}');
  }
}

/// Fetches the questions for a given class by filtering the `questions`
/// collection on the provided [classId].
Future<List<Map<String, dynamic>>> fetchQuestionsByClass(
  String classId, {
  FirebaseFirestore? firestore,
}) async {
  final db = firestore ?? FirebaseFirestore.instance;

  try {
    final querySnapshot = await db
        .collection('questions')
        .where('classId', isEqualTo: classId)
        .get();

    final questions = querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList(growable: false);

    questions.sort((a, b) {
      final aOrder = a['order'];
      final bOrder = b['order'];

      if (aOrder is num && bOrder is num) {
        return aOrder.compareTo(bOrder);
      }

      return 0;
    });

    return questions;
  } on FirebaseException catch (error) {
    throw Exception(
      'Unable to fetch questions for class "$classId": ${error.message}',
    );
  }
}

/// Updates the score of a user identified by [userId] for the class
/// identified by [classId]. The score increment is applied atomically so the
/// function is safe to call concurrently.
Future<void> updateUserScore(
  String userId,
  String classId,
  int scoreIncrement, {
  FirebaseFirestore? firestore,
}) async {
  final db = firestore ?? FirebaseFirestore.instance;
  final scoresRef = db.collection('userScores').doc(userId);

  try {
    await scoresRef.set({
      'scores.$classId': FieldValue.increment(scoreIncrement),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  } on FirebaseException catch (error) {
    throw Exception(
      'Unable to update score for user "$userId": ${error.message}',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  User? _user;
  String _status = 'Initializing Firebase...';

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _auth.signInAnonymously();
      _user = _auth.currentUser;
      await _firestore.collection('samples').doc(_user!.uid).set({
        'initializedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _status = 'Firebase initialized with UID: ${_user!.uid}';
      });
    } on FirebaseAuthException catch (error) {
      setState(() {
        _status = 'Auth error: ${error.message}';
      });
    } catch (error) {
      setState(() {
        _status = 'Unexpected error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _status,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
