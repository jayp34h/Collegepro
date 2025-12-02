import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/quiz_question.dart';
import 'firebase_quiz_initializer.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get quiz questions by subject
  static Future<List<QuizQuestion>> getQuizQuestions(String subject) async {
    try {
      debugPrint('🔍 Fetching questions for subject: $subject');
      
      // Check if Firebase has quiz data, if not initialize it
      final snapshot = await FirebaseFirestore.instance
          .collection('quiz_questions')
          .where('subject', isEqualTo: subject)
          .get();

      debugPrint('📊 Found ${snapshot.docs.length} questions in Firebase for $subject');

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ No questions found for $subject, initializing Firebase data...');
        // Initialize Firebase with quiz data
        await FirebaseQuizInitializer.initializeQuizData();
        
        // Try fetching again after initialization
        final retrySnapshot = await FirebaseFirestore.instance
            .collection('quiz_questions')
            .where('subject', isEqualTo: subject)
            .get();
        
        debugPrint('🔄 After initialization: Found ${retrySnapshot.docs.length} questions for $subject');
        
        if (retrySnapshot.docs.isEmpty) {
          debugPrint('❌ Still no questions after initialization, returning mock data');
          // Return mock data if Firebase initialization failed
          return _getMockQuestions(subject);
        }
        
        return retrySnapshot.docs
            .map((doc) {
              final data = Map<String, dynamic>.from(doc.data() as Map);
              data['id'] = doc.id;
              return QuizQuestion.fromJson(data);
            })
            .toList();
      }

      final questions = snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map);
            data['id'] = doc.id;
            return QuizQuestion.fromJson(data);
          })
          .toList();
      
      debugPrint('✅ Successfully loaded ${questions.length} questions for $subject');
      return questions;
    } catch (e) {
      debugPrint('❌ Error fetching quiz questions: $e');
      // Return mock data on error
      return _getMockQuestions(subject);
    }
  }

  // Save quiz result to Firebase
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await _firestore.collection('quiz_results').doc(result.id).set(result.toJson());
    } catch (e) {
      print('Error saving quiz result: $e');
      throw Exception('Failed to save quiz result');
    }
  }

  // Get user's quiz results
  Future<List<QuizResult>> getUserQuizResults(String userId) async {
    try {
      debugPrint('🔍 Fetching quiz results for user: $userId');
      
      // First try with orderBy, if it fails, try without ordering
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection('quiz_results')
            .where('userId', isEqualTo: userId)
            .orderBy('completedAt', descending: true)
            .get();
      } catch (orderError) {
        debugPrint('⚠️ OrderBy failed, trying without ordering: $orderError');
        // Fallback: query without ordering
        querySnapshot = await _firestore
            .collection('quiz_results')
            .where('userId', isEqualTo: userId)
            .get();
      }

      final results = querySnapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map);
            data['id'] = doc.id;
            return QuizResult.fromJson(data);
          })
          .toList();
      
      // Sort manually if we couldn't use orderBy
      results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      
      debugPrint('✅ Found ${results.length} quiz results for user: $userId');
      return results;
    } catch (e) {
      debugPrint('❌ Error fetching quiz results: $e');
      return [];
    }
  }

  // Initialize quiz questions in Firebase (call this once to populate)
  Future<void> initializeQuizQuestions() async {
    try {
      final batch = _firestore.batch();
      final questions = _getAllMockQuestions();

      for (final question in questions) {
        final docRef = _firestore.collection('quiz_questions').doc();
        batch.set(docRef, question.toJson());
      }

      await batch.commit();
      print('Quiz questions initialized successfully');
    } catch (e) {
      print('Error initializing quiz questions: $e');
    }
  }

  // Mock questions for fallback and initial data
  static List<QuizQuestion> _getMockQuestions(String subject) {
    debugPrint('🔍 Looking for mock questions with subject: $subject');
    
    List<QuizQuestion> filteredQuestions;
    switch (subject.toLowerCase()) {
      case 'programming':
        filteredQuestions = _getAllMockQuestions().where((q) => q.subject == 'programming').toList();
        break;
      case 'dsa':
        filteredQuestions = _getAllMockQuestions().where((q) => q.subject == 'dsa').toList();
        break;
      case 'dbms':
        filteredQuestions = _getAllMockQuestions().where((q) => q.subject == 'dbms').toList();
        break;
      case 'os':
        filteredQuestions = _getAllMockQuestions().where((q) => q.subject == 'os').toList();
        break;
      case 'cn':
        filteredQuestions = _getAllMockQuestions().where((q) => q.subject == 'cn').toList();
        break;
      case 'se_oop':
        filteredQuestions = _getAllMockQuestions().where((q) => q.subject == 'se_oop').toList();
        break;
      default:
        debugPrint('⚠️ Unknown subject: $subject, returning first 10 questions');
        filteredQuestions = _getAllMockQuestions().take(10).toList();
    }
    
    debugPrint('📚 Found ${filteredQuestions.length} mock questions for subject: $subject');
    return filteredQuestions;
  }

  static List<QuizQuestion> _getAllMockQuestions() {
    return [
      // Programming Questions
      QuizQuestion(
        id: 'prog_001',
        question: 'What is the correct way to declare a variable in Python?',
        options: ['var x = 5', 'x = 5', 'int x = 5', 'declare x = 5'],
        correctAnswer: 1,
        subject: 'programming',
        topic: 'Variables',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'prog_002',
        question: 'Which of the following is a valid Python data type?',
        options: ['int', 'string', 'boolean', 'All of the above'],
        correctAnswer: 3,
        subject: 'programming',
        topic: 'Data Types',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'prog_003',
        question: 'What is the output of: print(2 ** 3)?',
        options: ['6', '8', '9', 'Error'],
        correctAnswer: 1,
        subject: 'programming',
        topic: 'Operators',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'prog_004',
        question: 'Which loop is used when the number of iterations is unknown?',
        options: ['for loop', 'while loop', 'do-while loop', 'nested loop'],
        correctAnswer: 1,
        subject: 'programming',
        topic: 'Loops',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'prog_005',
        question: 'What is the purpose of the "break" statement?',
        options: ['Exit the program', 'Exit the current loop', 'Skip current iteration', 'Pause execution'],
        correctAnswer: 1,
        subject: 'programming',
        topic: 'Control Flow',
        difficulty: 'Medium',
      ),

      // DSA Questions
      QuizQuestion(
        id: 'dsa_001',
        question: 'What is the time complexity of binary search?',
        options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
        correctAnswer: 1,
        subject: 'dsa',
        topic: 'Search Algorithms',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'dsa_002',
        question: 'Which data structure follows LIFO principle?',
        options: ['Queue', 'Stack', 'Array', 'Linked List'],
        correctAnswer: 1,
        subject: 'dsa',
        topic: 'Data Structures',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'dsa_003',
        question: 'What is the worst-case time complexity of Quick Sort?',
        options: ['O(n log n)', 'O(n²)', 'O(n)', 'O(log n)'],
        correctAnswer: 1,
        subject: 'dsa',
        topic: 'Sorting',
        difficulty: 'Hard',
      ),
      QuizQuestion(
        id: 'dsa_004',
        question: 'Which traversal visits the root node first?',
        options: ['Inorder', 'Preorder', 'Postorder', 'Level order'],
        correctAnswer: 1,
        subject: 'dsa',
        topic: 'Trees',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'dsa_005',
        question: 'What is the space complexity of merge sort?',
        options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
        correctAnswer: 2,
        subject: 'dsa',
        topic: 'Sorting',
        difficulty: 'Medium',
      ),

      // DBMS Questions
      QuizQuestion(
        id: 'dbms_001',
        question: 'What does ACID stand for in database systems?',
        options: ['Atomicity, Consistency, Isolation, Durability', 'Accuracy, Consistency, Integrity, Durability', 'Atomicity, Concurrency, Isolation, Durability', 'Accuracy, Concurrency, Integrity, Durability'],
        correctAnswer: 0,
        subject: 'dbms',
        topic: 'Transactions',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'dbms_002',
        question: 'Which SQL command is used to retrieve data from a database?',
        options: ['GET', 'SELECT', 'RETRIEVE', 'FETCH'],
        correctAnswer: 1,
        subject: 'dbms',
        topic: 'SQL',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'dbms_003',
        question: 'What is a primary key?',
        options: ['A key that can be null', 'A unique identifier for records', 'A foreign key reference', 'An index on a table'],
        correctAnswer: 1,
        subject: 'dbms',
        topic: 'Keys',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'dbms_004',
        question: 'What is normalization in databases?',
        options: ['Combining tables', 'Organizing data to reduce redundancy', 'Creating indexes', 'Backing up data'],
        correctAnswer: 1,
        subject: 'dbms',
        topic: 'Normalization',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'dbms_005',
        question: 'Which normal form eliminates transitive dependencies?',
        options: ['1NF', '2NF', '3NF', 'BCNF'],
        correctAnswer: 2,
        subject: 'dbms',
        topic: 'Normalization',
        difficulty: 'Hard',
      ),

      // OS Questions
      QuizQuestion(
        id: 'os_001',
        question: 'What is a process in operating systems?',
        options: ['A program in execution', 'A stored program', 'A system call', 'A memory location'],
        correctAnswer: 0,
        subject: 'os',
        topic: 'Processes',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'os_002',
        question: 'Which scheduling algorithm gives the shortest average waiting time?',
        options: ['FCFS', 'SJF', 'Round Robin', 'Priority'],
        correctAnswer: 1,
        subject: 'os',
        topic: 'Scheduling',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'os_003',
        question: 'What is deadlock in operating systems?',
        options: ['Process termination', 'Circular wait condition', 'Memory overflow', 'CPU overload'],
        correctAnswer: 1,
        subject: 'os',
        topic: 'Deadlock',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'os_004',
        question: 'What is virtual memory?',
        options: ['Physical RAM', 'Storage technique that provides illusion of large memory', 'Cache memory', 'ROM'],
        correctAnswer: 1,
        subject: 'os',
        topic: 'Memory Management',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'os_005',
        question: 'Which algorithm is used for page replacement?',
        options: ['FIFO', 'LRU', 'Optimal', 'All of the above'],
        correctAnswer: 3,
        subject: 'os',
        topic: 'Memory Management',
        difficulty: 'Medium',
      ),

      // CN Questions
      QuizQuestion(
        id: 'cn_001',
        question: 'What does TCP stand for?',
        options: ['Transfer Control Protocol', 'Transmission Control Protocol', 'Transport Control Protocol', 'Terminal Control Protocol'],
        correctAnswer: 1,
        subject: 'cn',
        topic: 'Protocols',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'cn_002',
        question: 'Which layer of OSI model handles routing?',
        options: ['Physical', 'Data Link', 'Network', 'Transport'],
        correctAnswer: 2,
        subject: 'cn',
        topic: 'OSI Model',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'cn_003',
        question: 'What is the purpose of ARP?',
        options: ['Address Resolution Protocol - maps IP to MAC', 'Application Request Protocol', 'Automatic Routing Protocol', 'Access Request Protocol'],
        correctAnswer: 0,
        subject: 'cn',
        topic: 'Protocols',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'cn_004',
        question: 'Which protocol is connectionless?',
        options: ['TCP', 'UDP', 'HTTP', 'FTP'],
        correctAnswer: 1,
        subject: 'cn',
        topic: 'Protocols',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'cn_005',
        question: 'What is the maximum size of an Ethernet frame?',
        options: ['1024 bytes', '1500 bytes', '2048 bytes', '4096 bytes'],
        correctAnswer: 1,
        subject: 'cn',
        topic: 'Data Link Layer',
        difficulty: 'Hard',
      ),

      // SE/OOP Questions
      QuizQuestion(
        id: 'se_001',
        question: 'What is encapsulation in OOP?',
        options: ['Hiding implementation details', 'Creating multiple objects', 'Inheriting properties', 'Overriding methods'],
        correctAnswer: 0,
        subject: 'se_oop',
        topic: 'OOP Concepts',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'se_002',
        question: 'Which SDLC model is most suitable for changing requirements?',
        options: ['Waterfall', 'Agile', 'V-Model', 'Spiral'],
        correctAnswer: 1,
        subject: 'se_oop',
        topic: 'SDLC',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'se_003',
        question: 'What is polymorphism?',
        options: ['Multiple inheritance', 'Method overloading', 'One interface, multiple implementations', 'Data hiding'],
        correctAnswer: 2,
        subject: 'se_oop',
        topic: 'OOP Concepts',
        difficulty: 'Medium',
      ),
      QuizQuestion(
        id: 'se_004',
        question: 'What is the purpose of unit testing?',
        options: ['Test the entire system', 'Test individual components', 'Test user interface', 'Test performance'],
        correctAnswer: 1,
        subject: 'se_oop',
        topic: 'Testing',
        difficulty: 'Easy',
      ),
      QuizQuestion(
        id: 'se_005',
        question: 'Which design pattern ensures only one instance of a class?',
        options: ['Factory', 'Singleton', 'Observer', 'Strategy'],
        correctAnswer: 1,
        subject: 'se_oop',
        topic: 'Design Patterns',
        difficulty: 'Medium',
      ),
    ];
  }
}
